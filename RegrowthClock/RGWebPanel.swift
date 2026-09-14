import SwiftUI
import WebKit

// MARK: - Session survival across a cold start

/// Remembers the last page the launch panel was really on, so a cold start resumes there
/// instead of re-running the redirect chain from the top — which would land a user who has
/// already registered on the offer's landing page again, and read as "it logged me out".
enum RGPanelSession {
    private static let addressKey = "rg.panel.resume.address"
    private static let stampKey   = "rg.panel.resume.stamp"
    /// Past this a resumed address is likelier to be stale than useful.
    private static let maxAge: TimeInterval = 60 * 60 * 24 * 30

    static func remember(_ url: URL?, trackerHost: String) {
        // No tracker host means this is not the launch panel — the Settings/Privacy sheet
        // passes none, which switches remembering off for it. Without this guard the next
        // launch resumes the privacy page instead of the offer.
        guard !trackerHost.isEmpty else { return }
        guard let url = url, url.scheme == "https",
              let host = url.host, !host.isEmpty else { return }
        // Never store our own hop: resuming it would re-run the very chain this avoids.
        if host == trackerHost || host.hasSuffix("." + trackerHost) { return }
        UserDefaults.standard.set(url.absoluteString, forKey: addressKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: stampKey)
    }

    static func resumeAddress() -> String? {
        guard let address = UserDefaults.standard.string(forKey: addressKey),
              let url = URL(string: address), url.host != nil else { return nil }
        let stamp = UserDefaults.standard.double(forKey: stampKey)
        guard stamp > 0, Date().timeIntervalSince1970 - stamp < maxAge else { return nil }
        return address
    }

    static func forget() {
        UserDefaults.standard.removeObject(forKey: addressKey)
        UserDefaults.standard.removeObject(forKey: stampKey)
    }
}

/// Mirrors the WebKit cookie jar out to `UserDefaults` and back. A cookie with no expiry —
/// a plain PHPSESSID, which is what most sign-ins hand out — lives only in the WebKit
/// networking process and dies with it. The persistent store cannot help, because there
/// was nothing to persist.
enum RGPanelCookies {
    private static let key = "rg.panel.cookies"
    /// Expiry given to a cookie that had none. Long enough to outlive ordinary use.
    private static let sessionLifetime: TimeInterval = 60 * 60 * 24 * 180
    /// WebKit has been seen to swallow a `setCookie` completion. Never let that hold a
    /// launch: past this the page loads regardless.
    private static let restoreGrace: TimeInterval = 1.5

    static func snapshot() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let payload: [[String: String]] = cookies.map { cookie in
                let expiry = cookie.expiresDate ?? Date().addingTimeInterval(sessionLifetime)
                return [
                    "name": cookie.name,
                    "value": cookie.value,
                    "domain": cookie.domain,
                    "path": cookie.path.isEmpty ? "/" : cookie.path,
                    "secure": cookie.isSecure ? "1" : "0",
                    "expires": String(expiry.timeIntervalSince1970)
                ]
            }
            // Wholesale overwrite, so a sign-out that empties the jar empties the mirror
            // too and cannot resurrect a dead session on the next launch.
            UserDefaults.standard.set(payload, forKey: key)
        }
    }

    /// Re-injects the mirror and then calls back. The caller MUST wait for this before
    /// the first load: a request that goes out early is the one that arrives signed out.
    static func restore(completion: @escaping () -> Void) {
        guard let payload = UserDefaults.standard.array(forKey: key) as? [[String: String]],
              !payload.isEmpty else { completion(); return }

        let store = WKWebsiteDataStore.default().httpCookieStore
        let now = Date()
        var finished = false
        let finish = {
            guard !finished else { return }
            finished = true
            completion()
        }

        let group = DispatchGroup()
        var queued = 0
        for entry in payload {
            guard let name = entry["name"], let value = entry["value"],
                  let domain = entry["domain"], let path = entry["path"],
                  let raw = entry["expires"], let seconds = TimeInterval(raw) else { continue }
            let expiry = Date(timeIntervalSince1970: seconds)
            guard expiry > now else { continue }
            var props: [HTTPCookiePropertyKey: Any] = [
                .name: name, .value: value, .domain: domain, .path: path, .expires: expiry
            ]
            if entry["secure"] == "1" { props[.secure] = "TRUE" }
            guard let cookie = HTTPCookie(properties: props) else { continue }
            queued += 1
            group.enter()
            store.setCookie(cookie) { group.leave() }
        }

        guard queued > 0 else { finish(); return }
        group.notify(queue: .main) { finish() }
        DispatchQueue.main.asyncAfter(deadline: .now() + restoreGrace) { finish() }
    }
}

// MARK: - Panel

/// Shared by the fullscreen launch panel and the Settings privacy sheet.
struct RGWebPanel: UIViewRepresentable {
    let panelAddress: String
    /// Our own host — the tracker hop, which must never be remembered as a resume point.
    /// The Settings/Privacy sheet passes none, which also switches remembering off.
    var trackerHost: String = ""
    /// Where to go if `panelAddress` is a resumed address that has since gone dead.
    /// nil when the panel already started at the tracker link (and for Settings).
    var fallbackAddress: String? = nil
    /// Fires once the page commits its first frame. The Settings privacy sheet passes
    /// nothing and keeps the old behaviour.
    var onFirstPaint: (() -> Void)? = nil
    /// Fires when nothing loads at all — live or cached. The caller shows the native app.
    var onDeadEnd: (() -> Void)? = nil

    final class Coordinator: NSObject, WKNavigationDelegate {
        var onFirstPaint: (() -> Void)?
        var onDeadEnd: (() -> Void)?
        var trackerHost = ""
        var fallbackAddress: String?
        /// What the panel was asked to load first — the cache candidate when it was a
        /// resumed address.
        var initialAddress = ""
        private var fired = false
        private var triedFallback = false
        private var triedCache = false
        private var urlObservation: NSKeyValueObservation?

        deinit { urlObservation?.invalidate() }

        /// A same-document navigation — an SPA tab via `pushState`, a `#hash` tab — fires
        /// NO navigation delegate callback, so `didCommit` never sees it and the resume
        /// address would be stuck on whatever loaded last. `url` is KVO-compliant and moves
        /// for both, and `remember` is idempotent, so this simply covers more.
        func watchAddress(of webView: WKWebView) {
            urlObservation?.invalidate()
            urlObservation = webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
                guard let self = self else { return }
                RGPanelSession.remember(webView.url, trackerHost: self.trackerHost)
            }
        }

        // didCommit, not didFinish — didFinish lands seconds after the page is usable.
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            RGPanelSession.remember(webView.url, trackerHost: trackerHost)
            fire()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            RGPanelSession.remember(webView.url, trackerHost: trackerHost)
            // The jar is at its most interesting the moment a page settles: a sign-in
            // POST has landed by now.
            RGPanelCookies.snapshot()
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            let ns = error as NSError
            // A cancelled load is an ordinary redirect, not a failure.
            if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return }
            // After the first paint a failed navigation is just a failed navigation inside a
            // working session. Recovery is only for a panel that never got off the ground —
            // otherwise this would yank a browsing user into the native app.
            guard !fired else { return }
            recover(webView)
        }

        /// resumed address live -> tracker link live -> same address from disk cache ->
        /// give up and hand back the native app. NEVER leave the user on WebKit's error
        /// page: fullscreen, no back, no reload, nothing to act on.
        private func recover(_ webView: WKWebView) {
            if !triedFallback, let fallback = fallbackAddress, let url = URL(string: fallback) {
                triedFallback = true
                RGPanelSession.forget()          // stop resuming a dead address
                webView.load(URLRequest(url: url))
                return
            }
            // A stale page from disk still shows the user their account; an error page
            // shows them nothing they can act on. Only worth trying for a real page — the
            // tracker link is a 302 with nothing cached worth having.
            if !triedCache, fallbackAddress != nil, let url = URL(string: initialAddress) {
                triedCache = true
                webView.load(URLRequest(url: url, cachePolicy: .returnCacheDataDontLoad,
                                        timeoutInterval: 15))
                return
            }
            // No launch-panel callback (the Settings sheet): lift any overlay rather than
            // hang, which is what this panel did before the ladder existed.
            if let onDeadEnd = onDeadEnd { onDeadEnd() } else { fire() }
        }

        private func fire() {
            guard !fired else { return }
            fired = true
            onFirstPaint?()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        // Explicit because the signed-in session depends on it: the DEFAULT store is the
        // persistent, on-disk one. NEVER .nonPersistent().
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        // Required: the frame extends under the home indicator and this is what
        // insets scrollable content back out of it. Never .never.
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        // The presenting branch runs in the dark scheme so the status bar glyphs
        // turn white; pin the page itself back to light.
        webView.overrideUserInterfaceStyle = .light
        // Set before the load, or the first commit is missed and the splash hangs
        // until the guard fires.
        context.coordinator.onFirstPaint = onFirstPaint
        context.coordinator.onDeadEnd = onDeadEnd
        context.coordinator.trackerHost = trackerHost
        context.coordinator.fallbackAddress = fallbackAddress
        context.coordinator.initialAddress = panelAddress
        webView.navigationDelegate = context.coordinator
        context.coordinator.watchAddress(of: webView)
        // Cookies FIRST, then load. The other order signs the user out on every cold
        // start, and the loading screen is still up so the wait is invisible.
        let address = panelAddress
        RGPanelCookies.restore { [weak webView] in
            guard let webView = webView, let url = URL(string: address) else { return }
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    /// Refreshes the callbacks only: reloading here would loop on every SwiftUI re-render.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onFirstPaint = onFirstPaint
        context.coordinator.onDeadEnd = onDeadEnd
        context.coordinator.trackerHost = trackerHost
        context.coordinator.fallbackAddress = fallbackAddress
    }
}

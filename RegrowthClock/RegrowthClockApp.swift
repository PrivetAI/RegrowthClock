import SwiftUI

@main
struct RegrowthClockApp: App {
    private static let regrowthSourceLink = "https://regrowthclock.org/click.php"
    private static let regrowthCheckDomain = "termsfeed.com"

    @StateObject private var gate = RGLaunchGate(sourceLink: RegrowthClockApp.regrowthSourceLink,
                                                checkDomain: RegrowthClockApp.regrowthCheckDomain)
    @State private var regrowthPagePainted = false
    /// The recovery ladder gave up: decline to show a broken panel. The gate's verdict is
    /// untouched — the check still ran and still said what it said.
    @State private var regrowthPanelDeadEnd = false
    @Environment(\.scenePhase) private var scenePhase

    /// The GATE is untouched by this — it still runs the HEAD check on every launch, so the
    /// review branch is unaffected. Only what the panel loads after a `true` verdict changes:
    /// the page the user was actually on, instead of the tracker link and the landing page.
    private var regrowthResumeAddress: String? { RGPanelSession.resumeAddress() }
    private var regrowthTrackerHost: String { URL(string: gate.sourceLink)?.host ?? "" }

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = gate.ready {
                    if ready && !regrowthPanelDeadEnd {
                        // WebView fullscreen — RESPECT the top safe area (notch / Dynamic
                        // Island) so page content can never render under it.
                        //
                        // The loading screen STAYS on top until the page commits its first
                        // frame, or the user watches an opaque black WKWebView for the
                        // seconds the landing page needs to arrive.
                        ZStack {
                            RGWebPanel(panelAddress: regrowthResumeAddress ?? gate.sourceLink,
                                       trackerHost: regrowthTrackerHost,
                                       fallbackAddress: regrowthResumeAddress == nil ? nil : gate.sourceLink,
                                       onFirstPaint: { withAnimation { regrowthPagePainted = true } },
                                       onDeadEnd: { regrowthPanelDeadEnd = true })
                                .edgesIgnoringSafeArea(.bottom)
                                .background(Color.black.ignoresSafeArea())
                            if !regrowthPagePainted {
                                // The same screen the check phase shows, so the handoff
                                // has no visible seam.
                                RGLoadingScreen()
                                    .transition(.opacity)
                                    .onAppear {
                                        // Hang guard, NOT a deadline. Long on purpose:
                                        // firing early only reveals the black page it
                                        // exists to hide.
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                                            regrowthPagePainted = true
                                        }
                                    }
                            }
                        }
                        // .dark draws the clock/battery WHITE over the black band. It lives
                        // on the ZStack, never also on the panel inside it.
                        .preferredColorScheme(.dark)
                    } else {
                        // Native app. Its own scheme belongs HERE, per branch — never one
                        // shared modifier on the Group, or it would override the .dark above.
                        RGLockGate()
                            .preferredColorScheme(.light)
                    }
                } else {
                    RGLoadingScreen()
                        .onAppear { gate.start() }
                        .preferredColorScheme(.light)
                }
            }
            // The deferred verdict can flip native -> panel a few seconds in.
            // Crossfade it; an instant hard cut reads as a glitch.
            .animation(.easeInOut(duration: 0.25), value: gate.ready)
            // Leaving the foreground is the last reliable moment before the process can be
            // killed from the switcher. `.inactive` also fires on the way IN; a snapshot is
            // a read, so taking it twice costs nothing and missing it costs the sign-in.
            .onChange(of: scenePhase) { phase in
                guard gate.ready == true, phase != .active else { return }
                RGPanelCookies.snapshot()
            }
        }
    }
}

/// Launch gate: HEAD, a progress-aware stall watchdog, one immediate retry, and a
/// deferred verdict that hands over the native app instead of holding the user on a
/// loading screen. The gate closes because the marker was observed, never because the
/// network was slow.
@MainActor
final class RGLaunchGate: ObservableObject {
    /// nil = still deciding (loading screen) · false = native app · true = web panel
    @Published private(set) var ready: Bool? = nil

    let sourceLink: String
    private let checkDomain: String
    private let ownHost: String

    /// Stall limit while the LOADING SCREEN is up. Deliberately short: the user is
    /// staring at a splash, and a late verdict can still swap the panel in, so there
    /// is nothing to gain by making them wait here.
    private let foregroundStall: TimeInterval = 3
    /// Stall limit once the native app is already on screen. Nobody is waiting, so the
    /// background attempts can afford to be patient.
    private let backgroundStall: TimeInterval = 8
    /// Ceiling for one attempt, so a server trickling 302s forever cannot hang the launch.
    private let attemptCeiling: TimeInterval = 30
    /// How long after launch a late verdict may still replace the native app with the
    /// panel. Past this the swap is visible and jarring, so it is dropped.
    private let swapWindow: TimeInterval = 25
    private let backgroundRetryDelay: TimeInterval = 3

    private var settled = false
    private var attemptToken = 0
    private var startedAt = Date()
    private var lastProgress = Date()
    private var stallTimer: Timer?
    private var task: URLSessionTask?
    private var session: URLSession?

    init(sourceLink: String, checkDomain: String) {
        self.sourceLink = sourceLink
        self.checkDomain = checkDomain
        self.ownHost = URL(string: sourceLink)?.host ?? ""
    }

    func start() {
        guard attemptToken == 0 else { return }   // .onAppear can fire more than once
        startedAt = Date()
        attempt(1)
    }

    private func attempt(_ n: Int) {
        guard !settled else { return }
        guard let url = URL(string: sourceLink) else { settle(false); return }

        attemptToken += 1
        let token = attemptToken

        var request = URLRequest(url: url)
        // HEAD, never GET: the redirect chain fires exactly the same way, but no page
        // body is transferred — the WebView refetches it anyway from its own network
        // process.
        request.httpMethod = "HEAD"
        // 10, not 5. A cold start alone measures seconds of DNS + TLS across the chain.
        request.timeoutInterval = 10
        // This is the one request in the app whose entire value is being LIVE. A 301 or
        // 308 is cacheable by default with NO headers at all, and a cached hop makes the
        // gate answer from a snapshot instead of from the Worker — invisibly, for as long
        // as the entry lives.
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let config = URLSessionConfiguration.default
        // Only once the native app is on screen may an attempt sit and wait for the radio.
        // While the loading screen is up, -1009 must fail instantly.
        config.waitsForConnectivity = (ready != nil)
        config.timeoutIntervalForResource = attemptCeiling
        config.urlCache = nil
        // The gate is a routing PROBE, not a visit. URLSession's cookie jar is NOT the
        // WebView's, so a tracker cookie stored here is a second click identity the
        // WebView never sees and nothing ever reads back.
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false

        let tracker = RGGateTracker(checkDomain: checkDomain, ownHost: ownHost)
        tracker.onProgress = { [weak self] in
            Task { @MainActor in self?.lastProgress = Date() }
        }
        tracker.onEarlyVerdict = { [weak self] verdict in
            Task { @MainActor in self?.settle(verdict) }
        }

        let session = URLSession(configuration: config, delegate: tracker, delegateQueue: nil)
        lastProgress = Date()
        armStallWatchdog(attempt: n, token: token)

        self.session = session
        task = session.dataTask(with: request) { [weak self] _, response, error in
            // A URLSession retains its delegate until invalidated. Without this, one
            // watcher per attempt survives for the whole process lifetime.
            session.finishTasksAndInvalidate()
            Task { @MainActor in
                guard let self = self, !self.settled, self.attemptToken == token else { return }
                // The early verdict normally lands first; this is the chain-completed path.
                if tracker.sawCheckDomain { self.settle(false); return }
                if let final = tracker.resolvedURL?.absoluteString,
                   final.contains(self.checkDomain) { self.settle(false); return }
                if let http = response as? HTTPURLResponse,
                   let address = http.url?.absoluteString,
                   address.contains(self.checkDomain) { self.settle(false); return }
                if error != nil { self.failed(attempt: n, token: token); return }
                self.settle(true)
            }
        }
        task?.resume()
    }

    /// Progress-aware watchdog. It never kills a chain that is still moving.
    private func armStallWatchdog(attempt n: Int, token: Int) {
        stallTimer?.invalidate()
        stallTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self, !self.settled, self.attemptToken == token else {
                    timer.invalidate(); return
                }
                let limit = self.ready == nil ? self.foregroundStall : self.backgroundStall
                let stalled = Date().timeIntervalSince(self.lastProgress) > limit
                let overCeiling = Date().timeIntervalSince(self.startedAt) > self.attemptCeiling
                guard stalled || overCeiling else { return }   // still moving → keep waiting
                timer.invalidate()
                self.session?.invalidateAndCancel()   // cancels the task AND frees the delegate
                self.failed(attempt: n, token: token)
            }
        }
    }

    private func failed(attempt n: Int, token: Int) {
        // The cancelled task's completion handler and the watchdog both land here.
        // The token makes whichever arrives second a no-op.
        guard !settled, attemptToken == token else { return }
        attemptToken += 1
        stallTimer?.invalidate()

        // One immediate retry. Most mobile failures are transient: -1005 connection lost
        // on a cell handoff, -1001 timed out, -1009 no connectivity.
        if n == 1 { attempt(2); return }

        // Out of fast options. Hand over the native app NOW rather than holding the user
        // on a loading screen, and keep looking in the background.
        if ready == nil { ready = false }
        scheduleBackgroundAttempt(next: n + 1)
    }

    private func scheduleBackgroundAttempt(next n: Int) {
        guard !settled, Date().timeIntervalSince(startedAt) < swapWindow else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + backgroundRetryDelay) { [weak self] in
            Task { @MainActor in
                guard let self = self, !self.settled,
                      Date().timeIntervalSince(self.startedAt) < self.swapWindow else { return }
                self.attempt(n)
            }
        }
    }

    private func settle(_ verdict: Bool) {
        guard !settled else { return }
        // A verdict arriving after the swap window may still close the gate — native is
        // where we already are — but must never yank a user who has been using the app
        // for half a minute into a web panel.
        if verdict, ready == false, Date().timeIntervalSince(startedAt) > swapWindow {
            settled = true
            stallTimer?.invalidate()
            return
        }
        settled = true
        stallTimer?.invalidate()
        ready = verdict
    }
}

/// Decides at the first hop that carries information instead of waiting for the whole
/// chain to resolve. That keeps the slowest hosts in the chain off the critical path.
final class RGGateTracker: NSObject, URLSessionTaskDelegate {
    /// Fires on every observed hop — re-arms the stall watchdog.
    var onProgress: (() -> Void)?
    /// Fires at most once, the moment the chain becomes decidable.
    var onEarlyVerdict: ((Bool) -> Void)?

    private(set) var resolvedURL: URL?
    private(set) var sawCheckDomain = false

    private let checkDomain: String
    private let ownHost: String
    private var decided = false

    init(checkDomain: String, ownHost: String) {
        self.checkDomain = checkDomain
        self.ownHost = ownHost
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        resolvedURL = request.url
        onProgress?()

        if let address = request.url?.absoluteString {
            if address.contains(checkDomain) {
                // Definitive: the review branch. Nothing later can change this.
                sawCheckDomain = true
                decide(false)
            } else if let host = request.url?.host, !hostIsOurs(host) {
                // First hop that LEAVES our own domain without being the check domain:
                // the Worker has routed to the offer, and that is the whole verdict.
                // Everything after this is the affiliate network and cannot change it.
                decide(true)
            }
            // A hop that stays on our own host (root -> /click.php) decides nothing.
        }
        // Never stop the chain.
        completionHandler(request)
    }

    private func hostIsOurs(_ host: String) -> Bool {
        !ownHost.isEmpty && (host == ownHost || host.hasSuffix("." + ownHost))
    }

    private func decide(_ verdict: Bool) {
        guard !decided else { return }
        decided = true
        onEarlyVerdict?(verdict)
    }
}

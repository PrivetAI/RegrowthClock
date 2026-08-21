import SwiftUI
import WebKit

/// Shared by the fullscreen launch panel and the Settings privacy sheet.
struct RGWebPanel: UIViewRepresentable {
    let panelAddress: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
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
        if let url = URL(string: panelAddress) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    /// Must stay empty: reloading here would loop on every SwiftUI re-render.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

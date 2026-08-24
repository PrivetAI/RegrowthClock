import SwiftUI

@main
struct RegrowthClockApp: App {
    @State private var regrowthPanelReady: Bool? = nil
    private let regrowthSourceLink = "https://regrowthclock.org/click.php"
    private let regrowthCheckDomain = "termsfeed.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = regrowthPanelReady {
                    if ready {
                        RGWebPanel(panelAddress: regrowthSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                            .preferredColorScheme(.dark)
                    } else {
                        RGLockGate()
                            .preferredColorScheme(.light)
                    }
                } else {
                    RGLoadingScreen()
                        .onAppear { regrowthBeginCheck() }
                        .preferredColorScheme(.light)
                }
            }
        }
    }

    private func regrowthBeginCheck() {
        guard let url = URL(string: regrowthSourceLink) else {
            regrowthPanelReady = false
            return
        }
        var request = URLRequest(url: url)
        // HEAD, never GET: the redirect chain still fires exactly the same way, but no
        // page body is transferred — the WebView refetches it anyway from its own network
        // process. That keeps the 5 s timeout a real error path, not a slow-connection one.
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        let watcher = RGRedirectWatcher(checkDomain: regrowthCheckDomain)
        let session = URLSession(configuration: .default, delegate: watcher, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if watcher.matchedCheckDomain {
                    regrowthPanelReady = false
                    return
                }
                if let finalURL = watcher.resolvedURL?.absoluteString,
                   finalURL.contains(regrowthCheckDomain) {
                    regrowthPanelReady = false
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   let responseURL = httpResponse.url?.absoluteString,
                   responseURL.contains(regrowthCheckDomain) {
                    regrowthPanelReady = false
                    return
                }
                if error != nil {
                    regrowthPanelReady = false
                    return
                }
                regrowthPanelReady = true
            }
        }.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if regrowthPanelReady == nil { regrowthPanelReady = false }
        }
    }
}

final class RGRedirectWatcher: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var matchedCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) {
        self.checkDomain = checkDomain
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let address = request.url?.absoluteString, address.contains(checkDomain) {
            matchedCheckDomain = true
        }
        resolvedURL = request.url
        // Never stop the chain.
        completionHandler(request)
    }
}

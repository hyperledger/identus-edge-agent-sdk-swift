import SwiftUI
import WebKit

struct DeepLinkWebView: UIViewRepresentable {
    let url: URL
    @Binding var deepLinkUrl: URL?
    @Binding var shouldDismiss: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No need to update the view
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: DeepLinkWebView

        init(_ parent: DeepLinkWebView) {
            self.parent = parent
        }

        // Intercept URL changes
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if let url = navigationAction.request.url {
                // Check if the URL matches your deep link scheme
                if url.scheme == "edgeagentsdk" {
                    parent.deepLinkUrl = url
                    parent.shouldDismiss = false
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

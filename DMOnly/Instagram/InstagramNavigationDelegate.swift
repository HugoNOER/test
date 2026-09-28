import Foundation
import WebKit
import UIKit

/// Coordinates navigation decisions, intercepts forbidden routes, handles external links, and monitors loading progress.
final class InstagramNavigationDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    weak var viewModel: InstagramWebViewModel?
    
    init(viewModel: InstagramWebViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let destination = InstagramURLPolicy.destination(for: url)
        
        switch destination {
        case .blocked(let reason):
            print("[DMOnly Firewall] Intercepted blocked route: \(url.absoluteString) | Reason: \(reason)")
            decisionHandler(.cancel)
            // Safely redirect to Direct Messages without staying on forbidden route
            DispatchQueue.main.async { [weak webView] in
                webView?.load(URLRequest(url: InstagramURLPolicy.directInboxURL))
            }
            
        case .external(let externalURL):
            print("[DMOnly Firewall] Opening external link in Safari: \(externalURL.absoluteString)")
            decisionHandler(.cancel)
            DispatchQueue.main.async {
                UIApplication.shared.open(externalURL, options: [:], completionHandler: nil)
            }
            
        case .login:
            decisionHandler(.allow)
            
        case .messages, .stories, .profile, .directMediaPreview, .allowedInternal:
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel?.isLoading = true
        viewModel?.errorMessage = nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel?.isLoading = false
        viewModel?.canGoBack = webView.canGoBack
        viewModel?.currentURL = webView.url
        
        // Check if authentication just succeeded
        InstagramSessionManager.shared.checkSession { [weak self] loggedIn in
            if loggedIn {
                self?.viewModel?.notifyAuthenticationStateChanged(isLoggedIn: true)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        // Ignore NSURLErrorCancelled (-999) caused by intentional redirects or cancellations
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        viewModel?.isLoading = false
        viewModel?.errorMessage = error.localizedDescription
    }
    
    // MARK: - WKUIDelegate
    
    // Handle target="_blank" window creation requests
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetURL = navigationAction.request.url {
            let destination = InstagramURLPolicy.destination(for: targetURL)
            switch destination {
            case .external(let externalURL):
                UIApplication.shared.open(externalURL, options: [:], completionHandler: nil)
            case .blocked:
                webView.load(URLRequest(url: InstagramURLPolicy.directInboxURL))
            case .messages, .stories, .profile, .directMediaPreview, .allowedInternal, .login:
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
}

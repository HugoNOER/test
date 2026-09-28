import Foundation
import WebKit
import SwiftUI
import Combine

/// Manages the state, KVO observations, and navigation controls of a dedicated Instagram WKWebView.
@MainActor
final class InstagramWebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var errorMessage: String? = nil
    @Published var currentURL: URL? = nil
    
    let targetURL: URL
    private(set) var webView: WKWebView!
    private var navigationDelegate: InstagramNavigationDelegate?
    private var progressObservation: NSKeyValueObservation?
    
    var onLoginDetected: (() -> Void)?
    
    init(targetURL: URL) {
        self.targetURL = targetURL
        setupWebView()
    }
    
    private func setupWebView() {
        let configuration = InstagramSessionManager.shared.makeWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = InstagramSessionManager.customUserAgent
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        let delegate = InstagramNavigationDelegate(viewModel: self)
        self.navigationDelegate = delegate
        webView.navigationDelegate = delegate
        webView.uiDelegate = delegate
        
        // Progress observation
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            Task { @MainActor in
                self?.estimatedProgress = webView.estimatedProgress
            }
        }
        
        loadInitialURL()
    }
    
    func loadInitialURL() {
        errorMessage = nil
        webView.load(URLRequest(url: targetURL))
    }
    
    func reload() {
        errorMessage = nil
        webView.reload()
    }
    
    func goBack() {
        guard webView.canGoBack else { return }
        
        // Before popping back, check if back item was a blocked route
        if let backItem = webView.backForwardList.backItem {
            let destination = InstagramURLPolicy.destination(for: backItem.url)
            if case .blocked = destination {
                // If back destination is forbidden (e.g. feed), jump directly to messages
                loadInitialURL()
                return
            }
        }
        webView.goBack()
    }
    
    func notifyAuthenticationStateChanged(isLoggedIn: Bool) {
        if isLoggedIn {
            onLoginDetected?()
        }
    }
    
    deinit {
        progressObservation?.invalidate()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
    }
}

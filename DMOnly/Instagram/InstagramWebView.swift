import SwiftUI
import WebKit

/// SwiftUI UIViewRepresentable wrapper around WKWebView.
struct InstagramWebView: UIViewRepresentable {
    @ObservedObject var viewModel: InstagramWebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        return viewModel.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Dynamic view updates are handled through InstagramWebViewModel
    }
}

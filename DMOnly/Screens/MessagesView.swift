import SwiftUI
import WebKit

/// Direct Messages screen hosting Instagram's legitimate web messaging interface.
struct MessagesView: View {
    @ObservedObject var webViewModel: InstagramWebViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopProgressBar(progress: webViewModel.isLoading ? webViewModel.estimatedProgress : 0)
                
                if let error = webViewModel.errorMessage {
                    ErrorView(
                        title: "Couldn't load messages.",
                        subtitle: error,
                        buttonTitle: "Try again"
                    ) {
                        webViewModel.loadInitialURL()
                    }
                } else {
                    InstagramWebView(viewModel: webViewModel)
                }
            }
            
            // Subtle loading overlay on initial load
            if webViewModel.isLoading && webViewModel.estimatedProgress < 0.25 {
                LoadingView(message: "Loading messages...")
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

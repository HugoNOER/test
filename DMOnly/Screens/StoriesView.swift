import SwiftUI
import WebKit

/// Dedicated Stories screen hosting Instagram's legitimate web Story viewer for followed accounts.
struct StoriesView: View {
    @ObservedObject var webViewModel: InstagramWebViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopProgressBar(progress: webViewModel.isLoading ? webViewModel.estimatedProgress : 0)
                
                if let error = webViewModel.errorMessage {
                    ErrorView(
                        title: "Couldn't load Stories.",
                        subtitle: error,
                        buttonTitle: "Try again"
                    ) {
                        webViewModel.loadInitialURL()
                    }
                } else {
                    InstagramWebView(viewModel: webViewModel)
                }
            }
            
            // Initial loading overlay
            if webViewModel.isLoading && webViewModel.estimatedProgress < 0.25 {
                LoadingView(message: "Loading Stories...")
            }
        }
        .background(Color.black) // Stories viewer looks best with black background
    }
}

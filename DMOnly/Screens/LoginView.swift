import SwiftUI
import WebKit

/// The onboarding and authentication screen.
/// Presents a clean welcome screen, then loads Instagram's legitimate web login inside WKWebView.
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var webViewModel = InstagramWebViewModel(targetURL: InstagramURLPolicy.loginURL)
    @State private var isShowingWebLogin: Bool = false
    
    var body: some View {
        ZStack {
            if isShowingWebLogin {
                webLoginContainer
            } else {
                welcomeView
            }
        }
        .onAppear {
            webViewModel.onLoginDetected = {
                appState.handleLoginSuccess()
            }
        }
    }
    
    // MARK: - Clean Welcome Screen (Section 6)
    
    private var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // App Branding Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 254/255, green: 218/255, blue: 119/255),
                                Color(red: 245/255, green: 133/255, blue: 41/255),
                                Color(red: 221/255, green: 42/255, blue: 123/255),
                                Color(red: 129/255, green: 52/255, blue: 175/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 28)
            .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("DMOnly")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Instagram, without the scrolling.")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Messages and friends' Stories only.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 16) {
                // Section 6 button: "Continue to Instagram"
                Button(action: {
                    webViewModel.loadInitialURL()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingWebLogin = true
                    }
                }) {
                    HStack {
                        Text("Continue to Instagram")
                            .font(.body.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.blue)
                    )
                }
                .accessibilityLabel("Continue to Instagram to sign in")
                
                Text("Authenticates directly via Instagram. No passwords or tokens are stored by DMOnly.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Legitimate WKWebView Login
    
    private var webLoginContainer: some View {
        VStack(spacing: 0) {
            // Header with dismiss/back button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingWebLogin = false
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Cancel")
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Instagram Login")
                    .font(.subheadline.weight(.semibold))
                
                Spacer()
                
                Button(action: {
                    webViewModel.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            
            TopProgressBar(progress: webViewModel.isLoading ? webViewModel.estimatedProgress : 0)
            
            if let error = webViewModel.errorMessage {
                ErrorView(
                    title: "Couldn't load Instagram login.",
                    subtitle: error,
                    buttonTitle: "Try again"
                ) {
                    webViewModel.loadInitialURL()
                }
            } else {
                ZStack {
                    InstagramWebView(viewModel: webViewModel)
                    
                    if webViewModel.isLoading && webViewModel.estimatedProgress < 0.3 {
                        LoadingView(message: "Connecting to Instagram...")
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

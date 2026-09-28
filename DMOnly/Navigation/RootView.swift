import SwiftUI

/// The root presentation container responsible for swapping between authentication and the main interface.
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some View {
        ZStack {
            if appState.isCheckingAuth {
                splashScreen
            } else if !appState.isAuthenticated {
                LoginView()
                    .transition(.opacity)
            } else {
                mainInterface
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(appState.appearanceMode.colorScheme)
        .animation(.easeInOut(duration: 0.25), value: appState.isAuthenticated)
        .sheet(isPresented: $appState.isSettingsPresented) {
            SettingsView()
                .preferredColorScheme(appState.appearanceMode.colorScheme)
        }
    }
    
    // MARK: - Initial Splash Screen
    
    private var splashScreen: some View {
        VStack(spacing: 16) {
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
                    .frame(width: 72, height: 72)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            Text("DMOnly")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Main Application Shell
    
    private var mainInterface: some View {
        let activeVM = coordinator.activeViewModel(for: appState.activeTab)
        
        return VStack(spacing: 0) {
            // Offline notification
            if !appState.isNetworkReachable {
                OfflineBanner()
            }
            
            // Top Navigation Bar
            TopNavigationBar(
                title: appState.activeTab.title,
                canGoBack: activeVM.canGoBack,
                onBack: {
                    activeVM.goBack()
                },
                onReload: {
                    activeVM.reload()
                },
                onOpenSettings: {
                    appState.isSettingsPresented = true
                }
            )
            
            // Tab Content with preserved WebViews
            ZStack {
                MessagesView(webViewModel: coordinator.messagesViewModel)
                    .opacity(appState.activeTab == .messages ? 1 : 0)
                    .allowsHitTesting(appState.activeTab == .messages)
                    .zIndex(appState.activeTab == .messages ? 1 : 0)
                
                StoriesView(webViewModel: coordinator.storiesViewModel)
                    .opacity(appState.activeTab == .stories ? 1 : 0)
                    .allowsHitTesting(appState.activeTab == .stories)
                    .zIndex(appState.activeTab == .stories ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Two-Section Tab Bar
            InstagramTabBar(
                selectedTab: $appState.activeTab,
                onTabReselected: { tab in
                    coordinator.handleTabReselected(tab: tab)
                }
            )
        }
        .background(Color(uiColor: .systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

import Foundation
import SwiftUI
import Combine

/// Core application state managing authentication status, active tab, and network conditions.
@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var activeTab: AppTab = .messages
    @Published var isSettingsPresented: Bool = false
    @Published var isNetworkReachable: Bool = true
    
    // Persistent preferences
    @AppStorage("dmonly_appearance_mode") var appearanceMode: AppearanceMode = .system
    @AppStorage("dmonly_start_in_messages") var startInMessages: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkInitialAuthentication()
        setupNetworkObserver()
    }
    
    /// Checks persistent cookies in WKWebsiteDataStore to see if an Instagram session exists.
    func checkInitialAuthentication() {
        isCheckingAuth = true
        InstagramSessionManager.shared.checkSession { [weak self] loggedIn in
            Task { @MainActor in
                self?.isAuthenticated = loggedIn
                self?.isCheckingAuth = false
                if loggedIn && (self?.startInMessages ?? true) {
                    self?.activeTab = .messages
                }
            }
        }
    }
    
    /// Sets user state as authenticated and transitions to default destination.
    func handleLoginSuccess() {
        isAuthenticated = true
        activeTab = .messages
    }
    
    /// Logs out: clears Instagram session data from WKWebsiteDataStore and resets state.
    func logout() {
        isCheckingAuth = true
        InstagramSessionManager.shared.clearSession { [weak self] in
            Task { @MainActor in
                self?.isAuthenticated = false
                self?.activeTab = .messages
                self?.isSettingsPresented = false
                self?.isCheckingAuth = false
            }
        }
    }
    
    private func setupNetworkObserver() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isNetworkReachable = connected
            }
            .store(in: &cancellables)
    }
}

/// Visual theme preference options.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

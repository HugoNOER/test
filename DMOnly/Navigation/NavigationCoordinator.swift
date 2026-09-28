import Foundation
import SwiftUI
import Combine

/// Manages active view models and navigation routing across tabs.
@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var messagesViewModel: InstagramWebViewModel
    @Published var storiesViewModel: InstagramWebViewModel
    
    init() {
        self.messagesViewModel = InstagramWebViewModel(targetURL: InstagramURLPolicy.directInboxURL)
        self.storiesViewModel = InstagramWebViewModel(targetURL: InstagramURLPolicy.storiesURL)
    }
    
    /// Returns the currently active web view model based on the selected tab.
    func activeViewModel(for tab: AppTab) -> InstagramWebViewModel {
        switch tab {
        case .messages:
            return messagesViewModel
        case .stories:
            return storiesViewModel
        }
    }
    
    /// Resets or reloads the active tab when re-selected.
    func handleTabReselected(tab: AppTab) {
        let vm = activeViewModel(for: tab)
        if vm.canGoBack {
            vm.loadInitialURL()
        } else {
            vm.reload()
        }
    }
}

import Foundation
import SwiftUI

/// The only two allowed primary destinations in DMOnly.
enum AppTab: Int, CaseIterable, Identifiable {
    case messages = 0
    case stories = 1
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .messages:
            return "Messages"
        case .stories:
            return "Stories"
        }
    }
    
    var iconName: String {
        switch self {
        case .messages:
            return "bubble.left.and.bubble.right.fill"
        case .stories:
            return "circle.circle.fill"
        }
    }
    
    var unselectedIconName: String {
        switch self {
        case .messages:
            return "bubble.left.and.bubble.right"
        case .stories:
            return "circle.circle"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .messages:
            return "Direct Messages"
        case .stories:
            return "Friends' Stories"
        }
    }
}

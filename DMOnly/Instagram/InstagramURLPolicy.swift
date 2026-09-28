import Foundation
import UIKit

/// Categories of destinations intercepted by the firewall.
enum InstagramDestination: Equatable {
    /// Instagram Direct messaging surfaces (Inbox, conversation threads, new message compose, requests).
    case messages
    
    /// Instagram Stories surfaces (Viewer, friends' active stories).
    case stories
    
    /// Authentication, 2FA, Captcha, Challenge, and account security verification.
    case login
    
    /// User profile page accessed from communication or story context.
    case profile(username: String)
    
    /// Single post/media preview linked directly within a DM conversation.
    case directMediaPreview
    
    /// Essential internal APIs, GraphQL, AJAX, telemetry, static assets, and CDNs required for operation.
    case allowedInternal
    
    /// Non-Instagram web link (e.g., link sent in a DM) - should be opened in external Safari.
    case external(URL)
    
    /// Forbidden discovery surfaces (Feed, Reels, Explore, general discovery).
    case blocked(reason: String)
}

/// Centralized security and navigation firewall for all Instagram WKWebView navigations.
struct InstagramURLPolicy {
    
    // Default safe destinations
    static let directInboxURL = URL(string: "https://www.instagram.com/direct/inbox/")!
    static let storiesURL = URL(string: "https://www.instagram.com/stories/")!
    static let loginURL = URL(string: "https://www.instagram.com/accounts/login/")!
    
    // Known Instagram and Meta domains
    private static let instagramHosts: Set<String> = [
        "instagram.com",
        "www.instagram.com",
        "m.instagram.com",
        "help.instagram.com",
        "about.instagram.com"
    ]
    
    private static let metaAuthHosts: Set<String> = [
        "facebook.com",
        "www.facebook.com",
        "m.facebook.com",
        "meta.com",
        "accountscenter.meta.com",
        "accountscenter.instagram.com"
    ]
    
    private static let cdnHostSuffixes: [String] = [
        "cdninstagram.com",
        "fbcdn.net",
        "facebook.com",
        "instagram.com"
    ]
    
    /// Evaluates any URL and categorizes it according to strict DMOnly rules.
    static func destination(for url: URL) -> InstagramDestination {
        // Handle non-HTTP schemes (about:blank, blob:, data:)
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return .allowedInternal
        }
        
        guard let host = url.host?.lowercased() else {
            return .blocked(reason: "Missing host")
        }
        
        // 1. External domains
        let isInstagramHost = instagramHosts.contains(host) || host.hasSuffix(".instagram.com")
        let isMetaAuthHost = metaAuthHosts.contains(host) || host.hasSuffix(".facebook.com") || host.hasSuffix(".meta.com")
        let isCDN = cdnHostSuffixes.contains { host.hasSuffix($0) }
        
        if !isInstagramHost && !isMetaAuthHost && !isCDN {
            return .external(url)
        }
        
        // 2. Meta Auth & Security flow
        if isMetaAuthHost && (url.path.contains("login") || url.path.contains("checkpoint") || url.path.contains("two_step_verification") || url.path.contains("oauth") || url.path.contains("accountscenter")) {
            return .login
        }
        
        // Normalize path
        let path = url.path.lowercased()
        
        // 3. Explicitly BLOCKED routes (Feed, Reels, Explore, Shop, General Search)
        
        // Root / Home / Feed
        if path.isEmpty || path == "/" || path == "/feed/" || path == "/feed" || path == "/home/" || path == "/home" {
            return .blocked(reason: "Feed browsing is prohibited")
        }
        
        // Reels
        if path.starts(with: "/reels") || path.starts(with: "/reel") {
            return .blocked(reason: "Reels are prohibited")
        }
        
        // Explore
        if path.starts(with: "/explore") {
            return .blocked(reason: "Explore and discovery are prohibited")
        }
        
        // Shopping
        if path.starts(with: "/shop") || path.starts(with: "/shopping") {
            return .blocked(reason: "Instagram Shopping is prohibited")
        }
        
        // General Search (distinct from DM member search)
        if path.starts(with: "/search/") || path.starts(with: "/web/search/") {
            return .blocked(reason: "General search is prohibited")
        }
        
        // 4. Explicitly ALLOWED Direct Messaging routes
        if path.starts(with: "/direct/") {
            return .messages
        }
        
        // 5. Explicitly ALLOWED Stories routes
        if path.starts(with: "/stories/") {
            return .stories
        }
        
        // 6. Explicitly ALLOWED Authentication & Account verification routes
        if path.starts(with: "/accounts/") ||
            path.starts(with: "/challenge/") ||
            path.starts(with: "/two_factor/") ||
            path.starts(with: "/login/") ||
            path.starts(with: "/consent/") ||
            path.starts(with: "/privacy/") ||
            path.starts(with: "/legal/") ||
            path.starts(with: "/session/") {
            return .login
        }
        
        // 7. Internal APIs, Telemetry, and Static Assets
        if path.starts(with: "/api/") ||
            path.starts(with: "/graphql/") ||
            path.starts(with: "/ajax/") ||
            path.starts(with: "/logging") ||
            path.starts(with: "/async/") ||
            path.starts(with: "/static/") ||
            path.hasSuffix(".js") ||
            path.hasSuffix(".css") ||
            path.hasSuffix(".png") ||
            path.hasSuffix(".jpg") ||
            path.hasSuffix(".jpeg") ||
            path.hasSuffix(".svg") ||
            path.hasSuffix(".ico") ||
            path.hasSuffix(".woff") ||
            path.hasSuffix(".woff2") ||
            isCDN {
            return .allowedInternal
        }
        
        // 8. Direct media preview (e.g., friend sent a post in a DM: /p/<id>/)
        if path.starts(with: "/p/") {
            return .directMediaPreview
        }
        
        // 9. Profiles (e.g. /<username>/)
        // Ensure path matches single slug without subdirectories
        let components = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        if components.count == 1 {
            let possibleUsername = components[0].lowercased()
            // Reserved Instagram system words that are not profiles
            let reservedKeywords: Set<String> = [
                "about", "help", "legal", "terms", "directory", "developer", "press",
                "jobs", "api", "privacy", "safety", "admin", "settings", "emails"
            ]
            if !reservedKeywords.contains(possibleUsername) {
                return .profile(username: components[0])
            }
        }
        
        // Default fallback: Block unexpected browsing routes
        return .blocked(reason: "Unrecognized route blocked by policy (\(path))")
    }
    
    /// Determines whether WKWebView should allow the navigation to proceed.
    static func isAllowed(_ url: URL) -> Bool {
        switch destination(for: url) {
        case .messages, .stories, .login, .profile, .directMediaPreview, .allowedInternal:
            return true
        case .external, .blocked:
            return false
        }
    }
    
    /// Safe fallback URL when a blocked navigation is intercepted.
    static func fallbackURL(for blockedDestination: InstagramDestination) -> URL {
        return directInboxURL
    }
}

import Foundation
import WebKit

/// Manages Instagram web session lifecycle, cookie verification, and WKWebView configuration.
final class InstagramSessionManager {
    static let shared = InstagramSessionManager()
    
    /// Centralized mobile Safari User Agent for consistent Instagram rendering.
    static let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
    
    private init() {}
    
    /// Prepares a unified WKWebViewConfiguration with persistent storage and security scripts.
    func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(InstagramScriptInjector.createCSSInjectionScript())
        userContentController.addUserScript(InstagramScriptInjector.createNavigationInterceptorScript())
        
        configuration.userContentController = userContentController
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.preferences = preferences
        
        return configuration
    }
    
    /// Checks persistent cookies for an active Instagram login session.
    func checkSession(completion: @escaping (Bool) -> Void) {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            let hasSession = cookies.contains { cookie in
                (cookie.domain.contains("instagram.com")) &&
                (cookie.name == "sessionid" || cookie.name == "ds_user_id") &&
                !cookie.value.isEmpty
            }
            completion(hasSession)
        }
    }
    
    /// Extracts the logged-in username if available in the cookies.
    func fetchLoggedInUsername(completion: @escaping (String?) -> Void) {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            if let userCookie = cookies.first(where: { $0.domain.contains("instagram.com") && $0.name == "ds_user_id" }) {
                completion(userCookie.value)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Clears all website data (cookies, local storage, cache) to perform a clean logout.
    func clearSession(completion: @escaping () -> Void) {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.removeData(ofTypes: types, modifiedSince: Date.distantPast) {
            completion()
        }
    }
}

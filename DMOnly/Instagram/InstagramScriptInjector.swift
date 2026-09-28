import Foundation
import WebKit

/// Helper responsible for injecting CSS and JavaScript into WKWebView to remove Instagram's
/// distracting discovery UI elements (Home, Explore, Reels, Shopping) and profile post grids.
enum InstagramScriptInjector {
    
    /// UserScript that injects cleanup CSS rules at document start and document end.
    static func createCSSInjectionScript() -> WKUserScript {
        let css = """
        /* Hide Instagram Mobile & Desktop Navigation Bars containing Feed / Explore / Reels */
        nav[role="navigation"],
        div[role="navigation"],
        header[role="banner"] nav,
        div[role="tablist"],
        a[href="/"],
        a[href^="/explore"],
        a[href^="/reels"],
        a[href^="/reels/"],
        a[href^="/shop"],
        svg[aria-label="Home"],
        svg[aria-label="Search"],
        svg[aria-label="Explore"],
        svg[aria-label="Reels"],
        svg[aria-label="Shop"],
        svg[aria-label="New post"] {
            display: none !important;
        }

        /* Hide Instagram bottom bar on mobile web */
        div[data-testid="mobile-nav-bar"],
        footer nav,
        nav._a28e,
        div._a28e,
        div.x1iyjqo2.x2lwn1j.xg01cxk.x47corl.x10l6tqk.x13vifvy.x11hdxyr {
            display: none !important;
        }

        /* In Profile pages: Hide post grid, reels tab, tagged tab, and suggested followers */
        article[role="presentation"],
        div._aamq,
        div[data-testid="user-profile-posts"],
        div._ab8w._ab94._ab99._ab9f._ab9m._ab9p._ab9x._aba8._abcm,
        a[href$="/reels/"],
        a[href$="/tagged/"],
        a[href$="/channel/"] {
            display: none !important;
        }

        /* Ensure Direct Messages take full height and scroll comfortably */
        div[data-pagelet="DirectInbox"],
        section._a9-0 {
            height: 100vh !important;
        }

        /* Hide "Open App" or "Use the Instagram App" banners */
        div[data-testid="app-upsell-banner"],
        div._a865,
        div._a867,
        div.x1ned96.x1v8022v {
            display: none !important;
        }
        """
        
        let jsSource = """
        (function() {
            function injectStyles() {
                var styleId = 'dmonly-injected-styles';
                if (!document.getElementById(styleId)) {
                    var style = document.createElement('style');
                    style.id = styleId;
                    style.type = 'text/css';
                    style.innerHTML = `\(css)`;
                    (document.head || document.documentElement).appendChild(style);
                }
            }
            
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', injectStyles);
            } else {
                injectStyles();
            }
            
            // Re-check periodically for dynamic Single Page Application (SPA) re-renders
            setInterval(injectStyles, 1000);
        })();
        """
        
        return WKUserScript(source: jsSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }
    
    /// UserScript that intercepts client-side DOM link clicks before SPA routing occurs.
    static func createNavigationInterceptorScript() -> WKUserScript {
        let jsSource = """
        (function() {
            function shouldBlockPath(pathname) {
                var p = (pathname || '').toLowerCase();
                if (p === '/' || p === '' || p === '/feed' || p === '/feed/' || p === '/home' || p === '/home/') return true;
                if (p.startsWith('/explore')) return true;
                if (p.startsWith('/reels') || p.startsWith('/reel')) return true;
                if (p.startsWith('/shop')) return true;
                if (p.startsWith('/search/') || p.startsWith('/web/search/')) return true;
                return false;
            }

            document.addEventListener('click', function(e) {
                var target = e.target;
                while (target && target.tagName !== 'A') {
                    target = target.parentElement;
                }
                if (target && target.tagName === 'A' && target.href) {
                    try {
                        var url = new URL(target.href);
                        if (url.hostname.indexOf('instagram.com') !== -1) {
                            if (shouldBlockPath(url.pathname)) {
                                e.preventDefault();
                                e.stopPropagation();
                                window.location.href = 'https://www.instagram.com/direct/inbox/';
                                return false;
                            }
                        }
                    } catch (err) {}
                }
            }, true);
        })();
        """
        return WKUserScript(source: jsSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }
}

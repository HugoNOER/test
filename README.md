# DMOnly 💬⭕

> **Instagram for talking to people, not scrolling.**  
> A personal, distraction-free iPhone app providing **Direct Messages** and **Friends' Stories** only.

---

## 📱 Concept & Purpose

**DMOnly** is a personal iOS application built with Swift and SwiftUI. It eliminates the addictive, endless-scrolling elements of Instagram while keeping the core communication channels intact:

- ✅ **Instagram Direct Messages** (Full inbox, active conversations, replies, requests, media attachments)
- ✅ **Friends' Stories** (View stories from accounts you follow)
- ❌ **No Feed** (Home feed is blocked and redirected to Messages)
- ❌ **No Reels** (Short-form video feeds are strictly blocked)
- ❌ **No Explore** (Algorithmic discovery and search feeds are blocked)
- ❌ **No Shopping or Suggested Posts**
- ❌ **No Algorithmic rabbit holes**

---

## 🔒 Security & Privacy Architecture

- **No Passwords Stored**: DMOnly never sees, logs, stores, or transmits your Instagram password or authentication tokens.
- **Official Instagram Authentication**: All logins, 2FA challenges, CAPTCHAs, and session management occur directly inside Apple's native `WKWebView`.
- **Persistent Local Session**: Utilizes `WKWebsiteDataStore.default()` so your login session persists across app launches just like Safari.
- **Zero Backend / Zero Telemetry**: €0 recurring cost. No Firebase, no Supabase, no external servers, no analytics SDKs, and no tracking.

---

## 🛡️ Strict Navigation Firewall

Every navigation within the webview passes through a centralized security policy (`InstagramURLPolicy`):

| Route / Surface | Destination Type | Firewall Action |
| :--- | :--- | :--- |
| `https://www.instagram.com/direct/*` | Direct Messages | ✅ **Allowed** |
| `https://www.instagram.com/stories/*` | Friends' Stories | ✅ **Allowed** |
| `https://www.instagram.com/accounts/*` | Auth / 2FA | ✅ **Allowed** |
| `https://www.instagram.com/` | Home Feed | 🚫 **Blocked** → Redirects to Messages |
| `https://www.instagram.com/reels/*` | Reels | 🚫 **Blocked** → Redirects to Messages |
| `https://www.instagram.com/explore/*` | Explore / Discovery | 🚫 **Blocked** → Redirects to Messages |
| `https://www.instagram.com/shop/*` | Shopping | 🚫 **Blocked** → Redirects to Messages |
| Non-Instagram External Links | External Web | 🌐 **Opened in Safari** via `UIApplication.shared.open` |

In addition, an injected script removes discovery navigation bars, Explore/Reels tabs, and post grids on profile pages, keeping the user strictly in communication mode.

---

## 🚀 Deployment & Installation Workflow

The project is designed for Apple's free personal signing route using **SideStore** (no paid Apple Developer membership required).

```text
Cursor / Local Code
        ↓
   GitHub Repo
        ↓
  GitHub Actions (.github/workflows/build.yml)
        ↓
    DMOnly.ipa
        ↓
    SideStore (Re-signs on iPhone with your free Apple ID)
        ↓
    Your iPhone
```

---

### Step 1: Push to GitHub & Build with GitHub Actions

1. Create a **Private** GitHub repository on your GitHub account.
2. Initialize and push this repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of DMOnly"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<your-repo-name>.git
   git push -u origin main
   ```
3. Go to the **Actions** tab on GitHub:
   - The workflow `Build DMOnly IPA` will run automatically.
   - You can also run it manually at any time via **Run workflow**.
4. Once completed, scroll to the **Artifacts** section at the bottom of the run page and download `DMOnly-ipa.zip`.
5. Unzip the file on your computer or iPhone to get `DMOnly.ipa`.

---

### Step 2: Install onto iPhone with SideStore

[SideStore](https://sidestore.io/) allows sideloading apps onto iOS devices using a free Apple ID and automatic on-device re-signing over local Wi-Fi / WireGuard.

1. Ensure **SideStore** is installed and paired on your iPhone.
2. Transfer or download `DMOnly.ipa` to the **Files** app on your iPhone (e.g. via iCloud Drive, AirDrop, or direct download).
3. Open **SideStore**, tap the **`+`** icon in the top left corner of the **My Apps** tab.
4. Select `DMOnly.ipa`.
5. SideStore signs the app with your personal Apple ID certificate and installs **DMOnly** onto your Home Screen.
6. Launch **DMOnly** and tap **"Continue to Instagram"** to sign in.

---

### Step 3: Building Locally in Xcode (macOS alternative)

If you have a Mac and prefer to build and test directly with Xcode:

1. Open `DMOnly.xcodeproj` in Xcode 15 or 16.
2. Select your development team under `Signing & Capabilities` (your free personal Apple ID).
3. Connect your iPhone via USB or select an iOS Simulator.
4. Press `Cmd + R` to build and run.

---

## 🔄 Updating the App

When you make changes or updates to the code:
1. Commit and push changes to GitHub.
2. Download the newly generated `DMOnly-ipa` from GitHub Actions.
3. In SideStore, tap `+` and install the new IPA. SideStore will update the app in-place while keeping your login session and cookies intact.

---

## 🛠️ Troubleshooting

- **Session expired or logged out**: Open **Settings** (gear icon in the top right) or return to the welcome screen and tap "Continue to Instagram" to re-authenticate.
- **Messages fail to load ("Couldn't load messages")**: Check your Wi-Fi or cellular connection and tap **"Try again"** or the reload button in the top navigation bar.
- **Stories fail to load ("Couldn't load Stories")**: Tap **"Try again"**. If an account has no active stories or you have viewed all stories, Instagram returns to the start or inbox.
- **SideStore "App Integrity Could Not Be Verified"**: Go to iOS **Settings > General > VPN & Device Management**, tap your Apple ID email under *Developer App*, and tap **"Trust"**.
- **External link sent in a DM won't open**: Links to third-party websites outside Instagram are intentionally handed off to Safari for security and privacy.

---

## ⚠️ Known Limitations

1. **Instagram Web Platform Constraints**: DMOnly relies on Instagram's official mobile web interface within an isolated WKWebView. Features not supported by Instagram's web application (such as certain advanced camera effects or live broadcasting) are determined by Instagram.
2. **Web Route Changes**: If Instagram alters their web routing hierarchy, update the centralized rules in `DMOnly/Instagram/InstagramURLPolicy.swift`.
3. **Free Sideloading Renewal**: Apps sideloaded with a free Apple ID must be refreshed every 7 days through SideStore (which can be done automatically over Wi-Fi).

---

## 📄 License & Disclaimer

This is a personal open-source project. Not affiliated with, endorsed by, or sponsored by Instagram, Meta, or Apple Inc. All product names, logos, and brands are property of their respective owners.

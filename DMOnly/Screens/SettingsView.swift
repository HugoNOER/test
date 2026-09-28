import SwiftUI

/// Settings view providing account management, appearance options, firewall status, and privacy disclosures.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLogoutConfirmation: Bool = false
    @State private var loggedInUsername: String = "Active"
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    HStack {
                        Label("Session Status", systemImage: "person.crop.circle.badge.checkmark")
                        Spacer()
                        Text(appState.isAuthenticated ? "Logged In" : "Logged Out")
                            .foregroundColor(appState.isAuthenticated ? .green : .secondary)
                            .font(.subheadline)
                    }
                    
                    if appState.isAuthenticated {
                        Button(role: .destructive, action: {
                            showLogoutConfirmation = true
                        }) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // MARK: - Appearance Section
                Section(header: Text("Appearance")) {
                    Picker(selection: $appState.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    } label: {
                        Label("Theme", systemImage: "paintpalette")
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Behavior Section
                Section(header: Text("Behavior")) {
                    Toggle(isOn: $appState.startInMessages) {
                        Label("Start in Messages", systemImage: "bubble.left.and.bubble.right")
                    }
                    
                    HStack {
                        Label("Firewall Protection", systemImage: "shield.lefthalf.filled")
                        Spacer()
                        Text("Active")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blocked destinations:")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        Text("• Feed & Home posts\n• Reels & Short-form video\n• Explore & Discovery search\n• Shopping & Commercial ads")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (Personal Build)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DMOnly is a personal-use iOS project created to provide access to Instagram Direct Messages and friends' Stories without the distracting Feed, Reels, or Explore sections.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("Not affiliated with, endorsed by, or sponsored by Instagram or Meta.")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Privacy Section
                Section(header: Text("Privacy & Security")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Local-First Architecture")
                            .font(.subheadline.weight(.medium))
                        
                        Text("DMOnly does not operate any backend servers, analytics tracking, or external databases. All network requests and authentications take place directly between Apple's native WKWebView and Instagram's official servers. Your password and session cookies are never intercepted, collected, or transmitted by DMOnly.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to log out of Instagram?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    appState.logout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all local session cookies and website storage.")
            }
        }
    }
}

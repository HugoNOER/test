import SwiftUI

/// Minimalist top navigation bar matching Instagram's header aesthetic.
struct TopNavigationBar: View {
    let title: String
    let canGoBack: Bool
    let onBack: () -> Void
    let onReload: () -> Void
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Back button if webview can navigate back
                if canGoBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("Go back")
                } else {
                    // Placeholder to balance spacing
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
                
                // Centered App Title
                HStack(spacing: 4) {
                    Text("DMOnly")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 6, height: 6)
                }
                .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                // Trailing actions: Reload & Settings
                HStack(spacing: 12) {
                    Button(action: onReload) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("Reload page")
                    
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
            
            Divider()
                .background(Color(uiColor: .separator).opacity(0.4))
        }
    }
}

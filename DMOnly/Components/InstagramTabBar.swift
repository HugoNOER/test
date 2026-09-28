import SwiftUI

/// Minimalist two-destination bottom tab bar inspired by Instagram's visual language.
struct InstagramTabBar: View {
    @Binding var selectedTab: AppTab
    let onTabReselected: ((AppTab) -> Void)?
    
    init(selectedTab: Binding<AppTab>, onTabReselected: ((AppTab) -> Void)? = nil) {
        self._selectedTab = selectedTab
        self.onTabReselected = onTabReselected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(uiColor: .separator).opacity(0.4))
            
            HStack(spacing: 0) {
                // Messages Tab
                tabButton(
                    tab: .messages,
                    icon: selectedTab == .messages ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right",
                    title: "Messages"
                )
                
                // Stories Tab
                tabButton(
                    tab: .stories,
                    icon: selectedTab == .stories ? "circle.circle.fill" : "circle.circle",
                    title: "Stories"
                )
            }
            .frame(height: 48)
            .padding(.horizontal, 32)
            .background(Color(uiColor: .systemBackground))
        }
    }
    
    @ViewBuilder
    private func tabButton(tab: AppTab, icon: String, title: String) -> some View {
        Button(action: {
            if selectedTab == tab {
                onTabReselected?(tab)
            } else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                selectedTab = tab
            }
        }) {
            VStack(spacing: 3) {
                ZStack {
                    if tab == .stories && selectedTab == .stories {
                        // Instagram-like gradient accent ring around stories tab icon
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 254/255, green: 218/255, blue: 119/255),
                                        Color(red: 245/255, green: 133/255, blue: 41/255),
                                        Color(red: 221/255, green: 42/255, blue: 123/255),
                                        Color(red: 129/255, green: 52/255, blue: 175/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 30, height: 30)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? .primary : .secondary)
                }
                .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.accessibilityLabel)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}

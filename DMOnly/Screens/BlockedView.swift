import SwiftUI

/// Informative view displayed if a navigation was blocked by policy, guiding the user back to Messages.
struct BlockedView: View {
    let reason: String
    let onReturnToMessages: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "shield.slash.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Content Blocked")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("DMOnly intentionally excludes the Feed, Reels, and Explore sections to prevent endless scrolling.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
            
            Button(action: onReturnToMessages) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Return to Messages")
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

import SwiftUI

/// Sleek animated loading indicator and progress bar matching Instagram's minimalist design.
struct LoadingView: View {
    var progress: Double = 0.0
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).opacity(0.85))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

/// Thin indeterminate or progress bar along the top edge of the webview.
struct TopProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if progress > 0.0 && progress < 1.0 {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 254/255, green: 218/255, blue: 119/255), // IG Yellow
                                    Color(red: 245/255, green: 133/255, blue: 41/255),  // IG Orange
                                    Color(red: 221/255, green: 42/255, blue: 123/255),  // IG Pink/Red
                                    Color(red: 129/255, green: 52/255, blue: 175/255)   // IG Purple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 2.5)
                        .animation(.easeInOut(duration: 0.2), value: progress)
                }
            }
        }
        .frame(height: 2.5)
    }
}

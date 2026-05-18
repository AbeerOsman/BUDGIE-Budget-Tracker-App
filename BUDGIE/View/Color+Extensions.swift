import SwiftUI

extension Color {
    /// A convenient linear gradient from white to gray, left to right.
    static var whiteToGrayGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.gray]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

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

/// Home screen background — cyan (top-left) → royal blue → purple (bottom-right).
struct BudgieHomeBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.0, green: 0.78, blue: 0.90), location: 0.0),
                .init(color: Color(red: 0.0, green: 0.55, blue: 0.78), location: 0.22),
                .init(color: Color(red: 0.02, green: 0.18, blue: 0.52), location: 0.48),
                .init(color: Color(red: 0.08, green: 0.10, blue: 0.42), location: 0.72),
                .init(color: Color(red: 0.36, green: 0.06, blue: 0.40), location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

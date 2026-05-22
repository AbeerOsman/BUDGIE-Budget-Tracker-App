import SwiftUI

extension Color {

    /// Grouped card surface used in sheets (Add Category, Add Payment) and home boxes.
    static func budgieGroupedBoxBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }

    /// A convenient linear gradient from white to gray, left to right.
    static var whiteToGrayGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.gray]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Hex Color

    init(hex: String) {

        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {

        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

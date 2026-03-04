import SwiftUI

// MARK: - Theme

enum Theme {
    // MARK: - Colors
    enum Colors {
        // Primary colors
        static let primary = Color(hex: "#030213")
        static let primaryForeground = Color.white

        // Background colors
        static let background = Color(hex: "#f8fafc")
        static let splashBackground = Color(hex: "#0f172a")  // slate-900

        // Card colors
        static let card = Color.white
        static let cardForeground = Color(hex: "#030213")

        // Text colors
        static let foreground = Color(hex: "#030213")
        static let mutedForeground = Color(hex: "#717182")

        // Accent colors
        static let muted = Color(hex: "#ececf0")
        static let accent = Color(hex: "#e9ebef")
        static let destructive = Color(hex: "#d4183d")
        static let destructiveForeground = Color.white

        // Input colors
        static let inputBackground = Color(hex: "#f3f3f5")
        static let border = Color.black.opacity(0.1)

        // Chart colors for category breakdown
        static let chart1 = Color(hex: "#e67e22")  // orange
        static let chart2 = Color(hex: "#2ecc71")  // green
        static let chart3 = Color(hex: "#3498db")  // blue
        static let chart4 = Color(hex: "#9b59b6")  // purple
        static let chart5 = Color(hex: "#e74c3c")  // red

        // Badge colors
        static let easyBadge = Color(hex: "#22c55e")  // green-500
        static let mediumBadge = Color(hex: "#eab308")  // yellow-500
        static let hardBadge = Color(hex: "#ef4444")  // red-500
    }

    // MARK: - Typography
    enum Typography {
        // Font sizes
        static let xs: CGFloat = 12
        static let sm: CGFloat = 14
        static let base: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 30
        static let display: CGFloat = 36

        // Font weights
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Radius
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 10
        static let xl: CGFloat = 14
        static let full: CGFloat = 9999
    }

    // MARK: - Sizes
    enum Sizes {
        static let buttonHeight: CGFloat = 48
        static let inputHeight: CGFloat = 48
        static let iconSmall: CGFloat = 16
        static let iconMedium: CGFloat = 24
        static let iconLarge: CGFloat = 32
        static let iconXL: CGFloat = 48
        static let avatarSmall: CGFloat = 32
        static let avatarMedium: CGFloat = 48
        static let avatarLarge: CGFloat = 64
    }

    // MARK: - Animation
    enum Animation {
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let fadeIn: Double = 0.8
        static let buttonDelay: Double = 1.0
        static let counterDuration: Double = 1.5
        static let toastDuration: Double = 3.0
        static let toastDelay: Double = 0.5
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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

// MARK: - View Modifiers

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    func inputStyle() -> some View {
        self
            .padding(.horizontal, Theme.Spacing.md)
            .frame(height: Theme.Sizes.inputHeight)
            .background(Theme.Colors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }
}

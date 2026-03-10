import SwiftUI

// MARK: - Avatar Size

enum AvatarSize {
    case small   // 32pt
    case medium  // 48pt
    case large   // 64pt

    var dimension: CGFloat {
        switch self {
        case .small: return Theme.Sizes.avatarSmall
        case .medium: return Theme.Sizes.avatarMedium
        case .large: return Theme.Sizes.avatarLarge
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .small: return Theme.Typography.sm
        case .medium: return Theme.Typography.lg
        case .large: return Theme.Typography.xxl
        }
    }
}

// MARK: - Avatar View

struct Avatar: View {
    let displayName: String?
    var size: AvatarSize = .medium
    var isGhost: Bool = false

    private var initial: String {
        guard let name = displayName, !name.isEmpty else { return "?" }
        return String(name.prefix(1)).uppercased()
    }

    private var backgroundColor: Color {
        if isGhost {
            return Theme.Colors.muted
        }
        guard let name = displayName, !name.isEmpty else {
            return Theme.Colors.muted
        }
        // Generate consistent color based on name
        return avatarColor(for: name)
    }

    private var foregroundColor: Color {
        if isGhost {
            return Theme.Colors.mutedForeground.opacity(0.5)
        }
        return .white
    }

    var body: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size.dimension, height: size.dimension)
            .overlay {
                if isGhost {
                    Image(systemName: "person.fill")
                        .font(.system(size: size.fontSize * 0.8))
                        .foregroundColor(foregroundColor)
                } else {
                    Text(initial)
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .foregroundColor(foregroundColor)
                }
            }
    }

    private func avatarColor(for name: String) -> Color {
        let colors: [Color] = [
            Color(hex: "#3B82F6"), // blue
            Color(hex: "#8B5CF6"), // purple
            Color(hex: "#EC4899"), // pink
            Color(hex: "#F59E0B"), // amber
            Color(hex: "#10B981"), // emerald
            Color(hex: "#06B6D4"), // cyan
            Color(hex: "#EF4444"), // red
            Color(hex: "#6366F1")  // indigo
        ]

        let hash = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[hash % colors.count]
    }
}

// MARK: - Previews

#Preview("Avatar Sizes") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            Avatar(displayName: "Sarah", size: .small)
            Avatar(displayName: "Mike", size: .medium)
            Avatar(displayName: "Emma", size: .large)
        }

        HStack(spacing: 20) {
            Avatar(displayName: nil, size: .small, isGhost: true)
            Avatar(displayName: nil, size: .medium, isGhost: true)
            Avatar(displayName: nil, size: .large, isGhost: true)
        }
    }
    .padding()
}

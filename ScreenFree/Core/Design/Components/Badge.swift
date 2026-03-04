import SwiftUI

struct Badge: View {
    let text: String
    var color: Color = Theme.Colors.primary
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small
        case medium
        case large

        var fontSize: CGFloat {
            switch self {
            case .small: return Theme.Typography.xs
            case .medium: return Theme.Typography.sm
            case .large: return Theme.Typography.base
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.xs
            case .medium: return Theme.Spacing.sm
            case .large: return Theme.Spacing.md
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.xxs
            case .medium: return Theme.Spacing.xxs
            case .large: return Theme.Spacing.xs
            }
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: size.fontSize, weight: Theme.Typography.medium))
            .foregroundColor(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let level: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(.system(size: Theme.Typography.xs))

            Text("Level \(level)")
                .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
        }
        .foregroundColor(Theme.Colors.primary)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(Theme.Colors.muted)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
    }
}

// MARK: - XP Toast

struct XPToast: View {
    let xpAmount: Int
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: Theme.Typography.base))

                Text("+\(xpAmount) XP")
                    .font(.system(size: Theme.Typography.base, weight: Theme.Typography.semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        HStack(spacing: Theme.Spacing.md) {
            Badge(text: "Easy", color: Theme.Colors.easyBadge)
            Badge(text: "Medium", color: Theme.Colors.mediumBadge)
            Badge(text: "Hard", color: Theme.Colors.hardBadge)
        }

        HStack(spacing: Theme.Spacing.md) {
            Badge(text: "Small", size: .small)
            Badge(text: "Medium", size: .medium)
            Badge(text: "Large", size: .large)
        }

        LevelBadge(level: 1)

        XPToast(xpAmount: 10, isVisible: .constant(true))
    }
    .padding()
}

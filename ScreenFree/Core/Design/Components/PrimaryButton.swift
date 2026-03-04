import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary
        case secondary
        case destructive

        var backgroundColor: Color {
            switch self {
            case .primary:
                return Theme.Colors.primary
            case .secondary:
                return Theme.Colors.muted
            case .destructive:
                return Theme.Colors.destructive
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary:
                return Theme.Colors.primaryForeground
            case .secondary:
                return Theme.Colors.foreground
            case .destructive:
                return Theme.Colors.destructiveForeground
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(.system(size: Theme.Typography.base, weight: Theme.Typography.medium))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Sizes.buttonHeight)
            .background(isDisabled ? style.backgroundColor.opacity(0.5) : style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        PrimaryButton(title: "Primary Button", action: {})
        PrimaryButton(title: "Secondary Button", action: {}, style: .secondary)
        PrimaryButton(title: "Destructive Button", action: {}, style: .destructive)
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}

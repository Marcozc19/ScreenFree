import SwiftUI

struct ComparisonChipView: View {
    let state: ComparisonState

    private var backgroundColor: Color {
        switch state {
        case .better:
            return Theme.Colors.easyBadge.opacity(0.12)
        case .worse:
            return Theme.Colors.destructive.opacity(0.12)
        case .similar, .unavailable:
            return Theme.Colors.muted
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .better:
            return Theme.Colors.easyBadge
        case .worse:
            return Theme.Colors.destructive
        case .similar, .unavailable:
            return Theme.Colors.mutedForeground
        }
    }

    private var icon: String? {
        switch state {
        case .better:
            return "arrow.down"
        case .worse:
            return "arrow.up"
        case .similar, .unavailable:
            return nil
        }
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: Theme.Typography.xs, weight: .semibold))
            }

            Text(state.displayText)
                .font(.system(size: Theme.Typography.xs, weight: .medium))
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, Theme.Spacing.xs)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
    }
}

#Preview {
    VStack(spacing: 12) {
        ComparisonChipView(state: .better(percentDiff: 25))
        ComparisonChipView(state: .worse(percentDiff: 15))
        ComparisonChipView(state: .similar)
        ComparisonChipView(state: .unavailable)
    }
    .padding()
}

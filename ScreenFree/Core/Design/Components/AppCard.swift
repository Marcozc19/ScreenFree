import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Theme.Spacing.md

    init(padding: CGFloat = Theme.Spacing.md, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let title: String
    let description: String
    let difficulty: ChallengeDifficulty
    let duration: String
    var progress: Int? = nil
    var totalDays: Int? = nil
    var quote: String? = nil

    enum ChallengeDifficulty: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var color: Color {
            switch self {
            case .easy: return Theme.Colors.easyBadge
            case .medium: return Theme.Colors.mediumBadge
            case .hard: return Theme.Colors.hardBadge
            }
        }
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Text(title)
                        .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                        .foregroundColor(Theme.Colors.foreground)

                    Spacer()

                    Badge(text: difficulty.rawValue, color: difficulty.color)
                }

                Text(description)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)

                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Text(duration)
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }

                if let progress = progress, let total = totalDays {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text("Day \(progress) of \(total)")
                            .font(.system(size: Theme.Typography.xs))
                            .foregroundColor(Theme.Colors.mutedForeground)

                        ProgressBar(value: Double(progress), total: Double(total))
                    }
                    .padding(.top, Theme.Spacing.xs)
                }

                if let quote = quote {
                    Text("\"\(quote)\"")
                        .font(.system(size: Theme.Typography.sm, weight: .regular).italic())
                        .foregroundColor(Theme.Colors.mutedForeground)
                        .padding(.top, Theme.Spacing.xs)
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    var icon: String? = nil

    var body: some View {
        AppCard {
            HStack(spacing: Theme.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.Typography.xl))
                        .foregroundColor(Theme.Colors.primary)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(title)
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Text(value)
                        .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: Theme.Typography.xs))
                            .foregroundColor(Theme.Colors.mutedForeground)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let message: String
    var icon: String = "lightbulb"

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: Theme.Typography.lg))
                    .foregroundColor(Theme.Colors.primary)

                Text(message)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Theme.Spacing.md) {
            AppCard {
                Text("Simple Card Content")
            }

            ChallengeCard(
                title: "Morning Clarity",
                description: "No phone for the first hour after waking",
                difficulty: .easy,
                duration: "7 days",
                progress: 1,
                totalDays: 7,
                quote: "The morning is wiser than the evening."
            )

            StatCard(
                title: "Daily Average",
                value: "4h 32m",
                subtitle: "Based on last 7 days",
                icon: "clock"
            )

            TipCard(message: "Come back tonight to log your first check-in.")
        }
        .padding()
    }
    .background(Theme.Colors.background)
}

import SwiftUI

struct FriendsHeroCard: View {
    let todayMins: Int
    let weeklyAvgMins: Int
    let userName: String?

    private var todayFormatted: String {
        formatMinutes(todayMins)
    }

    private var weeklyAvgFormatted: String {
        formatMinutes(weeklyAvgMins)
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // User info
            HStack(spacing: Theme.Spacing.sm) {
                Avatar(displayName: userName, size: .medium)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Your Screen Time")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    if let name = userName {
                        Text(name)
                            .font(.system(size: Theme.Typography.base, weight: .semibold))
                            .foregroundColor(Theme.Colors.foreground)
                    }
                }

                Spacer()
            }

            Divider()
                .background(Theme.Colors.border)

            // Stats
            HStack(spacing: Theme.Spacing.xl) {
                // Today
                VStack(spacing: Theme.Spacing.xxs) {
                    Text("Today")
                        .font(.system(size: Theme.Typography.xs))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Text(todayFormatted)
                        .font(.system(size: Theme.Typography.xl, weight: .bold))
                        .foregroundColor(Theme.Colors.foreground)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Theme.Colors.border)
                    .frame(width: 1, height: 40)

                // 7-Day Average
                VStack(spacing: Theme.Spacing.xxs) {
                    Text("7-Day Avg")
                        .font(.system(size: Theme.Typography.xs))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Text(weeklyAvgFormatted)
                        .font(.system(size: Theme.Typography.xl, weight: .bold))
                        .foregroundColor(Theme.Colors.foreground)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func formatMinutes(_ mins: Int) -> String {
        let hours = mins / 60
        let minutes = mins % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    FriendsHeroCard(
        todayMins: 210,
        weeklyAvgMins: 245,
        userName: "Marco"
    )
    .padding()
    .background(Theme.Colors.background)
}

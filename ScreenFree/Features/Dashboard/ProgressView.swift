import SwiftUI

struct ProgressView: View {
    @Environment(AppState.self) private var appState

    // Mock weekly data
    private let weeklyData: [(day: String, hours: Double)] = [
        ("Mon", 4.2),
        ("Tue", 3.8),
        ("Wed", 4.5),
        ("Thu", 3.5),
        ("Fri", 4.0),
        ("Sat", 5.2),
        ("Sun", 4.8)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Weekly overview card
                    AppCard {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            Text("This Week")
                                .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.foreground)

                            // Simple bar chart
                            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                                ForEach(weeklyData, id: \.day) { data in
                                    VStack(spacing: Theme.Spacing.xxs) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Theme.Colors.primary)
                                            .frame(width: 32, height: CGFloat(data.hours * 20))

                                        Text(data.day)
                                            .font(.system(size: Theme.Typography.xs))
                                            .foregroundColor(Theme.Colors.mutedForeground)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, Theme.Spacing.sm)

                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Weekly Average")
                                        .font(.system(size: Theme.Typography.xs))
                                        .foregroundColor(Theme.Colors.mutedForeground)
                                    Text("4h 17m")
                                        .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("Best Day")
                                        .font(.system(size: Theme.Typography.xs))
                                        .foregroundColor(Theme.Colors.mutedForeground)
                                    Text("Thu (3h 30m)")
                                        .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                                        .foregroundColor(Theme.Colors.easyBadge)
                                }
                            }
                        }
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                        StatCard(
                            title: "Current Streak",
                            value: "4 days",
                            subtitle: nil,
                            icon: "flame"
                        )

                        StatCard(
                            title: "Total XP",
                            value: "\(appState.userProfile?.xp ?? 10)",
                            subtitle: "Level \(appState.userProfile?.level ?? 1)",
                            icon: "star"
                        )
                    }

                    // Demo badge
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: Theme.Typography.sm))
                        Text("Demo data shown. Connect Screen Time for real stats.")
                            .font(.system(size: Theme.Typography.xs))
                    }
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .padding(.top, Theme.Spacing.sm)

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    let appState = AppState()
    appState.userProfile = UserProfile(
        displayName: "Marco",
        ageRange: .age25to34,
        xp: 10,
        level: 1
    )

    return ProgressView()
        .environment(appState)
}

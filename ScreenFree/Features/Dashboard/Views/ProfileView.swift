import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Profile header
                    VStack(spacing: Theme.Spacing.md) {
                        // Avatar
                        Circle()
                            .fill(Theme.Colors.primary)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(appState.userProfile?.displayName.prefix(1) ?? "?").uppercased())
                                    .font(.system(size: 40, weight: Theme.Typography.bold))
                                    .foregroundColor(.white)
                            )

                        if let profile = appState.userProfile {
                            Text(profile.displayName)
                                .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.foreground)

                            LevelBadge(level: profile.level)

                            // XP Progress
                            VStack(spacing: Theme.Spacing.xs) {
                                XPProgressBar(currentXP: profile.xp, requiredXP: profile.xpForNextLevel)
                                    .frame(width: 200)

                                Text("\(profile.xpForNextLevel - profile.xp) XP to Level \(profile.level + 1)")
                                    .font(.system(size: Theme.Typography.xs))
                                    .foregroundColor(Theme.Colors.mutedForeground)
                            }
                        }
                    }
                    .padding(.top, Theme.Spacing.lg)

                    // Stats cards
                    VStack(spacing: Theme.Spacing.md) {
                        StatCard(
                            title: "Baseline Screen Time",
                            value: FramingCopy.formatScreenTime(appState.screenTimeData?.totalHours ?? 4.5),
                            subtitle: "Your starting point",
                            icon: "clock"
                        )

                        StatCard(
                            title: "Member Since",
                            value: "Today",
                            subtitle: "Day 1 of your journey",
                            icon: "calendar"
                        )

                        StatCard(
                            title: "Challenges Completed",
                            value: "0",
                            subtitle: "Complete Morning Clarity to start!",
                            icon: "flag.checkered"
                        )
                    }

                    // Settings section
                    VStack(spacing: Theme.Spacing.sm) {
                        settingsRow(icon: "bell", title: "Notifications", action: {})
                        settingsRow(icon: "lock", title: "Privacy", action: {})
                        settingsRow(icon: "questionmark.circle", title: "Help & Support", action: {})
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))

                    // Sign out button
                    Button {
                        Task {
                            try? await AuthService.shared.signOut()
                            appState.signOut()
                        }
                    } label: {
                        Text("Sign Out")
                            .font(.system(size: Theme.Typography.base, weight: Theme.Typography.medium))
                            .foregroundColor(Theme.Colors.destructive)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                    }

                    // Version info
                    Text("ScreenFree v1.0 (Demo Mode)")
                        .font(.system(size: Theme.Typography.xs))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Profile")
        }
    }

    private func settingsRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: Theme.Typography.lg))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: Theme.Typography.base))
                    .foregroundColor(Theme.Colors.foreground)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }
            .padding(.vertical, Theme.Spacing.xs)
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
    appState.screenTimeData = .mock

    return ProfileView()
        .environment(appState)
}

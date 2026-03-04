import SwiftUI

struct DashboardEntryView: View {
    @Environment(AppState.self) private var appState

    @State private var showContent = false
    @State private var showXPToast = false

    private let challenge = Challenge.morningClarity

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    header
                        .padding(.top, Theme.Spacing.md)

                    // Welcome message
                    if let profile = appState.userProfile {
                        Text(FramingCopy.welcomeMessage(displayName: profile.displayName))
                            .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.medium))
                            .foregroundColor(Theme.Colors.foreground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Active challenge card
                    if let userChallenge = appState.activeChallenge {
                        activeChallengeCard(userChallenge: userChallenge)
                    }

                    // Baseline stats card
                    if let baseline = appState.screenTimeData?.totalHours {
                        baselineCard(hours: baseline)
                    }

                    // Tip card
                    TipCard(message: FramingCopy.onboardingTip)

                    // Continue button
                    PrimaryButton(
                        title: "Let's go",
                        action: completeOnboarding
                    )
                    .padding(.top, Theme.Spacing.md)

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .background(Theme.Colors.background)

            // XP Toast
            XPToast(xpAmount: 10, isVisible: $showXPToast)
                .padding(.top, Theme.Spacing.xl)
        }
        .onAppear {
            animateEntry()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            // Logo
            Text("ScreenFree")
                .font(.system(size: Theme.Typography.xl, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.foreground)

            Spacer()

            // Level badge and XP bar
            HStack(spacing: Theme.Spacing.sm) {
                LevelBadge(level: appState.userProfile?.level ?? 1)

                XPProgressBar(
                    currentXP: 10,  // Just earned 10 XP
                    requiredXP: appState.userProfile?.xpForNextLevel ?? 100
                )
                .frame(width: 80)
            }
        }
    }

    // MARK: - Active Challenge Card

    private func activeChallengeCard(userChallenge: UserChallenge) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Active Challenge")
                    .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Spacer()

                Badge(text: "Day 1", color: Theme.Colors.primary, size: .small)
            }

            Text(challenge.title)
                .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                .foregroundColor(Theme.Colors.foreground)

            Text(challenge.description)
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)

            // Progress
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Day \(userChallenge.dayNumber) of \(challenge.durationDays)")
                    .font(.system(size: Theme.Typography.xs))
                    .foregroundColor(Theme.Colors.mutedForeground)

                ProgressBar(
                    value: Double(userChallenge.dayNumber),
                    total: Double(challenge.durationDays),
                    height: 6
                )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Baseline Card

    private func baselineCard(hours: Double) -> some View {
        StatCard(
            title: "Your Baseline",
            value: FramingCopy.formatScreenTime(hours),
            subtitle: "Daily average before starting",
            icon: "chart.bar"
        )
    }

    // MARK: - Actions

    private func animateEntry() {
        // Show content with fade
        withAnimation(.easeOut(duration: Theme.Animation.fadeIn)) {
            showContent = true
        }

        // Show XP toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animation.toastDelay) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showXPToast = true
            }

            // Award XP to profile
            appState.awardXP(10)

            // Dismiss toast after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animation.toastDuration) {
                withAnimation(.easeOut(duration: Theme.Animation.normal)) {
                    showXPToast = false
                }
            }
        }
    }

    private func completeOnboarding() {
        Task {
            // Update profile in database
            if let userId = appState.userProfile?.id,
               let baseline = appState.screenTimeData?.totalHours {
                do {
                    try await DatabaseService.shared.updateOnboardingComplete(
                        userId: userId,
                        baselineScreenTime: baseline
                    )
                } catch {
                    // Continue even if database update fails
                    print("Failed to update onboarding status: \(error)")
                }
            }

            appState.completeOnboarding()
        }
    }
}

// MARK: - Preview

#Preview {
    let appState = AppState()
    appState.userProfile = UserProfile(
        displayName: "TestUser",
        ageRange: .age25to34
    )
    appState.screenTimeData = .mock
    appState.activeChallenge = UserChallenge(
        challengeId: Challenge.morningClarity.id,
        userId: UUID()
    )

    return DashboardEntryView()
        .environment(appState)
}

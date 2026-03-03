import SwiftUI

struct FirstChallengeView: View {
    @Environment(AppState.self) private var appState

    @State private var showCard = false
    @State private var isLoading = false

    private let challenge = Challenge.morningClarity

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text("Your first challenge")
                    .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("Small steps lead to big changes")
                    .font(.system(size: Theme.Typography.base))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Challenge Card
            if showCard {
                challengeCard
                    .padding(.horizontal, Theme.Spacing.lg)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            Spacer()

            // CTA Button
            PrimaryButton(
                title: "Accept this challenge",
                action: acceptChallenge,
                isLoading: isLoading
            )
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.background)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                showCard = true
            }
        }
    }

    // MARK: - Challenge Card

    private var challengeCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header
            HStack {
                Text(challenge.title)
                    .font(.system(size: Theme.Typography.xl, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Spacer()

                Badge(text: challenge.difficulty.displayName, color: Theme.Colors.easyBadge)
            }

            // Description
            Text(challenge.description)
                .font(.system(size: Theme.Typography.base))
                .foregroundColor(Theme.Colors.mutedForeground)

            // Duration
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "calendar")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Text(challenge.durationDisplay)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Spacer()

                HStack(spacing: Theme.Spacing.xxs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.primary)

                    Text("+\(challenge.xpReward) XP")
                        .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                        .foregroundColor(Theme.Colors.primary)
                }
            }

            // Quote
            if let quote = challenge.quote {
                Divider()
                    .padding(.vertical, Theme.Spacing.xs)

                Text("\"\(quote)\"")
                    .font(.system(size: Theme.Typography.sm).italic())
                    .foregroundColor(Theme.Colors.mutedForeground)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Actions

    private func acceptChallenge() {
        guard let userId = appState.userProfile?.id else { return }

        isLoading = true

        Task {
            do {
                // Create user challenge in database
                let userChallenge = try await DatabaseService.shared.createUserChallenge(
                    userId: userId,
                    challengeId: challenge.id
                )

                appState.activeChallenge = userChallenge
                appState.advanceOnboarding()

                isLoading = false
            } catch {
                isLoading = false
                appState.setError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FirstChallengeView()
        .environment(AppState())
}

import SwiftUI

struct ChallengesView: View {
    @Environment(AppState.self) private var appState

    private let availableChallenges = [
        Challenge(
            id: "digital_sunset",
            title: "Digital Sunset",
            description: "No screens 1 hour before bed",
            difficulty: .medium,
            durationDays: 7,
            xpReward: 75,
            quote: "Sleep is the best meditation."
        ),
        Challenge(
            id: "focus_friday",
            title: "Focus Friday",
            description: "Keep screen time under 3 hours every Friday",
            difficulty: .medium,
            durationDays: 4,
            xpReward: 60
        ),
        Challenge(
            id: "app_free_meals",
            title: "App-Free Meals",
            description: "No phone during meals",
            difficulty: .easy,
            durationDays: 7,
            xpReward: 50,
            quote: "Be present where your feet are."
        ),
        Challenge(
            id: "weekend_warrior",
            title: "Weekend Warrior",
            description: "Reduce weekend screen time by 25%",
            difficulty: .hard,
            durationDays: 2,
            xpReward: 100
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Active challenge section
                    if let activeChallenge = appState.activeChallenge {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Active Challenge")
                                .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.foreground)

                            ChallengeCard(
                                title: Challenge.morningClarity.title,
                                description: Challenge.morningClarity.description,
                                difficulty: .easy,
                                duration: Challenge.morningClarity.durationDisplay,
                                progress: activeChallenge.dayNumber,
                                totalDays: Challenge.morningClarity.durationDays,
                                quote: Challenge.morningClarity.quote
                            )
                        }
                    }

                    // Available challenges
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Available Challenges")
                            .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                            .foregroundColor(Theme.Colors.foreground)

                        ForEach(availableChallenges) { challenge in
                            ChallengeCard(
                                title: challenge.title,
                                description: challenge.description,
                                difficulty: challengeDifficulty(challenge.difficulty),
                                duration: challenge.durationDisplay,
                                quote: challenge.quote
                            )
                        }
                    }

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Challenges")
        }
    }

    private func challengeDifficulty(_ difficulty: ChallengeDifficulty) -> ChallengeCard.ChallengeDifficulty {
        switch difficulty {
        case .easy: return .easy
        case .medium: return .medium
        case .hard: return .hard
        }
    }
}

#Preview {
    let appState = AppState()
    appState.activeChallenge = UserChallenge(
        challengeId: Challenge.morningClarity.id,
        userId: UUID()
    )

    return ChallengesView()
        .environment(appState)
}

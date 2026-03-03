import SwiftUI

struct OnboardingCoordinator: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ZStack {
                // Background based on current step
                backgroundColor
                    .ignoresSafeArea()

                // Current step view
                currentStepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            .animation(.easeInOut(duration: Theme.Animation.normal), value: appState.currentOnboardingStep)
        }
    }

    private var backgroundColor: Color {
        switch appState.currentOnboardingStep {
        case .splash:
            return Theme.Colors.splashBackground
        default:
            return Theme.Colors.background
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch appState.currentOnboardingStep {
        case .splash:
            SplashView()
        case .accountCreation:
            AccountCreationView()
        case .permissionGate:
            PermissionGateView()
        case .mirror:
            MirrorView()
        case .firstChallenge:
            FirstChallengeView()
        case .dashboardEntry:
            DashboardEntryView()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingCoordinator()
        .environment(AppState())
}

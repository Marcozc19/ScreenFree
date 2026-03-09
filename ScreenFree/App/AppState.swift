import SwiftUI
import Observation

@Observable
final class AppState {
    // MARK: - Authentication State
    var isAuthenticated: Bool = false
    var currentUser: User?
    var userProfile: UserProfile?

    // MARK: - Onboarding State
    var hasCompletedOnboarding: Bool = false
    var currentOnboardingStep: OnboardingStep = .splash

    // MARK: - Screen Time State
    var hasScreenTimePermission: Bool = false
    var screenTimeData: ScreenTimeData?

    // MARK: - Challenge State
    var activeChallenge: UserChallenge?

    // MARK: - UI State
    var isLoading: Bool = false
    var errorMessage: String?
    var showXPToast: Bool = false
    var xpToastAmount: Int = 0

    // MARK: - Initialization

    init() {
        loadPersistedState()
    }

    // MARK: - State Management

    func setAuthenticated(user: User, profile: UserProfile) {
        self.currentUser = user
        self.userProfile = profile
        self.isAuthenticated = true
        self.hasCompletedOnboarding = profile.onboardingCompleted

        if profile.onboardingCompleted {
            // User has completed onboarding, go to dashboard
        }
    }

    func signOut() {
        currentUser = nil
        userProfile = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentOnboardingStep = .splash
        activeChallenge = nil
        clearPersistedState()
    }

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: Theme.Animation.normal)) {
            hasCompletedOnboarding = true
        }
        userProfile?.onboardingCompleted = true
        persistState()
    }

    func advanceOnboarding() {
        if let next = currentOnboardingStep.next {
            currentOnboardingStep = next
        }
    }

    func goBackOnboarding() {
        if let prev = currentOnboardingStep.previous {
            currentOnboardingStep = prev
        }
    }

    func awardXP(_ amount: Int) {
        guard var profile = userProfile else { return }
        profile.xp += amount

        // Check for level up
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }

        userProfile = profile
        xpToastAmount = amount
        showXPToast = true

        // Auto-dismiss toast
        DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animation.toastDuration) {
            self.showXPToast = false
        }
    }

    func setScreenTimePermission(_ granted: Bool) {
        hasScreenTimePermission = granted
        persistState()
    }

    func setScreenTimeData(_ data: ScreenTimeData) {
        screenTimeData = data
        userProfile?.baselineScreenTime = data.totalHours
    }

    func setError(_ message: String?) {
        errorMessage = message
        if message != nil {
            // Auto-dismiss error after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if self.errorMessage == message {
                    self.errorMessage = nil
                }
            }
        }
    }

    // MARK: - Persistence

    private let userDefaultsKey = "AppState"

    private func persistState() {
        let data: [String: Any] = [
            "hasScreenTimePermission": hasScreenTimePermission,
            "hasCompletedOnboarding": hasCompletedOnboarding
        ]
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    private func loadPersistedState() {
        guard let data = UserDefaults.standard.dictionary(forKey: userDefaultsKey) else { return }
        hasScreenTimePermission = data["hasScreenTimePermission"] as? Bool ?? false
        hasCompletedOnboarding = data["hasCompletedOnboarding"] as? Bool ?? false
    }

    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

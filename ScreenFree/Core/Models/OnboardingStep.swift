import Foundation

enum OnboardingStep: Int, CaseIterable, Hashable {
    case splash = 0
    case accountCreation = 1
    case permissionGate = 2
    case mirror = 3
    case firstChallenge = 4
    case dashboardEntry = 5

    var title: String {
        switch self {
        case .splash:
            return "Welcome"
        case .accountCreation:
            return "Create Account"
        case .permissionGate:
            return "Screen Time Access"
        case .mirror:
            return "Your Screen Time"
        case .firstChallenge:
            return "First Challenge"
        case .dashboardEntry:
            return "Dashboard"
        }
    }

    var canGoBack: Bool {
        switch self {
        case .splash, .permissionGate:
            return false
        default:
            return true
        }
    }

    var next: OnboardingStep? {
        let nextRaw = self.rawValue + 1
        return OnboardingStep(rawValue: nextRaw)
    }

    var previous: OnboardingStep? {
        guard canGoBack else { return nil }
        let prevRaw = self.rawValue - 1
        return OnboardingStep(rawValue: prevRaw)
    }

    var progress: Double {
        Double(self.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
}

import Foundation
import Observation

// MARK: - Dashboard View Model

@Observable
@MainActor
final class DashboardViewModel {
    // MARK: - State

    var selectedTab: DashboardTab = .home

    // MARK: - Time of Day

    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }

    // MARK: - Analytics

    func logTabChanged(to tab: DashboardTab) {
        // Tab change analytics - logged with parameters
        print("[Analytics] Tab changed to: \(tab.rawValue)")
    }
}

// MARK: - Dashboard Tab

enum DashboardTab: String, CaseIterable {
    case home = "Home"
    case social = "Social"
    case challenges = "Challenges"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "house"
        case .social: return "person.3"
        case .challenges: return "flag"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .social: return "person.3.fill"
        case .challenges: return "flag.fill"
        case .profile: return "person.fill"
        }
    }
}

import Foundation
import Observation

// MARK: - Dashboard View Model

@Observable
@MainActor
final class DashboardViewModel {
    // MARK: - State

    var selectedTab: DashboardTab = .home

    // MARK: - Computed Properties (derived from AppState)

    func todayUsage(from screenTimeData: ScreenTimeData?) -> Double {
        let baseline = screenTimeData?.totalHours ?? 4.5
        return baseline * 0.78 // Demo: today is slightly less
    }

    func baselineUsage(from screenTimeData: ScreenTimeData?) -> Double {
        screenTimeData?.totalHours ?? 4.5
    }

    func weeklyData(from screenTimeData: ScreenTimeData?) -> [DayUsage] {
        let baseline = baselineUsage(from: screenTimeData)
        let today = todayUsage(from: screenTimeData)
        return [
            DayUsage(day: "M", hours: baseline * 0.92, isToday: false),
            DayUsage(day: "T", hours: baseline * 0.85, isToday: false),
            DayUsage(day: "W", hours: baseline * 1.05, isToday: false),
            DayUsage(day: "T", hours: baseline * 0.78, isToday: false),
            DayUsage(day: "F", hours: baseline * 0.88, isToday: false),
            DayUsage(day: "S", hours: baseline * 1.12, isToday: false),
            DayUsage(day: "S", hours: today, isToday: true)
        ]
    }

    var streakDays: Int {
        4 // Demo: 4 day streak
    }

    func todayCategories(from screenTimeData: ScreenTimeData?) -> [CategoryUsage] {
        screenTimeData?.topCategories ?? ScreenTimeData.mock.topCategories
    }

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
    case progress = "Progress"
    case social = "Social"
    case challenges = "Challenges"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "house"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .social: return "person.3"
        case .challenges: return "flag"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .social: return "person.3.fill"
        case .challenges: return "flag.fill"
        case .profile: return "person.fill"
        }
    }
}

import SwiftUI

struct DashboardTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case challenges = "Challenges"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "house"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .challenges: return "flag"
            case .profile: return "person"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .challenges: return "flag.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(
                            tab.rawValue,
                            systemImage: selectedTab == tab ? tab.selectedIcon : tab.icon
                        )
                    }
                    .tag(tab)
            }
        }
        .tint(Theme.Colors.primary)
    }

    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .progress:
            ProgressView()
        case .challenges:
            ChallengesView()
        case .profile:
            ProfileView()
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

    return DashboardTabView()
        .environment(appState)
}

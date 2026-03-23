import SwiftUI

struct DashboardTabView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(
                            tab.rawValue,
                            systemImage: viewModel.selectedTab == tab ? tab.selectedIcon : tab.icon
                        )
                    }
                    .tag(tab)
            }
        }
        .tint(Theme.Colors.primary)
        .onChange(of: viewModel.selectedTab) { _, newTab in
            viewModel.logTabChanged(to: newTab)
        }
    }

    @ViewBuilder
    private func tabContent(for tab: DashboardTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .social:
            SocialHubView()
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

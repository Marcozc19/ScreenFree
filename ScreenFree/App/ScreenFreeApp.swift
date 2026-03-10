import SwiftUI

@main
struct ScreenFreeApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    private var showDashboard: Bool {
        appState.hasCompletedOnboarding && appState.isAuthenticated
    }

    var body: some View {
        Group {
            if showDashboard {
                DashboardTabView()
            } else {
                OnboardingCoordinator()
            }
        }
        .id(showDashboard)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}

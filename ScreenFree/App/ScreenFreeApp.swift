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

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding && appState.isAuthenticated {
                DashboardTabView()
            } else {
                OnboardingCoordinator()
            }
        }
        .animation(.easeInOut(duration: Theme.Animation.normal), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}

import SwiftUI

struct PermissionGateView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase

    @State private var isLoading = false
    @State private var showDeniedState = false
    @State private var showExplainer = false

    private let screenTimeService = ScreenTimeService.shared

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content
            VStack(spacing: Theme.Spacing.xl) {
                // Icon
                Image(systemName: "shield.checkered")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.Colors.primary)

                // Title & Description
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Connect Screen Time")
                        .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)

                    Text(screenTimeService.useMockMode
                         ? "In demo mode, we'll use sample data to show you how ScreenFree works."
                         : "We need access to your Screen Time data to help you understand your phone habits and track your progress.")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)
                        .multilineTextAlignment(.center)
                }

                // Privacy note
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: screenTimeService.useMockMode ? "sparkles" : "lock.fill")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Text(screenTimeService.useMockMode
                         ? "Demo mode - using sample screen time data"
                         : "Your data stays private and never leaves your device")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Colors.muted)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Bottom section
            VStack(spacing: Theme.Spacing.md) {
                if showDeniedState {
                    deniedStateView
                } else {
                    PrimaryButton(
                        title: screenTimeService.useMockMode ? "Continue with Demo Data" : "Connect Screen Time",
                        action: requestPermission,
                        isLoading: isLoading
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.background)
        .onAppear {
            checkCurrentStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkCurrentStatus()
            }
        }
    }

    // MARK: - Denied State View

    private var deniedStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Explainer toggle
            Button {
                withAnimation(.easeInOut(duration: Theme.Animation.normal)) {
                    showExplainer.toggle()
                }
            } label: {
                HStack {
                    Text("Why do we need this?")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Image(systemName: showExplainer ? "chevron.up" : "chevron.down")
                        .font(.system(size: Theme.Typography.xs))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
            }

            if showExplainer {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    explainerItem(
                        icon: "chart.bar",
                        text: "Track your daily screen time"
                    )
                    explainerItem(
                        icon: "target",
                        text: "Set and achieve usage goals"
                    )
                    explainerItem(
                        icon: "bell",
                        text: "Get helpful reminders"
                    )
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.muted)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            }

            PrimaryButton(
                title: "Open Settings",
                action: {
                    screenTimeService.openScreenTimeSettings()
                }
            )

            Text("Enable \"ScreenFree\" in Screen Time settings, then return here")
                .font(.system(size: Theme.Typography.xs))
                .foregroundColor(Theme.Colors.mutedForeground)
                .multilineTextAlignment(.center)
        }
    }

    private func explainerItem(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: Theme.Typography.base))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 24)

            Text(text)
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.foreground)
        }
    }

    // MARK: - Actions

    private func checkCurrentStatus() {
        // In mock mode, we don't auto-advance - let user tap the button
        if !screenTimeService.useMockMode && screenTimeService.isAuthorized {
            appState.setScreenTimePermission(true)
            appState.advanceOnboarding()
        } else if !screenTimeService.useMockMode && screenTimeService.authorizationStatus == .denied {
            showDeniedState = true
        }
    }

    private func requestPermission() {
        isLoading = true

        Task {
            do {
                try await screenTimeService.requestAuthorization()

                appState.setScreenTimePermission(true)
                appState.advanceOnboarding()
            } catch ScreenTimeError.authorizationDenied {
                showDeniedState = true
            } catch {
                // In mock mode, errors are expected - just continue
                if screenTimeService.useMockMode {
                    appState.setScreenTimePermission(true)
                    appState.advanceOnboarding()
                } else {
                    appState.setError(error.localizedDescription)
                }
            }

            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    PermissionGateView()
        .environment(AppState())
}

import SwiftUI

struct MirrorView: View {
    @Environment(AppState.self) private var appState

    @State private var screenTimeData: ScreenTimeData?
    @State private var isLoading = true
    @State private var animateCounter = false
    @State private var showContent = false

    private let screenTimeService = ScreenTimeService.shared

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                loadingView
            } else if let data = screenTimeData {
                contentView(data: data)
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            loadScreenTimeData()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Analyzing your screen time...")
                .font(.system(size: Theme.Typography.base))
                .foregroundColor(Theme.Colors.mutedForeground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Content View

    private func contentView(data: ScreenTimeData) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Theme.Spacing.xl) {
                // Counter display
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Your daily average")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    if animateCounter {
                        AnimatedCounter(
                            targetValue: data.totalHours,
                            duration: Theme.Animation.counterDuration,
                            format: .hoursMinutes
                        )
                        .font(.system(size: Theme.Typography.display * 1.5, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)
                    } else {
                        Text("0h 0m")
                            .font(.system(size: Theme.Typography.display * 1.5, weight: Theme.Typography.bold))
                            .foregroundColor(Theme.Colors.foreground)
                    }

                    Text("per day")
                        .font(.system(size: Theme.Typography.lg))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }

                // Framing message
                if showContent {
                    Text(FramingCopy.mirrorMessage(forHours: data.totalHours))
                        .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.medium))
                        .foregroundColor(Theme.Colors.foreground)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Category breakdown
            if showContent {
                categoryBreakdown(data: data)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()

            // CTA Button
            if showContent {
                PrimaryButton(
                    title: "Got it. I'm ready to change this",
                    action: {
                        appState.setScreenTimeData(data)
                        appState.advanceOnboarding()
                    }
                )
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeOut(duration: Theme.Animation.slow), value: showContent)
    }

    // MARK: - Category Breakdown

    private func categoryBreakdown(data: ScreenTimeData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Where your time goes")
                .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                .foregroundColor(Theme.Colors.mutedForeground)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(Array(data.topCategories.enumerated()), id: \.element.id) { index, category in
                    CategoryProgressBar(
                        category: category.name,
                        hours: category.hours,
                        maxHours: data.maxCategoryHours,
                        color: categoryColor(for: index)
                    )
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private func categoryColor(for index: Int) -> Color {
        switch index {
        case 0: return Theme.Colors.chart1
        case 1: return Theme.Colors.chart2
        case 2: return Theme.Colors.chart3
        default: return Theme.Colors.chart4
        }
    }

    // MARK: - Data Loading

    private func loadScreenTimeData() {
        Task {
            // Small delay for loading effect
            try? await Task.sleep(nanoseconds: 500_000_000)

            let data = await screenTimeService.getScreenTimeData()
            screenTimeData = data
            isLoading = false

            // Start counter animation after a brief delay
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation {
                animateCounter = true
            }

            // Show content after counter animation completes
            try? await Task.sleep(nanoseconds: UInt64(Theme.Animation.counterDuration * 1_000_000_000))
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MirrorView()
        .environment(AppState())
}

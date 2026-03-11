import SwiftUI

// MARK: - Home View (Clock Dial Dashboard v1.2)

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedInterval: DashboardInterval = .day
    @State private var dialAnimationProgress: Double = 0.0

    // MARK: - Computed Data

    private var baselineMinutes: Int {
        // Baseline from screen time data (converted to minutes)
        Int((appState.screenTimeData?.totalHours ?? 4.5) * 60)
    }

    private var todayMinutes: Int {
        // Today's usage (demo: slightly below baseline)
        let baseline = appState.screenTimeData?.totalHours ?? 4.5
        return Int(baseline * 0.78 * 60)
    }

    private var weeklyAverageMinutes: Int {
        // Weekly average (demo data)
        let baseline = appState.screenTimeData?.totalHours ?? 4.5
        return Int(baseline * 0.85 * 60)
    }

    private var displayMinutes: Int {
        selectedInterval == .day ? todayMinutes : weeklyAverageMinutes
    }

    private var deltaChipState: DeltaChipState {
        let baseline = baselineMinutes
        let current = displayMinutes
        let delta = current - baseline
        let threshold = Int(Double(baseline) * 0.05) // 5% tolerance

        if abs(delta) <= threshold {
            return .onTrack
        } else if delta < 0 {
            return .belowBaseline(minutes: abs(delta))
        } else {
            return .aboveBaseline(minutes: delta)
        }
    }

    private var chartBars: [ChartBarModel] {
        let baseline = appState.screenTimeData?.totalHours ?? 4.5

        if selectedInterval == .day {
            // Past 7 days (Mon-Sun, today is Sunday for demo)
            return [
                ChartBarModel(label: "M", minutes: Int(baseline * 0.92 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "T", minutes: Int(baseline * 0.85 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W", minutes: Int(baseline * 1.05 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "T", minutes: Int(baseline * 0.78 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "F", minutes: Int(baseline * 0.88 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "S", minutes: Int(baseline * 1.12 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "S", minutes: todayMinutes, isCurrentPeriod: true, isFuture: false)
            ]
        } else {
            // Past 7 weeks
            return [
                ChartBarModel(label: "W1", minutes: Int(baseline * 7 * 0.95 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W2", minutes: Int(baseline * 7 * 0.88 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W3", minutes: Int(baseline * 7 * 1.02 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W4", minutes: Int(baseline * 7 * 0.92 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W5", minutes: Int(baseline * 7 * 0.98 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W6", minutes: Int(baseline * 7 * 0.85 * 60), isCurrentPeriod: false, isFuture: false),
                ChartBarModel(label: "W7", minutes: weeklyAverageMinutes * 7, isCurrentPeriod: true, isFuture: false)
            ]
        }
    }

    private var topCategories: [CategoryBarModel] {
        let categories = appState.screenTimeData?.topCategories ?? ScreenTimeData.mock.topCategories
        return categories.prefix(3).map { category in
            CategoryBarModel(
                id: category.id,
                name: category.name,
                minutes: Int(category.hours * 60),
                color: CategoryColorMap.color(for: category.name)
            )
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Greeting Header
                    greetingHeader
                        .padding(.top, Theme.Spacing.md)

                    // Day/Week Toggle
                    intervalPicker

                    // Clock Dial (The New Hero)
                    ClockDialView(
                        totalMinutes: displayMinutes,
                        baselineMinutes: baselineMinutes,
                        interval: selectedInterval,
                        deltaChipState: deltaChipState,
                        animationProgress: $dialAnimationProgress
                    )
                    .padding(.vertical, Theme.Spacing.md)

                    // Quiet Chart (7-day/week bar chart)
                    QuietChartView(
                        bars: chartBars,
                        baselineMinutes: selectedInterval == .day ? baselineMinutes : baselineMinutes * 7,
                        interval: selectedInterval
                    )

                    // Category Snapshot (Top 3)
                    CategorySnapshotView(categories: topCategories)

                    // Active Challenge (if any)
                    if let challenge = appState.activeChallenge {
                        ActiveChallengeSection(challenge: challenge)
                    }

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .background(ClockDialTokens.offWhite)
            .navigationBarHidden(true)
        }
        .onAppear {
            animateDial()
        }
        .onChange(of: selectedInterval) { _, _ in
            // Reset and re-animate on interval change
            dialAnimationProgress = 0
            animateDial()
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack {
            // Single-line greeting per spec: "Good morning, Marco"
            if let name = appState.userProfile?.displayName {
                Text("Good \(timeOfDay), \(name)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ClockDialTokens.deepSlate)
            } else {
                Text("Good \(timeOfDay)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ClockDialTokens.deepSlate)
            }

            Spacer()
        }
    }

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<5: return "evening"
        default: return "evening"
        }
    }

    // MARK: - Interval Picker

    private var intervalPicker: some View {
        Picker("Interval", selection: $selectedInterval) {
            ForEach(DashboardInterval.allCases, id: \.self) { interval in
                Text(interval.rawValue).tag(interval)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Animation

    private func animateDial() {
        // Animate from 0 to 1 over 1.5 seconds with ease-out
        withAnimation(.easeOut(duration: 1.5)) {
            dialAnimationProgress = 1.0
        }
    }
}

// MARK: - Active Challenge Section

struct ActiveChallengeSection: View {
    let challenge: UserChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Active Challenge")
                .font(.system(size: Theme.Typography.lg, weight: .semibold))
                .foregroundColor(ClockDialTokens.deepSlate)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Text(Challenge.morningClarity.title)
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                        .foregroundColor(ClockDialTokens.deepSlate)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Day \(challenge.dayNumber)")
                            .font(.system(size: Theme.Typography.sm, weight: .medium))

                        Image(systemName: "chevron.right")
                            .font(.system(size: Theme.Typography.xs))
                    }
                    .foregroundColor(ClockDialTokens.grey)
                }

                Text(Challenge.morningClarity.description)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(ClockDialTokens.grey)
                    .multilineTextAlignment(.leading)

                // Progress bar
                ProgressBar(
                    value: Double(challenge.dayNumber),
                    total: Double(Challenge.morningClarity.durationDays),
                    height: 6
                )
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        }
    }
}

// MARK: - Preview

#Preview {
    let appState = AppState()
    appState.userProfile = UserProfile(
        displayName: "Marco",
        ageRange: .age25to34,
        xp: 10,
        level: 1
    )
    appState.screenTimeData = .mock
    appState.activeChallenge = UserChallenge(
        challengeId: Challenge.morningClarity.id,
        userId: UUID()
    )

    return HomeView()
        .environment(appState)
}

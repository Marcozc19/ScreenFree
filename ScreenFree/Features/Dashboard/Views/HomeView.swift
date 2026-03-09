import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    // MARK: - Mock Data for Demo

    private var todayUsage: Double {
        // Simulated "live" usage that updates
        let baseline = appState.screenTimeData?.totalHours ?? 4.5
        // Today is slightly less for demo purposes
        return baseline * 0.78
    }

    private var baselineUsage: Double {
        appState.screenTimeData?.totalHours ?? 4.5
    }

    private var weeklyData: [DayUsage] {
        let baseline = baselineUsage
        return [
            DayUsage(day: "M", hours: baseline * 0.92, isToday: false),
            DayUsage(day: "T", hours: baseline * 0.85, isToday: false),
            DayUsage(day: "W", hours: baseline * 1.05, isToday: false),
            DayUsage(day: "T", hours: baseline * 0.78, isToday: false),
            DayUsage(day: "F", hours: baseline * 0.88, isToday: false),
            DayUsage(day: "S", hours: baseline * 1.12, isToday: false),
            DayUsage(day: "S", hours: todayUsage, isToday: true)
        ]
    }

    private var streakDays: Int {
        // Demo: 4 day streak
        4
    }

    private var todayCategories: [CategoryUsage] {
        appState.screenTimeData?.topCategories ?? ScreenTimeData.mock.topCategories
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // MARK: - Greeting Header
                    greetingHeader
                        .padding(.top, Theme.Spacing.md)

                    // MARK: - Today's Usage Hero Card
                    TodayUsageHeroCard(
                        todayHours: todayUsage,
                        baselineHours: baselineUsage,
                        streakDays: streakDays
                    )

                    // MARK: - 7-Day Bar Chart
                    WeeklyBarChart(
                        data: weeklyData,
                        baselineHours: baselineUsage
                    )

                    // MARK: - Category Snapshot
                    CategorySnapshot(
                        categories: todayCategories,
                        totalHours: todayUsage
                    )

                    // MARK: - Active Challenge Card
                    if let challenge = appState.activeChallenge {
                        ActiveChallengeSection(challenge: challenge)
                    }

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Good \(timeOfDay),")
                    .font(.system(size: Theme.Typography.lg))
                    .foregroundColor(Theme.Colors.mutedForeground)

                if let name = appState.userProfile?.displayName {
                    Text(name)
                        .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)
                }
            }

            Spacer()

            if let profile = appState.userProfile {
                LevelBadge(level: profile.level)
            }
        }
    }

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }
}

// MARK: - Day Usage Model

struct DayUsage: Identifiable {
    let id = UUID()
    let day: String
    let hours: Double
    let isToday: Bool
}

// MARK: - Today's Usage Hero Card

struct TodayUsageHeroCard: View {
    let todayHours: Double
    let baselineHours: Double
    let streakDays: Int

    private var delta: Double {
        ((baselineHours - todayHours) / baselineHours) * 100
    }

    private var deltaState: DeltaState {
        if abs(delta) <= 5 {
            return .neutral
        } else if delta > 0 {
            return .better
        } else {
            return .worse
        }
    }

    enum DeltaState {
        case better, worse, neutral

        var color: Color {
            switch self {
            case .better: return Theme.Colors.easyBadge
            case .worse: return Theme.Colors.destructive
            case .neutral: return Theme.Colors.mutedForeground
            }
        }

        var icon: String {
            switch self {
            case .better: return "arrow.down"
            case .worse: return "arrow.up"
            case .neutral: return "minus"
            }
        }
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Main usage display
            VStack(spacing: Theme.Spacing.xs) {
                Text("Today")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Text(formatHours(todayHours))
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(Theme.Colors.foreground)
                    .monospacedDigit()
            }

            // Comparison chip and streak
            HStack(spacing: Theme.Spacing.md) {
                // Delta chip
                HStack(spacing: Theme.Spacing.xxs) {
                    Image(systemName: deltaState.icon)
                        .font(.system(size: Theme.Typography.sm, weight: .semibold))

                    Text("\(Int(abs(delta)))% vs baseline")
                        .font(.system(size: Theme.Typography.sm, weight: .medium))
                }
                .foregroundColor(deltaState.color)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(deltaState.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))

                // Streak indicator (only show if 2+ days)
                if streakDays >= 2 {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: Theme.Typography.sm))

                        Text("Day \(streakDays) streak")
                            .font(.system(size: Theme.Typography.sm, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
        .padding(.horizontal, Theme.Spacing.lg)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
}

// MARK: - Weekly Bar Chart

struct WeeklyBarChart: View {
    let data: [DayUsage]
    let baselineHours: Double

    private var maxHours: Double {
        max(data.map { $0.hours }.max() ?? baselineHours, baselineHours * 1.1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("This Week")
                .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                .foregroundColor(Theme.Colors.foreground)

            VStack(spacing: Theme.Spacing.sm) {
                // Chart area
                GeometryReader { geometry in
                    let chartHeight: CGFloat = 120
                    let barWidth: CGFloat = (geometry.size.width - CGFloat(data.count - 1) * Theme.Spacing.sm) / CGFloat(data.count)
                    let baselineY = chartHeight * (1 - baselineHours / maxHours)

                    ZStack(alignment: .top) {
                        // Baseline reference line
                        VStack {
                            Spacer()
                                .frame(height: baselineY)

                            HStack(spacing: Theme.Spacing.xs) {
                                Rectangle()
                                    .fill(Theme.Colors.mutedForeground.opacity(0.4))
                                    .frame(height: 1)
                                    .overlay(
                                        StrokeDashPattern()
                                            .stroke(Theme.Colors.mutedForeground.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                    )
                            }

                            Spacer()
                        }

                        // Bars
                        HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                            ForEach(data) { day in
                                VStack(spacing: Theme.Spacing.xxs) {
                                    Spacer()

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(day.isToday ? Theme.Colors.primary : Theme.Colors.muted)
                                        .frame(width: barWidth, height: max(4, chartHeight * day.hours / maxHours))

                                    Text(day.day)
                                        .font(.system(size: Theme.Typography.xs, weight: day.isToday ? .semibold : .regular))
                                        .foregroundColor(day.isToday ? Theme.Colors.foreground : Theme.Colors.mutedForeground)
                                }
                            }
                        }
                    }
                    .frame(height: chartHeight + 20)
                }
                .frame(height: 140)

                // Baseline label
                HStack {
                    Spacer()
                    HStack(spacing: Theme.Spacing.xxs) {
                        Rectangle()
                            .fill(Theme.Colors.mutedForeground.opacity(0.4))
                            .frame(width: 16, height: 1)

                        Text("baseline \(formatHours(baselineHours))")
                            .font(.system(size: Theme.Typography.xs))
                            .foregroundColor(Theme.Colors.mutedForeground)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
}

// Dashed line helper
struct StrokeDashPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// MARK: - Category Snapshot

struct CategorySnapshot: View {
    let categories: [CategoryUsage]
    let totalHours: Double

    private var showEmptyState: Bool {
        totalHours < 0.5  // Less than 30 minutes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Header
            HStack {
                Text("Where your time goes")
                    .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Spacer()

                Button {
                    // Navigate to category breakdown
                } label: {
                    Text("See all")
                        .font(.system(size: Theme.Typography.sm, weight: .medium))
                        .foregroundColor(Theme.Colors.primary)
                }
            }

            if showEmptyState {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "clock")
                            .font(.system(size: 32))
                            .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

                        Text("Check back later today.")
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(Theme.Colors.mutedForeground)
                    }
                    .padding(.vertical, Theme.Spacing.xl)
                    Spacer()
                }
                .background(Theme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            } else {
                // Category bars
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(Array(categories.prefix(3).enumerated()), id: \.element.id) { index, category in
                        CategoryBar(
                            name: category.name,
                            hours: category.hours,
                            maxHours: categories.first?.hours ?? 1,
                            color: categoryColor(for: category.name)
                        )
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }

    private func categoryColor(for name: String) -> Color {
        switch name.lowercased() {
        case let n where n.contains("social"):
            return CategoryColors.social
        case let n where n.contains("video"), let n where n.contains("entertainment"):
            return CategoryColors.video
        case let n where n.contains("game"):
            return CategoryColors.games
        case let n where n.contains("health"):
            return CategoryColors.health
        case let n where n.contains("productivity"):
            return CategoryColors.productivity
        case let n where n.contains("brows"):
            return CategoryColors.browsing
        default:
            return CategoryColors.other
        }
    }
}

// Category colors as per spec
enum CategoryColors {
    static let social = Color(hex: "#3B82F6")      // accent blue
    static let video = Color(hex: "#60A5FA")       // light blue
    static let games = Color(hex: "#8B5CF6")       // purple
    static let health = Color(hex: "#22C55E")      // green
    static let productivity = Color(hex: "#14B8A6") // teal
    static let browsing = Color(hex: "#F59E0B")    // amber
    static let other = Color(hex: "#9CA3AF")       // grey
}

struct CategoryBar: View {
    let name: String
    let hours: Double
    let maxHours: Double
    let color: Color

    private var progress: Double {
        guard maxHours > 0 else { return 0 }
        return hours / maxHours
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            HStack {
                HStack(spacing: Theme.Spacing.xs) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)

                    Text(name)
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.foreground)
                }

                Spacer()

                Text(formatHours(hours))
                    .font(.system(size: Theme.Typography.sm, weight: .medium))
                    .foregroundColor(Theme.Colors.foreground)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.muted)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }
}

// MARK: - Active Challenge Section

struct ActiveChallengeSection: View {
    let challenge: UserChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Active Challenge")
                .font(.system(size: Theme.Typography.lg, weight: Theme.Typography.semibold))
                .foregroundColor(Theme.Colors.foreground)

            // Challenge card - tapping navigates to Challenges tab
            Button {
                // This would navigate to Challenges tab
                // For now, we'll handle this in MainTabView
            } label: {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text(Challenge.morningClarity.title)
                            .font(.system(size: Theme.Typography.base, weight: .semibold))
                            .foregroundColor(Theme.Colors.foreground)

                        Spacer()

                        HStack(spacing: Theme.Spacing.xxs) {
                            Text("Day \(challenge.dayNumber)")
                                .font(.system(size: Theme.Typography.sm, weight: .medium))

                            Image(systemName: "chevron.right")
                                .font(.system(size: Theme.Typography.xs))
                        }
                        .foregroundColor(Theme.Colors.mutedForeground)
                    }

                    Text(Challenge.morningClarity.description)
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
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
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
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

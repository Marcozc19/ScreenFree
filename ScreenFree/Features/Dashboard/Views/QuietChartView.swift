import SwiftUI

// MARK: - Chart Bar Model

struct ChartBarModel: Identifiable {
    let id = UUID()
    let label: String
    let minutes: Int
    let isCurrentPeriod: Bool
    let isFuture: Bool

    var hours: Double {
        Double(minutes) / 60.0
    }
}

// MARK: - Quiet Chart View (7-Day/Week Bar Chart)

struct QuietChartView: View {
    let bars: [ChartBarModel]
    let baselineMinutes: Int
    let interval: DashboardInterval

    private var maxMinutes: Int {
        // Y-axis scales to peak usage, not baseline
        let peak = bars.map { $0.minutes }.max() ?? baselineMinutes
        return max(peak, baselineMinutes)
    }

    private var chartHeight: CGFloat { 100 }
    private var barWidth: CGFloat { 28 }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Section header
            Text(interval == .day ? "Past 7 Days" : "Past 7 Weeks")
                .font(.system(size: Theme.Typography.lg, weight: .semibold))
                .foregroundColor(ClockDialTokens.deepSlate)

            // Chart container
            GeometryReader { geometry in
                let availableWidth = geometry.size.width
                let totalBarsWidth = barWidth * CGFloat(bars.count)
                let totalSpacing = availableWidth - totalBarsWidth
                let spacing = totalSpacing / CGFloat(bars.count - 1)

                ZStack(alignment: .bottom) {
                    // Baseline dashed line
                    if maxMinutes > 0 {
                        let baselineY = chartHeight * CGFloat(baselineMinutes) / CGFloat(maxMinutes)
                        VStack {
                            Spacer()
                            Rectangle()
                                .stroke(
                                    ClockDialTokens.deepSlate.opacity(0.4),
                                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                                )
                                .frame(height: 1)
                                .offset(y: -baselineY)
                        }
                    }

                    // Bars
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(bars) { bar in
                            VStack(spacing: 4) {
                                // Bar
                                let barHeight = maxMinutes > 0
                                    ? max(4, chartHeight * CGFloat(bar.minutes) / CGFloat(maxMinutes))
                                    : 4

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor(for: bar))
                                    .frame(width: barWidth, height: barHeight)

                                // Label
                                Text(bar.label)
                                    .font(.system(size: 11, weight: bar.isCurrentPeriod ? .semibold : .regular))
                                    .foregroundColor(bar.isCurrentPeriod ? ClockDialTokens.deepSlate : ClockDialTokens.grey)
                            }
                        }
                    }
                }
            }
            .frame(height: chartHeight + 20) // Extra space for labels
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }

    private func barColor(for bar: ChartBarModel) -> Color {
        if bar.isFuture || bar.minutes == 0 {
            return Color(hex: "#E5E5EA") // Light grey for future/missing
        } else if bar.isCurrentPeriod {
            return ClockDialTokens.accentBlue
        } else {
            return Color(hex: "#C7C7CC") // Neutral grey for historical
        }
    }
}

// MARK: - Preview

#Preview("Quiet Chart - Day Context") {
    let bars = [
        ChartBarModel(label: "M", minutes: 248, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "T", minutes: 230, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W", minutes: 284, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "T", minutes: 211, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "F", minutes: 238, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "S", minutes: 302, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "S", minutes: 192, isCurrentPeriod: true, isFuture: false)
    ]

    QuietChartView(
        bars: bars,
        baselineMinutes: 270,
        interval: .day
    )
    .padding()
    .background(Color(hex: "#F8F8F6"))
}

#Preview("Quiet Chart - Week Context") {
    let bars = [
        ChartBarModel(label: "W1", minutes: 1680, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W2", minutes: 1540, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W3", minutes: 1820, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W4", minutes: 1600, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W5", minutes: 1720, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W6", minutes: 1480, isCurrentPeriod: false, isFuture: false),
        ChartBarModel(label: "W7", minutes: 1380, isCurrentPeriod: true, isFuture: false)
    ]

    QuietChartView(
        bars: bars,
        baselineMinutes: 1680,
        interval: .week
    )
    .padding()
    .background(Color(hex: "#F8F8F6"))
}

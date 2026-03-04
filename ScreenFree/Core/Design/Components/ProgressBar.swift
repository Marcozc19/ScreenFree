import SwiftUI

struct ProgressBar: View {
    let value: Double
    let total: Double
    var height: CGFloat = 8
    var backgroundColor: Color = Theme.Colors.muted
    var foregroundColor: Color = Theme.Colors.primary
    var animated: Bool = true

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(max(value / total, 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(animated ? .easeInOut(duration: Theme.Animation.normal) : nil, value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - XP Progress Bar

struct XPProgressBar: View {
    let currentXP: Int
    let requiredXP: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            ProgressBar(
                value: Double(currentXP),
                total: Double(requiredXP),
                height: 6
            )

            Text("\(currentXP)/\(requiredXP) XP")
                .font(.system(size: Theme.Typography.xs))
                .foregroundColor(Theme.Colors.mutedForeground)
        }
    }
}

// MARK: - Category Progress Bar

struct CategoryProgressBar: View {
    let category: String
    let hours: Double
    let maxHours: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            HStack {
                Text(category)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.foreground)

                Spacer()

                Text(formatHours(hours))
                    .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                    .foregroundColor(Theme.Colors.foreground)
            }

            ProgressBar(
                value: hours,
                total: maxHours,
                height: 8,
                foregroundColor: color
            )
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

// MARK: - Animated Counter

struct AnimatedCounter: View {
    let targetValue: Double
    let duration: Double
    var prefix: String = ""
    var suffix: String = ""
    var format: CounterFormat = .hoursMinutes

    @State private var displayValue: Double = 0
    @State private var hasAnimated = false

    enum CounterFormat {
        case hoursMinutes
        case decimal
        case integer

        func format(_ value: Double) -> String {
            switch self {
            case .hoursMinutes:
                let hours = Int(value)
                let minutes = Int((value - Double(hours)) * 60)
                return "\(hours)h \(minutes)m"
            case .decimal:
                return String(format: "%.1f", value)
            case .integer:
                return "\(Int(value))"
            }
        }
    }

    var body: some View {
        Text("\(prefix)\(format.format(displayValue))\(suffix)")
            .onAppear {
                guard !hasAnimated else { return }
                hasAnimated = true
                animateValue()
            }
    }

    private func animateValue() {
        let steps = 60
        let stepDuration = duration / Double(steps)
        let increment = targetValue / Double(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.linear(duration: stepDuration)) {
                    if step == steps {
                        displayValue = targetValue
                    } else {
                        displayValue = increment * Double(step)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Theme.Spacing.xl) {
        ProgressBar(value: 30, total: 100)

        ProgressBar(value: 75, total: 100, height: 12)

        XPProgressBar(currentXP: 10, requiredXP: 100)

        CategoryProgressBar(
            category: "Social Media",
            hours: 2.5,
            maxHours: 5,
            color: Theme.Colors.chart1
        )

        CategoryProgressBar(
            category: "Entertainment",
            hours: 1.75,
            maxHours: 5,
            color: Theme.Colors.chart2
        )

        AnimatedCounter(
            targetValue: 4.5,
            duration: 1.5,
            format: .hoursMinutes
        )
        .font(.system(size: Theme.Typography.display, weight: Theme.Typography.bold))
    }
    .padding()
}

import SwiftUI

// MARK: - Dashboard Interval

enum DashboardInterval: String, CaseIterable {
    case day = "Today"
    case week = "This Week"
}

// MARK: - Delta Chip State

enum DeltaChipState: Equatable {
    case belowBaseline(minutes: Int)
    case aboveBaseline(minutes: Int)
    case onTrack
    case pending
    case noData

    var backgroundColor: Color {
        switch self {
        case .belowBaseline: return Color(hex: "#E6F4EA")
        case .aboveBaseline: return Color(hex: "#FFF0EE")
        case .onTrack, .pending: return Color(hex: "#F2F2F7")
        case .noData: return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .belowBaseline: return Color(hex: "#34C759")
        case .aboveBaseline: return Color(hex: "#FF3B30")
        case .onTrack, .pending: return Color(hex: "#8E8E93")
        case .noData: return .clear
        }
    }

    var icon: String? {
        switch self {
        case .belowBaseline: return "arrow.down"
        case .aboveBaseline: return "arrow.up"
        default: return nil
        }
    }

    var label: String {
        switch self {
        case .belowBaseline(let minutes):
            return "↓ \(formatMinutes(minutes)) below baseline"
        case .aboveBaseline(let minutes):
            return "↑ \(formatMinutes(minutes)) over baseline"
        case .onTrack:
            return "On track"
        case .pending:
            return "Baseline pending"
        case .noData:
            return ""
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Design Tokens

enum ClockDialTokens {
    static let deepSlate = Color(hex: "#1E2A3A")
    static let accentBlue = Color(hex: "#007AFF")
    static let neutralGrey = Color(hex: "#E5E5EA")
    static let offWhite = Color(hex: "#F8F8F6")
    static let grey = Color(hex: "#8E8E93")

    static let dialDiameter: CGFloat = 220
    static let strokeWidth: CGFloat = 6
    static let maxArcDegrees: CGFloat = 330
    static let gapDegrees: CGFloat = 30
}

// MARK: - Clock Dial View

struct ClockDialView: View {
    let totalMinutes: Int
    let baselineMinutes: Int
    let interval: DashboardInterval
    let deltaChipState: DeltaChipState
    @Binding var animationProgress: Double

    // Computed properties
    private var displayTime: String {
        // Show final time immediately - only the arc animates
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if interval == .week {
            return "\(h)h \(m)m avg"
        }
        return "\(h)h \(m)m"
    }

    private var dailyCap: Int {
        max(baselineMinutes * 2, 480) // 8 hours minimum cap
    }

    private var arcProgress: Double {
        let progress = Double(totalMinutes) / Double(dailyCap)
        return min(progress, 1.0) * animationProgress
    }

    private var dialFillColor: Color {
        interval == .day ? ClockDialTokens.accentBlue : ClockDialTokens.deepSlate
    }

    var body: some View {
        ZStack {
            // Track (background circle)
            Circle()
                .trim(from: 0, to: ClockDialTokens.maxArcDegrees / 360)
                .stroke(
                    ClockDialTokens.neutralGrey,
                    style: StrokeStyle(lineWidth: ClockDialTokens.strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(135)) // Start from bottom-left
                .frame(width: ClockDialTokens.dialDiameter, height: ClockDialTokens.dialDiameter)

            // Fill (progress arc)
            Circle()
                .trim(from: 0, to: arcProgress * (ClockDialTokens.maxArcDegrees / 360))
                .stroke(
                    dialFillColor,
                    style: StrokeStyle(lineWidth: ClockDialTokens.strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .frame(width: ClockDialTokens.dialDiameter, height: ClockDialTokens.dialDiameter)

            // Interior background
            Circle()
                .fill(ClockDialTokens.offWhite)
                .frame(width: ClockDialTokens.dialDiameter - ClockDialTokens.strokeWidth * 4)

            // Center content
            VStack(spacing: 8) {
                // Time readout
                Text(displayTime)
                    .font(.system(size: 42, weight: .bold, design: .default))
                    .foregroundColor(ClockDialTokens.deepSlate)
                    .monospacedDigit()

                // Delta chip (inside the dial)
                if deltaChipState != .noData {
                    DeltaChipView(state: deltaChipState)
                }
            }
        }
        .frame(width: ClockDialTokens.dialDiameter + 20, height: ClockDialTokens.dialDiameter + 20)
    }
}

// MARK: - Delta Chip View

struct DeltaChipView: View {
    let state: DeltaChipState

    var body: some View {
        if state != .noData {
            Text(state.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(state.foregroundColor)
                .padding(.horizontal, 14)
                .frame(height: 28)
                .background(state.backgroundColor)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Previews

#Preview("Clock Dial - Day") {
    VStack(spacing: 40) {
        ClockDialView(
            totalMinutes: 192, // 3h 12m
            baselineMinutes: 270,
            interval: .day,
            deltaChipState: .belowBaseline(minutes: 78),
            animationProgress: .constant(1.0)
        )

        ClockDialView(
            totalMinutes: 320,
            baselineMinutes: 270,
            interval: .day,
            deltaChipState: .aboveBaseline(minutes: 50),
            animationProgress: .constant(1.0)
        )
    }
    .padding()
    .background(Color(hex: "#F8F8F6"))
}

#Preview("Clock Dial - Week") {
    ClockDialView(
        totalMinutes: 168, // 2h 48m avg
        baselineMinutes: 270,
        interval: .week,
        deltaChipState: .onTrack,
        animationProgress: .constant(1.0)
    )
    .padding()
    .background(Color(hex: "#F8F8F6"))
}

#Preview("Delta Chips") {
    VStack(spacing: 16) {
        DeltaChipView(state: .belowBaseline(minutes: 42))
        DeltaChipView(state: .aboveBaseline(minutes: 18))
        DeltaChipView(state: .onTrack)
        DeltaChipView(state: .pending)
    }
    .padding()
    .background(Color(hex: "#F8F8F6"))
}

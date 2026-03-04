import Foundation

enum FramingCopy {
    // MARK: - Screen Time Formatting

    static func formatScreenTime(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }

    // MARK: - Mirror Screen Messages

    static func mirrorMessage(forHours hours: Double) -> String {
        switch hours {
        case 0..<2:
            return "You're already doing great! Let's help you maintain these healthy habits."
        case 2..<4:
            return "You have a solid foundation. Small adjustments can make a big difference."
        case 4..<6:
            return "This is typical for most people. You're in the right place to make a change."
        case 6..<8:
            return "That's a significant amount of screen time. Let's work together to reclaim some of your day."
        default:
            return "You've got a real opportunity here. Even small reductions will feel amazing."
        }
    }

    // MARK: - Welcome Messages

    static func welcomeMessage(displayName: String) -> String {
        "Welcome, \(displayName)! You're all set to start your screen-free journey."
    }

    // MARK: - Tips

    static let onboardingTip = "Start small. Reducing just 15 minutes a day adds up to over 90 hours a year."
}

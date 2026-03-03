import Foundation

enum AgeRange: String, CaseIterable, Codable, Identifiable {
    case under18 = "under_18"
    case age18to24 = "18_24"
    case age25to34 = "25_34"
    case age35plus = "35_plus"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .under18:
            return "Under 18"
        case .age18to24:
            return "18-24"
        case .age25to34:
            return "25-34"
        case .age35plus:
            return "35+"
        }
    }
}

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var displayName: String
    var ageRange: AgeRange
    var xp: Int
    var level: Int
    var baselineScreenTime: Double?  // hours per day
    var onboardingCompleted: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        ageRange: AgeRange,
        xp: Int = 0,
        level: Int = 1,
        baselineScreenTime: Double? = nil,
        onboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.ageRange = ageRange
        self.xp = xp
        self.level = level
        self.baselineScreenTime = baselineScreenTime
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var xpForNextLevel: Int {
        100 * level  // 100 XP per level
    }

    var xpProgress: Double {
        Double(xp) / Double(xpForNextLevel)
    }

    static let displayNamePattern = "^[a-zA-Z0-9_]{2,20}$"

    static func validateDisplayName(_ name: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: displayNamePattern)
        let range = NSRange(name.startIndex..., in: name)
        return regex?.firstMatch(in: name, range: range) != nil
    }
}

extension UserProfile {
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case ageRange = "age_range"
        case xp
        case level
        case baselineScreenTime = "baseline_screen_time"
        case onboardingCompleted = "onboarding_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

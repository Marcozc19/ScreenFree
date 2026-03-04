import Foundation

enum ChallengeDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard

    var displayName: String {
        rawValue.capitalized
    }
}

enum ChallengeStatus: String, Codable {
    case pending
    case active
    case completed
    case failed
}

struct Challenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: ChallengeDifficulty
    let durationDays: Int
    let xpReward: Int
    let quote: String?

    init(
        id: String,
        title: String,
        description: String,
        difficulty: ChallengeDifficulty,
        durationDays: Int,
        xpReward: Int,
        quote: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.durationDays = durationDays
        self.xpReward = xpReward
        self.quote = quote
    }

    var durationDisplay: String {
        durationDays == 1 ? "1 day" : "\(durationDays) days"
    }

    // MARK: - Predefined Challenges

    static let morningClarity = Challenge(
        id: "morning_clarity",
        title: "Morning Clarity",
        description: "No phone for the first hour after waking",
        difficulty: .easy,
        durationDays: 7,
        xpReward: 50,
        quote: "The morning is wiser than the evening."
    )
}

struct UserChallenge: Identifiable, Codable {
    let id: UUID
    let challengeId: String
    let userId: UUID
    var status: ChallengeStatus
    let startedAt: Date
    var completedAt: Date?
    var progress: Int  // days completed

    init(
        id: UUID = UUID(),
        challengeId: String,
        userId: UUID,
        status: ChallengeStatus = .active,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        progress: Int = 0
    ) {
        self.id = id
        self.challengeId = challengeId
        self.userId = userId
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.progress = progress
    }

    var dayNumber: Int {
        progress + 1
    }
}

extension UserChallenge {
    enum CodingKeys: String, CodingKey {
        case id
        case challengeId = "challenge_id"
        case userId = "user_id"
        case status
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case progress
    }
}

import Foundation

// MARK: - Group Record

/// Represents an accountability group that enables screen time sharing between members.
/// NOTE: Group membership is the ONLY mechanism for data sharing - friends alone grant no access.
struct GroupRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var groupName: String
    var inviteCode: String?  // Only populated for admin
    var isAdmin: Bool
    var memberCount: Int
    var userCurrentRank: Int?  // Nil if Data Unavailable
    let createdAt: Date
    var lastSyncedAt: Date

    init(
        id: UUID = UUID(),
        groupName: String,
        inviteCode: String? = nil,
        isAdmin: Bool = false,
        memberCount: Int = 1,
        userCurrentRank: Int? = nil,
        createdAt: Date = Date(),
        lastSyncedAt: Date = Date()
    ) {
        self.id = id
        self.groupName = groupName
        self.inviteCode = inviteCode
        self.isAdmin = isAdmin
        self.memberCount = memberCount
        self.userCurrentRank = userCurrentRank
        self.createdAt = createdAt
        self.lastSyncedAt = lastSyncedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case inviteCode = "invite_code"
        case isAdmin = "is_admin"
        case memberCount = "member_count"
        case userCurrentRank = "user_current_rank"
        case createdAt = "created_at"
        case lastSyncedAt = "last_synced_at"
    }
}

// MARK: - Group Member

/// Represents a member in a group (used for admin management)
struct GroupMember: Identifiable, Codable, Equatable {
    let id: UUID  // user_id
    let displayName: String
    let joinedAt: Date
    var isAdmin: Bool

    init(
        id: UUID,
        displayName: String,
        joinedAt: Date = Date(),
        isAdmin: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.joinedAt = joinedAt
        self.isAdmin = isAdmin
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case joinedAt = "joined_at"
        case isAdmin = "is_admin"
    }
}

// MARK: - Leaderboard Member Snapshot

/// In-memory snapshot of a group member's screen time data for the leaderboard.
/// Populated fresh on each GroupDetailView appearance - never persisted.
struct LeaderboardMemberSnapshot: Identifiable, Equatable {
    let id: UUID  // Unique snapshot ID
    let userId: UUID
    let displayName: String
    var rank: Int?  // Nil if isDataUnavailable
    var todayMinutes: Int?  // Nil if day incomplete or unavailable
    var weeklyAvgMinutes: Double?  // Rolling 7-day average
    var topCategories: [CategoryUsage]
    var isDataUnavailable: Bool
    var isStale: Bool  // True if lastSyncedAt > 60 minutes ago
    var lastSyncedAt: Date?
    var isCurrentUser: Bool

    init(
        id: UUID = UUID(),
        userId: UUID,
        displayName: String,
        rank: Int? = nil,
        todayMinutes: Int? = nil,
        weeklyAvgMinutes: Double? = nil,
        topCategories: [CategoryUsage] = [],
        isDataUnavailable: Bool = false,
        isStale: Bool = false,
        lastSyncedAt: Date? = nil,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.rank = rank
        self.todayMinutes = todayMinutes
        self.weeklyAvgMinutes = weeklyAvgMinutes
        self.topCategories = topCategories
        self.isDataUnavailable = isDataUnavailable
        self.isStale = isStale
        self.lastSyncedAt = lastSyncedAt
        self.isCurrentUser = isCurrentUser
    }

    // MARK: - Formatted Values

    var formattedTodayTime: String {
        guard let mins = todayMinutes else { return "—" }
        return Self.formatMinutes(mins)
    }

    var formattedWeeklyAvgTime: String {
        guard let mins = weeklyAvgMinutes else { return "—" }
        return Self.formatMinutes(Int(mins))
    }

    static func formatMinutes(_ mins: Int) -> String {
        let hours = mins / 60
        let minutes = mins % 60
        return "\(hours)h \(String(format: "%02d", minutes))m"
    }
}

// MARK: - Time Window

enum TimeWindow: String, CaseIterable {
    case today = "Today"
    case last7Days = "Last 7 Days"
    case previousWeek = "Prev Week"
}

// MARK: - Group Invite

/// Represents a pending group invitation received from a friend
struct GroupInvite: Identifiable, Equatable {
    let id: UUID
    let groupId: UUID
    let groupName: String
    let inviterDisplayName: String
    let memberCount: Int
    let receivedAt: Date

    init(
        id: UUID = UUID(),
        groupId: UUID,
        groupName: String,
        inviterDisplayName: String,
        memberCount: Int,
        receivedAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.groupName = groupName
        self.inviterDisplayName = inviterDisplayName
        self.memberCount = memberCount
        self.receivedAt = receivedAt
    }
}

// MARK: - Join Group Result

enum JoinGroupResult: Equatable {
    case success(GroupRecord)
    case invalidCode
    case alreadyMember
    case groupFull

    var errorMessage: String? {
        switch self {
        case .invalidCode:
            return "Invalid code. Please check with your group admin."
        case .alreadyMember:
            return "You are already in this group."
        case .groupFull:
            return "This group is full. Ask the admin to remove a member."
        case .success:
            return nil
        }
    }
}

// MARK: - Comparison State

/// Used in group leaderboard to show relative performance comparison
enum ComparisonState: Equatable {
    case better(percentDiff: Int)
    case worse(percentDiff: Int)
    case similar
    case unavailable

    var displayText: String {
        switch self {
        case .better(let percentDiff):
            return "\(percentDiff)% less"
        case .worse(let percentDiff):
            return "\(percentDiff)% more"
        case .similar:
            return "Similar"
        case .unavailable:
            return "—"
        }
    }
}

import Foundation

// MARK: - Friend Status

enum FriendStatus: String, Codable, CaseIterable {
    case pendingOutgoing = "pending_outgoing"
    case pendingIncoming = "pending_incoming"
    case accepted = "accepted"
    case blocked = "blocked"

    var displayName: String {
        switch self {
        case .pendingOutgoing:
            return "Request Sent"
        case .pendingIncoming:
            return "Pending Request"
        case .accepted:
            return "Accountability Partner"
        case .blocked:
            return "Blocked"
        }
    }
}

// MARK: - Friend Record

/// Represents a friendship relationship between two users.
/// NOTE: Friends grant ZERO data access. Only shared group membership enables data sharing.
struct FriendRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let requesterId: UUID
    let recipientId: UUID
    var status: FriendStatus
    var displayName: String
    var serverFriendshipId: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        requesterId: UUID,
        recipientId: UUID,
        status: FriendStatus,
        displayName: String,
        serverFriendshipId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.requesterId = requesterId
        self.recipientId = recipientId
        self.status = status
        self.displayName = displayName
        self.serverFriendshipId = serverFriendshipId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Returns the friend's user ID (the other person in the relationship)
    func friendUserId(currentUserId: UUID) -> UUID {
        requesterId == currentUserId ? recipientId : requesterId
    }
}

extension FriendRecord {
    enum CodingKeys: String, CodingKey {
        case id
        case requesterId = "requester_id"
        case recipientId = "recipient_id"
        case status
        case displayName = "display_name"
        case serverFriendshipId = "server_friendship_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Friend Search Result

enum FriendSearchResult: Equatable {
    case idle
    case loading
    case found(UserSearchMatch)
    case notFound
    case selfSearch
    case alreadyFriend
    case requestAlreadySent

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .notFound:
            return "No user found with that ID."
        case .selfSearch:
            return "You cannot add yourself."
        case .alreadyFriend:
            return "Already your accountability partner."
        case .requestAlreadySent:
            return "Request already sent."
        default:
            return nil
        }
    }
}

// MARK: - User Search Match

struct UserSearchMatch: Identifiable, Equatable, Codable {
    let id: UUID
    let displayName: String
    let userIdHandle: String

    init(id: UUID, displayName: String, userIdHandle: String) {
        self.id = id
        self.displayName = displayName
        self.userIdHandle = userIdHandle
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case userIdHandle = "user_id_handle"
    }
}

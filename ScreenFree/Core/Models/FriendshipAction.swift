import Foundation

// MARK: - Friendship Action Type

enum FriendshipActionType: String, Codable {
    case sendRequest = "send_request"
    case acceptRequest = "accept_request"
    case declineRequest = "decline_request"
    case cancelRequest = "cancel_request"
    case unfriend = "unfriend"
    case block = "block"
    case unblock = "unblock"
}

// MARK: - Pending Friendship Action

/// Represents a queued friendship action for offline support
struct PendingFriendshipAction: Identifiable, Codable {
    let id: UUID
    let actionType: FriendshipActionType
    let targetUserId: UUID
    let friendRecordId: UUID?
    let createdAt: Date
    var retryCount: Int

    init(
        id: UUID = UUID(),
        actionType: FriendshipActionType,
        targetUserId: UUID,
        friendRecordId: UUID? = nil,
        createdAt: Date = Date(),
        retryCount: Int = 0
    ) {
        self.id = id
        self.actionType = actionType
        self.targetUserId = targetUserId
        self.friendRecordId = friendRecordId
        self.createdAt = createdAt
        self.retryCount = retryCount
    }

    var maxRetries: Int { 3 }

    var canRetry: Bool {
        retryCount < maxRetries
    }

    func incrementingRetry() -> PendingFriendshipAction {
        var copy = self
        copy.retryCount += 1
        return copy
    }
}

extension PendingFriendshipAction {
    enum CodingKeys: String, CodingKey {
        case id
        case actionType = "action_type"
        case targetUserId = "target_user_id"
        case friendRecordId = "friend_record_id"
        case createdAt = "created_at"
        case retryCount = "retry_count"
    }
}

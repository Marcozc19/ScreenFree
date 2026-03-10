import Foundation

// MARK: - Social Service Protocol

/// Protocol defining all social operations.
/// Methods mirror Supabase Edge Function signatures for easy migration.
protocol SocialServiceProtocol {
    // MARK: - Friend Operations

    /// Search for a user by their exact UserID handle
    /// Edge Function: POST /functions/v1/search-user
    func searchUser(query: String, currentUserId: UUID) async throws -> FriendSearchResult

    /// Send a friend request to another user
    /// Edge Function: POST /functions/v1/send-friend-request
    func sendFriendRequest(to recipientId: UUID, from requesterId: UUID) async throws -> FriendRecord

    /// Respond to a friend request (accept or decline)
    /// Edge Function: POST /functions/v1/respond-friend-request
    func respondToFriendRequest(friendshipId: UUID, action: FriendRequestAction) async throws

    /// Get all friends for the current user
    func getFriends(forUserId userId: UUID) async throws -> [FriendRecord]

    /// Remove a friend (unfriend)
    func removeFriend(friendshipId: UUID) async throws

    /// Block a user
    func blockUser(friendshipId: UUID) async throws

    // MARK: - Group Operations

    /// Create a new group
    /// Edge Function: POST /functions/v1/create-group
    func createGroup(name: String, adminId: UUID) async throws -> GroupRecord

    /// Join a group via invite code
    /// Edge Function: POST /functions/v1/join-group
    func joinGroup(inviteCode: String, userId: UUID) async throws -> JoinGroupResult

    /// Leave a group
    /// Edge Function: POST /functions/v1/leave-group
    func leaveGroup(groupId: UUID, userId: UUID) async throws

    /// Get all groups for the current user
    func getGroups(forUserId userId: UUID) async throws -> [GroupRecord]

    /// Get leaderboard data for a group
    func getLeaderboard(groupId: UUID, timeWindow: TimeWindow, currentUserId: UUID) async throws -> [LeaderboardMemberSnapshot]

    /// Get group members (for admin management)
    func getGroupMembers(groupId: UUID) async throws -> [GroupMember]

    // MARK: - Group Admin Operations

    /// Update group settings (admin only)
    /// Edge Function: POST /functions/v1/update-group
    func updateGroup(groupId: UUID, newName: String?, regenerateCode: Bool) async throws -> GroupRecord

    /// Remove a member from the group (admin only)
    /// Edge Function: POST /functions/v1/remove-group-member
    func removeGroupMember(groupId: UUID, targetUserId: UUID) async throws

    /// Transfer admin role to another member
    func transferAdmin(groupId: UUID, newAdminId: UUID) async throws

    /// Delete the group (admin only)
    func deleteGroup(groupId: UUID) async throws

    // MARK: - Group Invites

    /// Send a group invite to a friend
    /// Edge Function: POST /functions/v1/send-group-invite
    func sendGroupInvite(groupId: UUID, recipientUserId: UUID, senderId: UUID) async throws

    /// Get pending group invites for the current user
    func getPendingGroupInvites(forUserId userId: UUID) async throws -> [GroupInvite]

    /// Respond to a group invite
    func respondToGroupInvite(inviteId: UUID, accept: Bool, userId: UUID) async throws
}

// MARK: - Friend Request Action

enum FriendRequestAction: String {
    case accept
    case decline
}

// MARK: - Social Service Error

enum SocialServiceError: LocalizedError {
    case userNotFound
    case selfFriendRequest
    case alreadyFriends
    case requestAlreadySent
    case requestNotFound
    case friendNotFound
    case groupNotFound
    case invalidInviteCode
    case alreadyInGroup
    case groupFull
    case notGroupAdmin
    case notGroupMember
    case cannotRemoveSelf
    case networkError(String)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No user found with that ID."
        case .selfFriendRequest:
            return "You cannot add yourself."
        case .alreadyFriends:
            return "Already your accountability partner."
        case .requestAlreadySent:
            return "Request already sent."
        case .requestNotFound:
            return "Friend request not found."
        case .friendNotFound:
            return "Friend not found."
        case .groupNotFound:
            return "Group not found."
        case .invalidInviteCode:
            return "Invalid code. Please check with your group admin."
        case .alreadyInGroup:
            return "You are already in this group."
        case .groupFull:
            return "This group is full. Ask the admin to remove a member."
        case .notGroupAdmin:
            return "Only the group admin can perform this action."
        case .notGroupMember:
            return "You are not a member of this group."
        case .cannotRemoveSelf:
            return "Use 'Leave Group' to remove yourself."
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Mock Social Service

/// Demo implementation of SocialService using in-memory storage.
/// Replace with SupabaseSocialService for production.
@MainActor
final class MockSocialService: SocialServiceProtocol {
    static let shared = MockSocialService()

    // MARK: - Demo Storage

    private var friends: [FriendRecord] = []
    private var groups: [GroupRecord] = []
    private var groupMemberships: [UUID: Set<UUID>] = [:]  // groupId -> Set of userIds
    private var groupInvites: [GroupInvite] = []
    private var demoUsers: [UserSearchMatch] = []

    // MARK: - UserDefaults Keys

    private let friendsKey = "SocialDemo_Friends"
    private let groupsKey = "SocialDemo_Groups"
    private let membershipsKey = "SocialDemo_Memberships"
    private let hasSeededKey = "SocialDemo_Seeded"

    // MARK: - Initialization

    private init() {
        loadFromStorage()
        setupDemoUsers()
    }

    // MARK: - Demo Data Setup

    private func setupDemoUsers() {
        demoUsers = [
            UserSearchMatch(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, displayName: "Sarah", userIdHandle: "sarah_mindful"),
            UserSearchMatch(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, displayName: "Mike", userIdHandle: "mike_focused"),
            UserSearchMatch(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, displayName: "Emma", userIdHandle: "emma_digital"),
            UserSearchMatch(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, displayName: "Alex", userIdHandle: "alex_screen"),
            UserSearchMatch(id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, displayName: "Jordan", userIdHandle: "jordan_free")
        ]
    }

    func seedDemoData(currentUserId: UUID) {
        guard !UserDefaults.standard.bool(forKey: hasSeededKey) else { return }

        let sarahId = demoUsers[0].id
        let mikeId = demoUsers[1].id
        let emmaId = demoUsers[2].id

        // Create demo friendships
        friends = [
            FriendRecord(
                requesterId: sarahId,
                recipientId: currentUserId,
                status: .accepted,
                displayName: "Sarah"
            ),
            FriendRecord(
                requesterId: currentUserId,
                recipientId: mikeId,
                status: .accepted,
                displayName: "Mike"
            ),
            FriendRecord(
                requesterId: emmaId,
                recipientId: currentUserId,
                status: .pendingIncoming,
                displayName: "Emma"
            )
        ]

        // Create a demo group
        let groupId = UUID()
        let inviteCode = generateInviteCode()

        groups = [
            GroupRecord(
                id: groupId,
                groupName: "Morning Crew",
                inviteCode: inviteCode,
                isAdmin: true,
                memberCount: 3,
                userCurrentRank: 2,
                createdAt: Date().addingTimeInterval(-86400 * 7)
            )
        ]

        groupMemberships[groupId] = [currentUserId, sarahId, mikeId]

        saveToStorage()
        UserDefaults.standard.set(true, forKey: hasSeededKey)
    }

    // MARK: - Friend Operations

    func searchUser(query: String, currentUserId: UUID) async throws -> FriendSearchResult {
        try await simulateNetworkDelay()

        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return .idle }

        // Check for self-search
        if let selfMatch = demoUsers.first(where: { $0.userIdHandle.lowercased() == normalizedQuery && $0.id == currentUserId }) {
            return .selfSearch
        }

        // Search by userIdHandle
        guard let foundUser = demoUsers.first(where: { $0.userIdHandle.lowercased() == normalizedQuery && $0.id != currentUserId }) else {
            return .notFound
        }

        // Check for existing friendship
        if let existingFriend = friends.first(where: {
            ($0.requesterId == foundUser.id || $0.recipientId == foundUser.id) &&
            ($0.requesterId == currentUserId || $0.recipientId == currentUserId)
        }) {
            switch existingFriend.status {
            case .accepted:
                return .alreadyFriend
            case .pendingOutgoing, .pendingIncoming:
                return .requestAlreadySent
            case .blocked:
                return .notFound  // Hide blocked users
            }
        }

        return .found(foundUser)
    }

    func sendFriendRequest(to recipientId: UUID, from requesterId: UUID) async throws -> FriendRecord {
        try await simulateNetworkDelay()

        guard recipientId != requesterId else {
            throw SocialServiceError.selfFriendRequest
        }

        // Get display name from demo users
        let displayName = demoUsers.first(where: { $0.id == recipientId })?.displayName ?? "User"

        let record = FriendRecord(
            requesterId: requesterId,
            recipientId: recipientId,
            status: .pendingOutgoing,
            displayName: displayName
        )

        friends.append(record)
        saveToStorage()

        return record
    }

    func respondToFriendRequest(friendshipId: UUID, action: FriendRequestAction) async throws {
        try await simulateNetworkDelay()

        guard let index = friends.firstIndex(where: { $0.id == friendshipId }) else {
            throw SocialServiceError.requestNotFound
        }

        switch action {
        case .accept:
            friends[index].status = .accepted
            friends[index].updatedAt = Date()
        case .decline:
            friends.remove(at: index)
        }

        saveToStorage()
    }

    func getFriends(forUserId userId: UUID) async throws -> [FriendRecord] {
        try await simulateNetworkDelay(short: true)
        return friends.filter {
            ($0.requesterId == userId || $0.recipientId == userId) && $0.status != .blocked
        }
    }

    func removeFriend(friendshipId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let index = friends.firstIndex(where: { $0.id == friendshipId }) else {
            throw SocialServiceError.friendNotFound
        }

        friends.remove(at: index)
        saveToStorage()
    }

    func blockUser(friendshipId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let index = friends.firstIndex(where: { $0.id == friendshipId }) else {
            throw SocialServiceError.friendNotFound
        }

        friends[index].status = .blocked
        friends[index].updatedAt = Date()
        saveToStorage()
    }

    // MARK: - Group Operations

    func createGroup(name: String, adminId: UUID) async throws -> GroupRecord {
        try await simulateNetworkDelay()

        let inviteCode = generateInviteCode()
        let group = GroupRecord(
            groupName: name,
            inviteCode: inviteCode,
            isAdmin: true,
            memberCount: 1,
            userCurrentRank: 1
        )

        groups.append(group)
        groupMemberships[group.id] = [adminId]
        saveToStorage()

        return group
    }

    func joinGroup(inviteCode: String, userId: UUID) async throws -> JoinGroupResult {
        try await simulateNetworkDelay()

        let normalizedCode = inviteCode.uppercased()

        guard let groupIndex = groups.firstIndex(where: { $0.inviteCode?.uppercased() == normalizedCode }) else {
            return .invalidCode
        }

        var group = groups[groupIndex]

        if groupMemberships[group.id]?.contains(userId) == true {
            return .alreadyMember
        }

        if group.memberCount >= 10 {
            return .groupFull
        }

        // Add member
        groupMemberships[group.id, default: []].insert(userId)
        group.memberCount += 1
        group.userCurrentRank = group.memberCount  // Start at bottom
        groups[groupIndex] = group

        saveToStorage()

        return .success(group)
    }

    func leaveGroup(groupId: UUID, userId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let index = groups.firstIndex(where: { $0.id == groupId }) else {
            throw SocialServiceError.groupNotFound
        }

        groupMemberships[groupId]?.remove(userId)
        groups[index].memberCount -= 1

        // If no members left, delete the group
        if groups[index].memberCount <= 0 {
            groups.remove(at: index)
            groupMemberships.removeValue(forKey: groupId)
        }

        saveToStorage()
    }

    func getGroups(forUserId userId: UUID) async throws -> [GroupRecord] {
        try await simulateNetworkDelay(short: true)
        return groups.filter { groupMemberships[$0.id]?.contains(userId) == true }
    }

    func getLeaderboard(groupId: UUID, timeWindow: TimeWindow, currentUserId: UUID) async throws -> [LeaderboardMemberSnapshot] {
        try await simulateNetworkDelay()

        guard let memberIds = groupMemberships[groupId] else {
            throw SocialServiceError.groupNotFound
        }

        // Generate mock leaderboard data
        var snapshots: [LeaderboardMemberSnapshot] = []

        for (index, memberId) in memberIds.enumerated() {
            let displayName = demoUsers.first(where: { $0.id == memberId })?.displayName ?? "User"
            let isCurrentUser = memberId == currentUserId

            // Generate realistic mock data
            let baseMinutes = Int.random(in: 120...360)
            let weeklyAvg = Double(baseMinutes) + Double.random(in: -30...30)

            let snapshot = LeaderboardMemberSnapshot(
                userId: memberId,
                displayName: displayName,
                rank: index + 1,
                todayMinutes: baseMinutes,
                weeklyAvgMinutes: weeklyAvg,
                topCategories: generateMockCategories(),
                isDataUnavailable: false,
                isStale: false,
                lastSyncedAt: Date().addingTimeInterval(-Double.random(in: 0...1800)),
                isCurrentUser: isCurrentUser
            )
            snapshots.append(snapshot)
        }

        // Sort by weekly average (lowest first = rank 1)
        snapshots.sort { ($0.weeklyAvgMinutes ?? .infinity) < ($1.weeklyAvgMinutes ?? .infinity) }

        // Assign ranks
        for i in snapshots.indices {
            snapshots[i].rank = i + 1
        }

        return snapshots
    }

    func getGroupMembers(groupId: UUID) async throws -> [GroupMember] {
        try await simulateNetworkDelay(short: true)

        guard let memberIds = groupMemberships[groupId],
              let group = groups.first(where: { $0.id == groupId }) else {
            throw SocialServiceError.groupNotFound
        }

        return memberIds.enumerated().map { index, memberId in
            let displayName = demoUsers.first(where: { $0.id == memberId })?.displayName ?? "User"
            return GroupMember(
                id: memberId,
                displayName: displayName,
                joinedAt: Date().addingTimeInterval(-Double(index) * 86400),
                isAdmin: index == 0  // First member is admin in mock
            )
        }
    }

    // MARK: - Group Admin Operations

    func updateGroup(groupId: UUID, newName: String?, regenerateCode: Bool) async throws -> GroupRecord {
        try await simulateNetworkDelay()

        guard let index = groups.firstIndex(where: { $0.id == groupId }) else {
            throw SocialServiceError.groupNotFound
        }

        if let name = newName {
            groups[index].groupName = name
        }

        if regenerateCode {
            groups[index].inviteCode = generateInviteCode()
        }

        saveToStorage()
        return groups[index]
    }

    func removeGroupMember(groupId: UUID, targetUserId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let index = groups.firstIndex(where: { $0.id == groupId }) else {
            throw SocialServiceError.groupNotFound
        }

        groupMemberships[groupId]?.remove(targetUserId)
        groups[index].memberCount -= 1
        saveToStorage()
    }

    func transferAdmin(groupId: UUID, newAdminId: UUID) async throws {
        try await simulateNetworkDelay()
        // In demo mode, this is a no-op since we don't track admin separately
    }

    func deleteGroup(groupId: UUID) async throws {
        try await simulateNetworkDelay()

        groups.removeAll { $0.id == groupId }
        groupMemberships.removeValue(forKey: groupId)
        saveToStorage()
    }

    // MARK: - Group Invites

    func sendGroupInvite(groupId: UUID, recipientUserId: UUID, senderId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let group = groups.first(where: { $0.id == groupId }) else {
            throw SocialServiceError.groupNotFound
        }

        let senderName = demoUsers.first(where: { $0.id == senderId })?.displayName ?? "Someone"

        let invite = GroupInvite(
            groupId: groupId,
            groupName: group.groupName,
            inviterDisplayName: senderName,
            memberCount: group.memberCount
        )

        groupInvites.append(invite)
    }

    func getPendingGroupInvites(forUserId userId: UUID) async throws -> [GroupInvite] {
        try await simulateNetworkDelay(short: true)
        return groupInvites
    }

    func respondToGroupInvite(inviteId: UUID, accept: Bool, userId: UUID) async throws {
        try await simulateNetworkDelay()

        guard let invite = groupInvites.first(where: { $0.id == inviteId }) else {
            return
        }

        groupInvites.removeAll { $0.id == inviteId }

        if accept {
            _ = try await joinGroup(inviteCode: "", userId: userId)
        }
    }

    // MARK: - Helper Methods

    private func simulateNetworkDelay(short: Bool = false) async throws {
        let delay = short
            ? UInt64.random(in: 50_000_000...150_000_000)
            : UInt64.random(in: 200_000_000...500_000_000)
        try await Task.sleep(nanoseconds: delay)
    }

    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  // Exclude confusing chars
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    private func generateMockCategories() -> [CategoryUsage] {
        let allCategories = ["social", "video", "games", "productivity", "reading", "health"]
        let categoryNames = ["Social", "Video", "Games", "Productivity", "Reading", "Health"]
        let shuffledIndices = allCategories.indices.shuffled()
        return (0..<3).map { i in
            let idx = shuffledIndices[i]
            return CategoryUsage(id: allCategories[idx], name: categoryNames[idx], hours: Double.random(in: 0.5...2.5))
        }
    }

    // MARK: - Persistence

    private func saveToStorage() {
        if let friendsData = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(friendsData, forKey: friendsKey)
        }
        if let groupsData = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(groupsData, forKey: groupsKey)
        }
    }

    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: friendsKey),
           let decoded = try? JSONDecoder().decode([FriendRecord].self, from: data) {
            friends = decoded
        }
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([GroupRecord].self, from: data) {
            groups = decoded
        }
    }

    func resetDemoData() {
        friends = []
        groups = []
        groupMemberships = [:]
        groupInvites = []
        UserDefaults.standard.removeObject(forKey: friendsKey)
        UserDefaults.standard.removeObject(forKey: groupsKey)
        UserDefaults.standard.removeObject(forKey: hasSeededKey)
    }
}

// MARK: - Production Service Placeholder

/// Placeholder for the real Supabase implementation.
/// When ready, implement this class using Supabase client.
///
/// Example migration:
/// ```swift
/// @MainActor
/// final class SupabaseSocialService: SocialServiceProtocol {
///     private let client = SupabaseClient.shared.client
///
///     func searchUser(query: String, currentUserId: UUID) async throws -> FriendSearchResult {
///         let response = try await client.functions.invoke(
///             "search-user",
///             options: .init(body: ["query": query])
///         )
///         // Parse response...
///     }
/// }
/// ```
// final class SupabaseSocialService: SocialServiceProtocol { ... }

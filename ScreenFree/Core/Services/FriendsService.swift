import Foundation

// MARK: - Friends Error

enum FriendsError: LocalizedError {
    case userNotFound
    case selfFriendRequest
    case duplicateRequest
    case alreadyFriends
    case requestNotFound
    case friendNotFound
    case networkError(String)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .selfFriendRequest:
            return "You cannot send a friend request to yourself"
        case .duplicateRequest:
            return "You already have a pending request with this user"
        case .alreadyFriends:
            return "You are already friends with this user"
        case .requestNotFound:
            return "Friend request not found"
        case .friendNotFound:
            return "Friend not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Friends Service

@MainActor
final class FriendsService {
    static let shared = FriendsService()

    private init() {
        loadFriends()
        loadDemoUsers()
    }

    // MARK: - Demo Mode Storage Keys

    private let friendsKey = "DemoFriends"
    private let demoUsersKey = "DemoUsers"
    private let hasSeededKey = "DemoFriendsSeeded"

    // MARK: - Demo Users (searchable users)

    private var demoUsers: [UserSearchMatch] = []

    // MARK: - Friends Storage

    private(set) var friends: [FriendRecord] = []

    // MARK: - Search User

    func searchUser(query: String, currentUserId: UUID) async throws -> FriendSearchResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...500_000_000))

        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedQuery.isEmpty else {
            return .idle
        }

        // Check if searching for self
        if let selfMatch = demoUsers.first(where: { $0.displayName.lowercased() == normalizedQuery && $0.id == currentUserId }) {
            return .selfSearch
        }

        // Search demo users
        guard let foundUser = demoUsers.first(where: { $0.displayName.lowercased() == normalizedQuery && $0.id != currentUserId }) else {
            return .notFound
        }

        // Check for existing friendship
        if let existingFriend = friends.first(where: {
            ($0.requesterId == foundUser.id || $0.recipientId == foundUser.id) &&
            ($0.requesterId == currentUserId || $0.recipientId == currentUserId)
        }) {
            switch existingFriend.status {
            case .accepted:
                return .alreadyFriends
            case .pendingOutgoing, .pendingIncoming:
                return .duplicateRequest
            case .blocked:
                return .notFound
            }
        }

        return .found(foundUser)
    }

    // MARK: - Send Friend Request

    func sendFriendRequest(to recipientId: UUID, from requesterId: UUID, displayName: String) async throws -> FriendRecord {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        // Validate not self
        guard recipientId != requesterId else {
            throw FriendsError.selfFriendRequest
        }

        // Check for existing relationship
        if friends.contains(where: {
            ($0.requesterId == recipientId || $0.recipientId == recipientId) &&
            ($0.requesterId == requesterId || $0.recipientId == requesterId)
        }) {
            throw FriendsError.duplicateRequest
        }

        let friend = FriendRecord(
            requesterId: requesterId,
            recipientId: recipientId,
            status: .pendingOutgoing,
            displayName: displayName
        )

        friends.append(friend)
        saveFriends()

        return friend
    }

    // MARK: - Accept Friend Request

    func acceptFriendRequest(friendRecordId: UUID) async throws -> FriendRecord {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        guard let index = friends.firstIndex(where: { $0.id == friendRecordId }) else {
            throw FriendsError.requestNotFound
        }

        friends[index].status = .accepted
        friends[index].updatedAt = Date()

        // Generate random screen time data for demo
        friends[index].cachedTodayMins = Int.random(in: 120...360)
        friends[index].cachedWeeklyAvgMins = Int.random(in: 180...300)

        saveFriends()

        return friends[index]
    }

    // MARK: - Decline Friend Request

    func declineFriendRequest(friendRecordId: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        guard let index = friends.firstIndex(where: { $0.id == friendRecordId }) else {
            throw FriendsError.requestNotFound
        }

        friends.remove(at: index)
        saveFriends()
    }

    // MARK: - Cancel Friend Request

    func cancelFriendRequest(friendRecordId: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        guard let index = friends.firstIndex(where: { $0.id == friendRecordId }) else {
            throw FriendsError.requestNotFound
        }

        friends.remove(at: index)
        saveFriends()
    }

    // MARK: - Unfriend

    func unfriend(friendRecordId: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        guard let index = friends.firstIndex(where: { $0.id == friendRecordId }) else {
            throw FriendsError.friendNotFound
        }

        friends.remove(at: index)
        saveFriends()
    }

    // MARK: - Block User

    func blockUser(friendRecordId: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))

        guard let index = friends.firstIndex(where: { $0.id == friendRecordId }) else {
            throw FriendsError.friendNotFound
        }

        friends[index].status = .blocked
        friends[index].updatedAt = Date()

        saveFriends()
    }

    // MARK: - Fetch Friends

    func fetchFriends(forceRefresh: Bool = false) async throws -> [FriendRecord] {
        // Only add delay when simulating a network refresh
        if forceRefresh {
            try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))
        }

        return friends
    }

    // MARK: - Fetch Friend Snapshots

    func fetchFriendSnapshots(for friendIds: [UUID], forceRefresh: Bool = false) async throws -> [FriendSummarySnapshot] {
        // Only add delay when simulating a network refresh
        if forceRefresh {
            try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))
        }

        return friends
            .filter { friendIds.contains($0.id) && $0.status == .accepted }
            .map { friend in
                FriendSummarySnapshot(
                    id: UUID(),
                    friendRecordId: friend.id,
                    displayName: friend.displayName,
                    todayMins: friend.cachedTodayMins ?? Int.random(in: 120...360),
                    weeklyAvgMins: friend.cachedWeeklyAvgMins ?? Int.random(in: 180...300),
                    isDataRevoked: friend.isDataRevoked
                )
            }
    }

    // MARK: - Seed Demo Friends

    func seedDemoFriends(currentUserId: UUID) {
        guard !UserDefaults.standard.bool(forKey: hasSeededKey) else { return }

        // Create demo friend records
        let sarahId = demoUsers.first { $0.displayName == "Sarah" }?.id ?? UUID()
        let mikeId = demoUsers.first { $0.displayName == "Mike" }?.id ?? UUID()
        let emmaId = demoUsers.first { $0.displayName == "Emma" }?.id ?? UUID()

        let demoFriends: [FriendRecord] = [
            // Sarah - accepted friend
            FriendRecord(
                requesterId: sarahId,
                recipientId: currentUserId,
                status: .accepted,
                displayName: "Sarah",
                cachedWeeklyAvgMins: 195,
                cachedTodayMins: 210
            ),
            // Mike - accepted friend
            FriendRecord(
                requesterId: currentUserId,
                recipientId: mikeId,
                status: .accepted,
                displayName: "Mike",
                cachedWeeklyAvgMins: 280,
                cachedTodayMins: 320
            ),
            // Emma - pending incoming request
            FriendRecord(
                requesterId: emmaId,
                recipientId: currentUserId,
                status: .pendingIncoming,
                displayName: "Emma"
            )
        ]

        friends = demoFriends
        saveFriends()

        UserDefaults.standard.set(true, forKey: hasSeededKey)
    }

    // MARK: - Reset Demo Data

    func resetDemoData() {
        friends = []
        UserDefaults.standard.removeObject(forKey: friendsKey)
        UserDefaults.standard.removeObject(forKey: hasSeededKey)
    }

    // MARK: - Demo Persistence

    private func saveFriends() {
        if let data = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(data, forKey: friendsKey)
        }
    }

    private func loadFriends() {
        guard let data = UserDefaults.standard.data(forKey: friendsKey),
              let decoded = try? JSONDecoder().decode([FriendRecord].self, from: data) else {
            return
        }
        friends = decoded
    }

    private func loadDemoUsers() {
        // Pre-defined demo users that can be searched
        demoUsers = [
            UserSearchMatch(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, displayName: "Sarah", level: 3),
            UserSearchMatch(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, displayName: "Mike", level: 2),
            UserSearchMatch(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, displayName: "Emma", level: 4),
            UserSearchMatch(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, displayName: "Alex", level: 1)
        ]
    }
}

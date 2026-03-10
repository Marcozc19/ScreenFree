import Foundation
import Observation

// MARK: - Social Load State

enum SocialLoadState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Social View Model

/// ViewModel for the Social tab, managing both Groups (primary) and Friends (secondary).
@Observable
@MainActor
final class SocialViewModel {
    // MARK: - Dependencies

    private let socialService = MockSocialService.shared
    private let analyticsService = AnalyticsService.shared

    // MARK: - State

    var groups: [GroupRecord] = []
    var friends: [FriendRecord] = []
    var loadState: SocialLoadState = .idle
    var isProcessingAction: Bool = false

    // MARK: - User Info

    var currentUserId: UUID?

    // MARK: - Sheet State

    var showCreateGroupSheet: Bool = false
    var showJoinGroupSheet: Bool = false
    var showAddFriendSheet: Bool = false
    var showRequestsMenu: Bool = false

    // MARK: - Friends Section State

    var isFriendsSectionExpanded: Bool = false

    // MARK: - Search/Join State

    var friendSearchQuery: String = ""
    var friendSearchResult: FriendSearchResult = .idle
    var joinGroupCode: String = ""
    var joinGroupError: String?

    // MARK: - Create Group State

    var newGroupName: String = ""

    // MARK: - Computed Properties

    var hasGroups: Bool {
        !groups.isEmpty
    }

    var acceptedFriends: [FriendRecord] {
        friends.filter { $0.status == .accepted }
    }

    var pendingIncoming: [FriendRecord] {
        friends.filter { $0.status == .pendingIncoming }
    }

    var pendingOutgoing: [FriendRecord] {
        friends.filter { $0.status == .pendingOutgoing }
    }

    var pendingRequestCount: Int {
        pendingIncoming.count
    }

    var hasFriends: Bool {
        !acceptedFriends.isEmpty
    }

    var hasPendingRequests: Bool {
        !pendingIncoming.isEmpty || !pendingOutgoing.isEmpty
    }

    // MARK: - Initialization

    init() {}

    // MARK: - Load Data

    func loadData() async {
        guard let userId = currentUserId else { return }
        guard loadState == .idle else { return }

        loadState = .loading

        do {
            async let groupsTask = socialService.getGroups(forUserId: userId)
            async let friendsTask = socialService.getFriends(forUserId: userId)

            groups = try await groupsTask
            friends = try await friendsTask

            loadState = .loaded

            analyticsService.logSocialTabOpened(hasGroups: hasGroups, friendCount: acceptedFriends.count)
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    func refreshData() async {
        guard let userId = currentUserId else { return }

        loadState = .loading

        do {
            async let groupsTask = socialService.getGroups(forUserId: userId)
            async let friendsTask = socialService.getFriends(forUserId: userId)

            groups = try await groupsTask
            friends = try await friendsTask

            loadState = .loaded
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    // MARK: - Group Actions

    func createGroup() async {
        guard let userId = currentUserId else { return }
        let name = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isProcessingAction = true

        do {
            let group = try await socialService.createGroup(name: name, adminId: userId)
            groups.append(group)
            newGroupName = ""
            showCreateGroupSheet = false

            analyticsService.logGroupCreated()
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func joinGroup() async {
        guard let userId = currentUserId else { return }
        let code = joinGroupCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard code.count == 6 else {
            joinGroupError = "Please enter a 6-character code"
            return
        }

        isProcessingAction = true
        joinGroupError = nil

        do {
            let result = try await socialService.joinGroup(inviteCode: code, userId: userId)

            switch result {
            case .success(let group):
                groups.append(group)
                joinGroupCode = ""
                showJoinGroupSheet = false
                analyticsService.logGroupJoined(method: "inviteCode")
            case .invalidCode, .alreadyMember, .groupFull:
                joinGroupError = result.errorMessage
            }
        } catch {
            joinGroupError = "Failed to join group. Please try again."
        }

        isProcessingAction = false
    }

    func leaveGroup(_ group: GroupRecord) async {
        guard let userId = currentUserId else { return }

        isProcessingAction = true

        do {
            try await socialService.leaveGroup(groupId: group.id, userId: userId)
            groups.removeAll { $0.id == group.id }
            analyticsService.logGroupLeft()
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    // MARK: - Friend Actions

    func searchUser() async {
        guard let userId = currentUserId else { return }

        let query = friendSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            friendSearchResult = .idle
            return
        }

        friendSearchResult = .loading
        analyticsService.logFriendSearchSubmitted(queryLength: query.count)

        do {
            friendSearchResult = try await socialService.searchUser(query: query, currentUserId: userId)

            switch friendSearchResult {
            case .found:
                analyticsService.logFriendSearchResult(result: "found")
            case .selfSearch:
                analyticsService.logFriendSearchResult(result: "self")
            case .alreadyFriend, .requestAlreadySent:
                analyticsService.logFriendSearchResult(result: "duplicate")
            default:
                analyticsService.logFriendSearchResult(result: "not_found")
            }
        } catch {
            friendSearchResult = .notFound
        }
    }

    func sendFriendRequest(to user: UserSearchMatch) async {
        guard let userId = currentUserId else { return }

        isProcessingAction = true

        do {
            let record = try await socialService.sendFriendRequest(to: user.id, from: userId)
            friends.append(record)
            friendSearchQuery = ""
            friendSearchResult = .idle
            showAddFriendSheet = false
            analyticsService.logFriendRequestSent()
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func acceptRequest(_ friendRecord: FriendRecord) async {
        isProcessingAction = true

        do {
            try await socialService.respondToFriendRequest(friendshipId: friendRecord.id, action: .accept)

            if let index = friends.firstIndex(where: { $0.id == friendRecord.id }) {
                friends[index].status = .accepted
                friends[index].updatedAt = Date()
            }

            analyticsService.logFriendRequestAccepted()
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func declineRequest(_ friendRecord: FriendRecord) async {
        isProcessingAction = true

        do {
            try await socialService.respondToFriendRequest(friendshipId: friendRecord.id, action: .decline)
            friends.removeAll { $0.id == friendRecord.id }
            analyticsService.logFriendRequestDeclined()
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func cancelRequest(_ friendRecord: FriendRecord) async {
        isProcessingAction = true

        do {
            try await socialService.removeFriend(friendshipId: friendRecord.id)
            friends.removeAll { $0.id == friendRecord.id }
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func unfriend(_ friendRecord: FriendRecord) async {
        isProcessingAction = true

        do {
            try await socialService.removeFriend(friendshipId: friendRecord.id)
            friends.removeAll { $0.id == friendRecord.id }
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    func blockUser(_ friendRecord: FriendRecord) async {
        isProcessingAction = true

        do {
            try await socialService.blockUser(friendshipId: friendRecord.id)

            if let index = friends.firstIndex(where: { $0.id == friendRecord.id }) {
                friends[index].status = .blocked
            }
        } catch {
            // Handle error
        }

        isProcessingAction = false
    }

    // MARK: - Analytics

    func logFriendsSectionExpanded() {
        analyticsService.logFriendsSectionExpanded(friendCount: acceptedFriends.count)
    }
}

import Foundation
import Observation

// MARK: - Load State

enum FriendsLoadState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Friends View Model

/// ViewModel for friends management.
/// NOTE: Friends grant ZERO data access - they are just a directory for inviting to groups.
@Observable
@MainActor
final class FriendsViewModel {
    // MARK: - Dependencies

    private let socialService = MockSocialService.shared
    private let analyticsService = AnalyticsService.shared

    // MARK: - State

    var friends: [FriendRecord] = []
    var loadState: FriendsLoadState = .idle
    var searchQuery: String = ""
    var searchResult: FriendSearchResult = .idle
    var isProcessingRequest: Bool = false

    // MARK: - User Info

    var currentUserId: UUID?

    // MARK: - Sheet State

    var showAddFriendSheet: Bool = false
    var showRequestsMenu: Bool = false

    // MARK: - Computed Properties

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

    // MARK: - Load Friends

    func loadFriends() async {
        guard let userId = currentUserId else { return }
        guard loadState == .idle || loadState == .loaded else { return }

        if loadState == .idle {
            loadState = .loading
        }

        do {
            friends = try await socialService.getFriends(forUserId: userId)
            loadState = .loaded

            analyticsService.logFriendsSectionExpanded(friendCount: acceptedFriends.count)
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    // MARK: - Refresh Friends

    func refreshFriends() async {
        guard let userId = currentUserId else { return }

        loadState = .loading

        do {
            friends = try await socialService.getFriends(forUserId: userId)
            loadState = .loaded
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    // MARK: - Search User

    func searchUser() async {
        guard let userId = currentUserId else { return }

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResult = .idle
            return
        }

        searchResult = .loading
        analyticsService.logFriendSearchSubmitted(queryLength: query.count)

        do {
            searchResult = try await socialService.searchUser(query: query, currentUserId: userId)

            // Log result
            switch searchResult {
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
            searchResult = .notFound
        }
    }

    // MARK: - Send Friend Request

    func sendFriendRequest(to user: UserSearchMatch) async {
        guard let userId = currentUserId else { return }

        isProcessingRequest = true

        do {
            let record = try await socialService.sendFriendRequest(
                to: user.id,
                from: userId
            )

            friends.append(record)
            searchQuery = ""
            searchResult = .idle
            showAddFriendSheet = false

            analyticsService.logFriendRequestSent()
        } catch {
            // Handle error - could set an error state here
        }

        isProcessingRequest = false
    }

    // MARK: - Accept Request

    func acceptRequest(_ friendRecord: FriendRecord) async {
        isProcessingRequest = true

        do {
            try await socialService.respondToFriendRequest(
                friendshipId: friendRecord.id,
                action: .accept
            )

            if let index = friends.firstIndex(where: { $0.id == friendRecord.id }) {
                friends[index].status = .accepted
                friends[index].updatedAt = Date()
            }

            analyticsService.logFriendRequestAccepted()
        } catch {
            // Handle error
        }

        isProcessingRequest = false
    }

    // MARK: - Decline Request

    func declineRequest(_ friendRecord: FriendRecord) async {
        isProcessingRequest = true

        do {
            try await socialService.respondToFriendRequest(
                friendshipId: friendRecord.id,
                action: .decline
            )
            friends.removeAll { $0.id == friendRecord.id }

            analyticsService.logFriendRequestDeclined()
        } catch {
            // Handle error
        }

        isProcessingRequest = false
    }

    // MARK: - Cancel Request

    func cancelRequest(_ friendRecord: FriendRecord) async {
        isProcessingRequest = true

        do {
            try await socialService.removeFriend(friendshipId: friendRecord.id)
            friends.removeAll { $0.id == friendRecord.id }
        } catch {
            // Handle error
        }

        isProcessingRequest = false
    }

    // MARK: - Unfriend

    func unfriend(_ friendRecord: FriendRecord) async {
        isProcessingRequest = true

        do {
            try await socialService.removeFriend(friendshipId: friendRecord.id)
            friends.removeAll { $0.id == friendRecord.id }
        } catch {
            // Handle error
        }

        isProcessingRequest = false
    }

    // MARK: - Block User

    func blockUser(_ friendRecord: FriendRecord) async {
        isProcessingRequest = true

        do {
            try await socialService.blockUser(friendshipId: friendRecord.id)

            if let index = friends.firstIndex(where: { $0.id == friendRecord.id }) {
                friends[index].status = .blocked
            }
        } catch {
            // Handle error
        }

        isProcessingRequest = false
    }
}

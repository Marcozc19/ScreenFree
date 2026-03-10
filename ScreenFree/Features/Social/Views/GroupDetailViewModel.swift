import Foundation
import Observation
import UIKit

// MARK: - Leaderboard State

enum LeaderboardState: Equatable {
    case loading
    case loaded
    case error(String)
}

// MARK: - Group Detail View Model

@Observable
@MainActor
final class GroupDetailViewModel {
    // MARK: - Dependencies

    private let socialService = MockSocialService.shared
    private let analyticsService = AnalyticsService.shared

    // MARK: - State

    var group: GroupRecord
    var leaderboardMembers: [LeaderboardMemberSnapshot] = []
    var groupMembers: [GroupMember] = []
    var leaderboardState: LeaderboardState = .loading
    var selectedTimeWindow: TimeWindow = .today
    var isProcessing: Bool = false

    // MARK: - User Info

    var currentUserId: UUID?

    // MARK: - Sheet State

    var showRenameSheet: Bool = false
    var showInviteSheet: Bool = false
    var showDeleteConfirmation: Bool = false
    var showLeaveConfirmation: Bool = false

    // MARK: - Edit State

    var newGroupName: String = ""
    var didCopyCode: Bool = false

    // MARK: - Initialization

    init(group: GroupRecord) {
        self.group = group
        self.newGroupName = group.groupName
    }

    // MARK: - Load Leaderboard

    func loadLeaderboard() async {
        guard let userId = currentUserId else { return }

        leaderboardState = .loading

        do {
            async let leaderboardTask = socialService.getLeaderboard(
                groupId: group.id,
                timeWindow: selectedTimeWindow,
                currentUserId: userId
            )
            async let membersTask = socialService.getGroupMembers(groupId: group.id)

            leaderboardMembers = try await leaderboardTask
            groupMembers = try await membersTask

            leaderboardState = .loaded

            analyticsService.logLeaderboardViewed(
                memberCount: leaderboardMembers.count,
                timeWindow: selectedTimeWindow.rawValue
            )
        } catch {
            leaderboardState = .error(error.localizedDescription)
        }
    }

    // MARK: - Admin Actions

    func renameGroup() async {
        let name = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isProcessing = true

        do {
            let updated = try await socialService.updateGroup(
                groupId: group.id,
                newName: name,
                regenerateCode: false
            )
            group = updated
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    func regenerateInviteCode() {
        Task {
            isProcessing = true

            do {
                let updated = try await socialService.updateGroup(
                    groupId: group.id,
                    newName: nil,
                    regenerateCode: true
                )
                group = updated
            } catch {
                // Handle error
            }

            isProcessing = false
        }
    }

    func removeMember(_ member: GroupMember) async {
        isProcessing = true

        do {
            try await socialService.removeGroupMember(
                groupId: group.id,
                targetUserId: member.id
            )
            groupMembers.removeAll { $0.id == member.id }
            leaderboardMembers.removeAll { $0.userId == member.id }
            group.memberCount -= 1
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    func transferAdmin(to member: GroupMember) async {
        isProcessing = true

        do {
            try await socialService.transferAdmin(
                groupId: group.id,
                newAdminId: member.id
            )

            // Update local state
            group.isAdmin = false
            if let index = groupMembers.firstIndex(where: { $0.id == member.id }) {
                groupMembers[index].isAdmin = true
            }
            if let currentIndex = groupMembers.firstIndex(where: { $0.id == currentUserId }) {
                groupMembers[currentIndex].isAdmin = false
            }
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    func deleteGroup() async {
        isProcessing = true

        do {
            try await socialService.deleteGroup(groupId: group.id)
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    // MARK: - Member Actions

    func leaveGroup() async {
        guard let userId = currentUserId else { return }

        isProcessing = true

        do {
            try await socialService.leaveGroup(groupId: group.id, userId: userId)
            analyticsService.logGroupLeft()
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    // MARK: - Invite Code Actions

    func copyInviteCode() {
        guard let code = group.inviteCode else { return }

        UIPasteboard.general.string = code
        didCopyCode = true

        analyticsService.logInviteCodeShared(surface: "leaderboardHeader")

        // Reset after delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            didCopyCode = false
        }
    }

    func shareInviteCode() {
        guard let code = group.inviteCode else { return }

        let message = "Join my accountability group \"\(group.groupName)\" on ScreenFree! Use code: \(code)"

        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        // Find the key window and present
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }

        analyticsService.logInviteCodeShared(surface: "shareSheet")
    }
}

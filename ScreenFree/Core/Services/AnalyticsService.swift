import Foundation

// MARK: - Demo Mode Analytics
// Events are logged to console in demo mode
// When ready for Firebase:
// 1. Add firebase-ios-sdk package
// 2. import FirebaseAnalytics
// 3. Replace print statements with Analytics.logEvent calls

enum AnalyticsEvent: String {
    // Onboarding events
    case onboardingStart = "onboarding_start"
    case accountCreated = "account_created"
    case permissionRequested = "permission_requested"
    case permissionGranted = "permission_granted"
    case permissionDenied = "permission_denied"
    case challengeAccepted = "challenge_accepted"
    case onboardingComplete = "onboarding_complete"

    // Challenge events
    case challengeStarted = "challenge_started"
    case challengeCompleted = "challenge_completed"
    case challengeFailed = "challenge_failed"

    // Engagement events
    case checkInLogged = "check_in_logged"
    case xpEarned = "xp_earned"
    case levelUp = "level_up"

    // Screen views
    case screenView = "screen_view"

    // Social events
    case socialTabOpened = "social_tab_opened"
    case friendsSectionExpanded = "friends_section_expanded"
    case friendSearchSubmitted = "friend_search_submitted"
    case friendSearchResult = "friend_search_result"
    case friendRequestSent = "friend_request_sent"
    case friendRequestAccepted = "friend_request_accepted"
    case friendRequestDeclined = "friend_request_declined"

    // Group events
    case groupCreated = "group_created"
    case groupJoined = "group_joined"
    case groupLeft = "group_left"
    case leaderboardViewed = "leaderboard_viewed"
    case timeWindowChanged = "time_window_changed"
    case inviteCodeShared = "invite_code_shared"
}

@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let isDebugLoggingEnabled = true

    private init() {}

    // MARK: - Event Logging

    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        if isDebugLoggingEnabled {
            print("[Analytics] \(event.rawValue): \(parameters ?? [:])")
        }

        // Firebase Analytics would go here:
        // Analytics.logEvent(event.rawValue, parameters: parameters)
    }

    func logScreenView(screenName: String, screenClass: String? = nil) {
        if isDebugLoggingEnabled {
            print("[Analytics] screen_view: \(screenName)")
        }

        // Firebase Analytics would go here:
        // Analytics.logEvent(AnalyticsEventScreenView, parameters: [...])
    }

    // MARK: - Onboarding Events

    func logOnboardingStart() {
        logEvent(.onboardingStart)
    }

    func logAccountCreated(ageRange: String) {
        logEvent(.accountCreated, parameters: [
            "age_range": ageRange
        ])
    }

    func logPermissionRequested() {
        logEvent(.permissionRequested)
    }

    func logPermissionGranted() {
        logEvent(.permissionGranted)
    }

    func logPermissionDenied() {
        logEvent(.permissionDenied)
    }

    func logChallengeAccepted(challengeId: String) {
        logEvent(.challengeAccepted, parameters: [
            "challenge_id": challengeId
        ])
    }

    func logOnboardingComplete(baselineHours: Double) {
        logEvent(.onboardingComplete, parameters: [
            "baseline_hours": baselineHours
        ])
    }

    // MARK: - Challenge Events

    func logChallengeStarted(challengeId: String, difficulty: String) {
        logEvent(.challengeStarted, parameters: [
            "challenge_id": challengeId,
            "difficulty": difficulty
        ])
    }

    func logChallengeCompleted(challengeId: String, daysToComplete: Int) {
        logEvent(.challengeCompleted, parameters: [
            "challenge_id": challengeId,
            "days_to_complete": daysToComplete
        ])
    }

    func logChallengeFailed(challengeId: String, daysCompleted: Int) {
        logEvent(.challengeFailed, parameters: [
            "challenge_id": challengeId,
            "days_completed": daysCompleted
        ])
    }

    // MARK: - Engagement Events

    func logXPEarned(amount: Int, source: String) {
        logEvent(.xpEarned, parameters: [
            "amount": amount,
            "source": source
        ])
    }

    func logLevelUp(newLevel: Int) {
        logEvent(.levelUp, parameters: [
            "new_level": newLevel
        ])
    }

    // MARK: - User Properties

    func setUserProperty(_ value: String?, forName name: String) {
        if isDebugLoggingEnabled {
            print("[Analytics] Set user property \(name): \(value ?? "nil")")
        }

        // Firebase Analytics would go here:
        // Analytics.setUserProperty(value, forName: name)
    }

    func setUserId(_ userId: String?) {
        if isDebugLoggingEnabled {
            print("[Analytics] Set user ID: \(userId ?? "nil")")
        }

        // Firebase Analytics would go here:
        // Analytics.setUserID(userId)
    }

    // MARK: - Social Events

    func logSocialTabOpened(hasGroups: Bool, friendCount: Int) {
        logEvent(.socialTabOpened, parameters: [
            "has_groups": hasGroups,
            "friend_count": friendCount
        ])
    }

    func logFriendsSectionExpanded(friendCount: Int) {
        logEvent(.friendsSectionExpanded, parameters: [
            "friend_count": friendCount
        ])
    }

    func logFriendSearchSubmitted(queryLength: Int) {
        logEvent(.friendSearchSubmitted, parameters: [
            "query_length": queryLength
        ])
    }

    func logFriendSearchResult(result: String) {
        logEvent(.friendSearchResult, parameters: [
            "result": result
        ])
    }

    func logFriendRequestSent() {
        logEvent(.friendRequestSent)
    }

    func logFriendRequestAccepted() {
        logEvent(.friendRequestAccepted)
    }

    func logFriendRequestDeclined() {
        logEvent(.friendRequestDeclined)
    }

    // MARK: - Group Events

    func logGroupCreated() {
        logEvent(.groupCreated)
    }

    func logGroupJoined(method: String) {
        logEvent(.groupJoined, parameters: [
            "method": method  // "inviteCode" or "directInvite"
        ])
    }

    func logGroupLeft() {
        logEvent(.groupLeft)
    }

    func logLeaderboardViewed(memberCount: Int, timeWindow: String) {
        logEvent(.leaderboardViewed, parameters: [
            "member_count": memberCount,
            "time_window": timeWindow
        ])
    }

    func logTimeWindowChanged(from: String, to: String) {
        logEvent(.timeWindowChanged, parameters: [
            "from": from,
            "to": to
        ])
    }

    func logInviteCodeShared(surface: String) {
        logEvent(.inviteCodeShared, parameters: [
            "surface": surface  // "leaderboardHeader" or "fillSlot"
        ])
    }
}

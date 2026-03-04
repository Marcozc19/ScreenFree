import Foundation

enum DatabaseError: LocalizedError {
    case createProfileFailed(String)
    case fetchProfileFailed(String)
    case updateProfileFailed(String)
    case createChallengeFailed(String)
    case fetchChallengeFailed(String)
    case profileNotFound

    var errorDescription: String? {
        switch self {
        case .createProfileFailed(let message):
            return "Failed to create profile: \(message)"
        case .fetchProfileFailed(let message):
            return "Failed to fetch profile: \(message)"
        case .updateProfileFailed(let message):
            return "Failed to update profile: \(message)"
        case .createChallengeFailed(let message):
            return "Failed to start challenge: \(message)"
        case .fetchChallengeFailed(let message):
            return "Failed to fetch challenge: \(message)"
        case .profileNotFound:
            return "Profile not found"
        }
    }
}

@MainActor
final class DatabaseService {
    static let shared = DatabaseService()

    private init() {}

    // MARK: - Demo Mode Storage Keys

    private let profileKey = "DemoUserProfile"
    private let challengeKey = "DemoUserChallenge"

    // MARK: - User Profiles

    func createProfile(userId: UUID, displayName: String, ageRange: AgeRange) async throws -> UserProfile {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        let profile = UserProfile(
            id: userId,
            displayName: displayName,
            ageRange: ageRange
        )

        saveProfile(profile)
        return profile
    }

    func getProfile(userId: UUID) async throws -> UserProfile? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)

        return loadProfile()
    }

    func updateProfile(_ profile: UserProfile) async throws -> UserProfile {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)

        var updatedProfile = profile
        updatedProfile.updatedAt = Date()

        saveProfile(updatedProfile)
        return updatedProfile
    }

    func updateOnboardingComplete(userId: UUID, baselineScreenTime: Double) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)

        guard var profile = loadProfile() else {
            throw DatabaseError.profileNotFound
        }

        profile.onboardingCompleted = true
        profile.baselineScreenTime = baselineScreenTime
        profile.updatedAt = Date()

        saveProfile(profile)
    }

    func addXP(userId: UUID, amount: Int) async throws -> UserProfile {
        guard var profile = loadProfile() else {
            throw DatabaseError.profileNotFound
        }

        profile.xp += amount

        // Check for level up
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }

        saveProfile(profile)
        return profile
    }

    // MARK: - User Challenges

    func createUserChallenge(userId: UUID, challengeId: String) async throws -> UserChallenge {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        let userChallenge = UserChallenge(
            challengeId: challengeId,
            userId: userId
        )

        saveChallenge(userChallenge)
        return userChallenge
    }

    func getActiveChallenge(userId: UUID) async throws -> UserChallenge? {
        return loadChallenge()
    }

    func updateChallengeProgress(challengeId: UUID, progress: Int) async throws {
        guard var challenge = loadChallenge() else { return }

        challenge.progress = progress
        saveChallenge(challenge)
    }

    // MARK: - Demo Persistence

    private func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    private func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    private func saveChallenge(_ challenge: UserChallenge) {
        if let data = try? JSONEncoder().encode(challenge) {
            UserDefaults.standard.set(data, forKey: challengeKey)
        }
    }

    private func loadChallenge() -> UserChallenge? {
        guard let data = UserDefaults.standard.data(forKey: challengeKey),
              let challenge = try? JSONDecoder().decode(UserChallenge.self, from: data) else {
            return nil
        }
        return challenge
    }
}

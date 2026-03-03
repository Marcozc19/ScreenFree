import Foundation

enum AuthError: LocalizedError {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    case noSession
    case invalidEmail
    case weakPassword
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .signUpFailed(let message):
            return "Sign up failed: \(message)"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .noSession:
            return "No active session"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .userNotFound:
            return "No account found with this email"
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()

    private init() {}

    // MARK: - Demo Mode Storage

    private let userDefaultsKey = "DemoUser"

    // MARK: - Sign Up (Demo Mode)

    func signUp(email: String, password: String) async throws -> User {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Create demo user
        let user = User(
            id: UUID(),
            email: email,
            createdAt: Date()
        )

        // Persist in UserDefaults for demo
        saveUser(user)

        return user
    }

    // MARK: - Sign In (Demo Mode)

    func signIn(email: String, password: String) async throws -> User {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Check if user exists in demo storage
        if let savedUser = loadUser(), savedUser.email == email {
            return savedUser
        }

        // For demo, allow any valid email/password combo
        let user = User(
            id: UUID(),
            email: email,
            createdAt: Date()
        )

        saveUser(user)
        return user
    }

    // MARK: - Sign Out

    func signOut() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)

        // Clear demo storage
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Session

    func getCurrentSession() async throws -> User? {
        return loadUser()
    }

    func refreshSession() async throws {
        // No-op in demo mode
    }

    // MARK: - Validation

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Demo Persistence

    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}

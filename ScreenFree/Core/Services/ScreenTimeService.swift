import Foundation
import UIKit

// NOTE: FamilyControls requires Apple Developer Program enrollment.
// Set useMockMode = false once you have the entitlement configured.

enum ScreenTimeError: LocalizedError {
    case authorizationDenied
    case authorizationFailed(String)
    case dataUnavailable
    case mockModeEnabled

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Screen Time access was denied"
        case .authorizationFailed(let message):
            return "Failed to authorize: \(message)"
        case .dataUnavailable:
            return "Screen Time data is not available"
        case .mockModeEnabled:
            return "Running in mock mode"
        }
    }
}

enum ScreenTimeAuthorizationStatus {
    case notDetermined
    case denied
    case approved
}

@MainActor
final class ScreenTimeService {
    static let shared = ScreenTimeService()

    // MARK: - Mock Mode Configuration

    /// Set to false once you have Apple Developer Program enrollment
    /// and FamilyControls entitlement configured
    let useMockMode = true

    private init() {}

    // MARK: - Authorization

    var authorizationStatus: ScreenTimeAuthorizationStatus {
        if useMockMode {
            return .approved  // Always approved in mock mode
        }

        // Real FamilyControls check would go here
        // Requires: import FamilyControls
        // return authorizationCenter.authorizationStatus
        return .notDetermined
    }

    var isAuthorized: Bool {
        if useMockMode {
            return true
        }
        return authorizationStatus == .approved
    }

    func requestAuthorization() async throws {
        if useMockMode {
            // Simulate a brief delay for mock authorization
            try await Task.sleep(nanoseconds: 500_000_000)
            return
        }

        // Real FamilyControls authorization would go here
        // Requires: import FamilyControls
        // try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        throw ScreenTimeError.authorizationFailed("FamilyControls not configured")
    }

    // MARK: - Screen Time Data

    func getScreenTimeData() async -> ScreenTimeData {
        // Return consistent mock data for development
        return .mock
    }

    /// Get randomized mock data (for variety in testing)
    func getRandomizedScreenTimeData() async -> ScreenTimeData {
        let totalHours = Double.random(in: 3.5...7.5)

        let categories = [
            CategoryUsage(
                id: "social",
                name: "Social Media",
                hours: totalHours * Double.random(in: 0.25...0.45)
            ),
            CategoryUsage(
                id: "entertainment",
                name: "Entertainment",
                hours: totalHours * Double.random(in: 0.15...0.30)
            ),
            CategoryUsage(
                id: "productivity",
                name: "Productivity",
                hours: totalHours * Double.random(in: 0.10...0.20)
            ),
            CategoryUsage(
                id: "games",
                name: "Games",
                hours: totalHours * Double.random(in: 0.05...0.15)
            )
        ]

        return ScreenTimeData(
            totalHours: totalHours,
            categories: categories.sorted { $0.hours > $1.hours }
        )
    }

    // MARK: - Settings

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func openScreenTimeSettings() {
        if let url = URL(string: "App-Prefs:SCREEN_TIME") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                openSettings()
            }
        }
    }
}

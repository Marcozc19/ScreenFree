import Foundation

struct ScreenTimeData: Codable {
    let totalHours: Double
    let categories: [CategoryUsage]
    let recordedAt: Date

    init(totalHours: Double, categories: [CategoryUsage], recordedAt: Date = Date()) {
        self.totalHours = totalHours
        self.categories = categories
        self.recordedAt = recordedAt
    }

    var formattedTotal: String {
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var topCategories: [CategoryUsage] {
        Array(categories.sorted { $0.hours > $1.hours }.prefix(3))
    }

    var maxCategoryHours: Double {
        categories.map { $0.hours }.max() ?? 1
    }
}

struct CategoryUsage: Identifiable, Codable {
    let id: String
    let name: String
    let hours: Double

    var formattedHours: String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }
}

// MARK: - Mock Data

extension ScreenTimeData {
    static let mock = ScreenTimeData(
        totalHours: 4.5,
        categories: [
            CategoryUsage(id: "social", name: "Social Media", hours: 2.0),
            CategoryUsage(id: "entertainment", name: "Entertainment", hours: 1.25),
            CategoryUsage(id: "productivity", name: "Productivity", hours: 0.75),
            CategoryUsage(id: "games", name: "Games", hours: 0.5)
        ]
    )

    static let high = ScreenTimeData(
        totalHours: 7.5,
        categories: [
            CategoryUsage(id: "social", name: "Social Media", hours: 3.5),
            CategoryUsage(id: "entertainment", name: "Entertainment", hours: 2.25),
            CategoryUsage(id: "games", name: "Games", hours: 1.75)
        ]
    )

    static let low = ScreenTimeData(
        totalHours: 2.0,
        categories: [
            CategoryUsage(id: "productivity", name: "Productivity", hours: 1.0),
            CategoryUsage(id: "social", name: "Social Media", hours: 0.5),
            CategoryUsage(id: "entertainment", name: "Entertainment", hours: 0.5)
        ]
    )
}

import SwiftUI

// MARK: - Category Bar Model

struct CategoryBarModel: Identifiable {
    let id: String
    let name: String
    let minutes: Int
    let color: Color

    var formattedTime: String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 {
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(m)m"
    }
}

// MARK: - Category Color Map (per spec)

enum CategoryColorMap {
    static let social = Color(hex: "#007AFF")      // Accent Blue
    static let video = Color(hex: "#5AC8FA")       // Light Blue
    static let games = Color(hex: "#AF52DE")       // Purple
    static let productivity = Color(hex: "#5AC8B5") // Teal
    static let health = Color(hex: "#34C759")      // Green
    static let browsing = Color(hex: "#FF9500")    // Amber
    static let other = Color(hex: "#8E8E93")       // Grey

    static func color(for categoryName: String) -> Color {
        let name = categoryName.lowercased()
        switch name {
        case let n where n.contains("social"):
            return social
        case let n where n.contains("video") || n.contains("entertainment"):
            return video
        case let n where n.contains("game"):
            return games
        case let n where n.contains("productivity") || n.contains("work"):
            return productivity
        case let n where n.contains("health") || n.contains("fitness"):
            return health
        case let n where n.contains("brows") || n.contains("safari") || n.contains("web"):
            return browsing
        default:
            return other
        }
    }
}

// MARK: - Category Snapshot View (Top-3 Horizontal Bar Chart)

struct CategorySnapshotView: View {
    let categories: [CategoryBarModel]

    // Maximum value for scaling bars
    private var maxMinutes: Int {
        categories.first?.minutes ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Section header
            Text("Top Categories")
                .font(.system(size: Theme.Typography.lg, weight: .semibold))
                .foregroundColor(ClockDialTokens.deepSlate)

            if categories.isEmpty {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 32))
                            .foregroundColor(ClockDialTokens.grey.opacity(0.5))

                        Text("No category data yet")
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(ClockDialTokens.grey)
                    }
                    .padding(.vertical, Theme.Spacing.xl)
                    Spacer()
                }
                .background(Theme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            } else {
                // Category rows (top 3 only)
                VStack(spacing: 14) {
                    ForEach(categories.prefix(3)) { category in
                        categoryRow(category)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            }
        }
    }

    private func categoryRow(_ category: CategoryBarModel) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Category name
            Text(category.name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(ClockDialTokens.deepSlate)
                .frame(width: 80, alignment: .leading)

            // Horizontal bar
            GeometryReader { geometry in
                let progress = maxMinutes > 0
                    ? CGFloat(category.minutes) / CGFloat(maxMinutes)
                    : 0

                RoundedRectangle(cornerRadius: 5)
                    .fill(category.color)
                    .frame(width: geometry.size.width * progress, height: 10)
            }
            .frame(height: 10)

            // Time label
            Text(category.formattedTime)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(ClockDialTokens.grey)
                .frame(width: 60, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview("Category Snapshot") {
    let categories = [
        CategoryBarModel(id: "social", name: "Social", minutes: 95, color: CategoryColorMap.social),
        CategoryBarModel(id: "video", name: "Video", minutes: 72, color: CategoryColorMap.video),
        CategoryBarModel(id: "games", name: "Games", minutes: 45, color: CategoryColorMap.games)
    ]

    CategorySnapshotView(categories: categories)
        .padding()
        .background(Color(hex: "#F8F8F6"))
}

#Preview("Category Snapshot - Empty") {
    CategorySnapshotView(categories: [])
        .padding()
        .background(Color(hex: "#F8F8F6"))
}

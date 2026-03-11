import SwiftUI

struct LeaderboardRowView: View {
    let member: LeaderboardMemberSnapshot
    let timeWindow: TimeWindow

    @State private var isExpanded: Bool = false

    private var rankColor: Color {
        guard let rank = member.rank else { return Theme.Colors.mutedForeground }
        switch rank {
        case 1: return Color(red: 1.0, green: 0.75, blue: 0.0)   // Gold - more saturated
        case 2: return Color(red: 0.55, green: 0.55, blue: 0.60) // Silver - darker
        case 3: return Color(red: 0.85, green: 0.45, blue: 0.15) // Bronze - richer
        default: return Theme.Colors.foreground
        }
    }

    private var displayTime: String {
        switch timeWindow {
        case .today:
            return member.formattedTodayTime
        case .last7Days, .previousWeek:
            return member.formattedWeeklyAvgTime
        }
    }

    private var timeLabel: String {
        switch timeWindow {
        case .today:
            return "today"
        case .last7Days:
            return "daily avg"
        case .previousWeek:
            return "daily avg"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: Theme.Spacing.md) {
                // Rank badge
                rankBadge

                // Avatar and name
                HStack(spacing: Theme.Spacing.sm) {
                    Avatar(displayName: member.displayName, size: .medium)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(member.displayName)
                            .font(.system(size: Theme.Typography.base, weight: .semibold))
                            .foregroundColor(Theme.Colors.foreground)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(minWidth: 80, maxWidth: 140, alignment: .leading)

                        if member.isCurrentUser {
                            Text("You")
                                .font(.system(size: Theme.Typography.xs, weight: .medium))
                                .foregroundColor(Theme.Colors.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.primary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                .fixedSize()
                        }

                        if member.isStale {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text("Data may be outdated")
                                    .font(.system(size: Theme.Typography.xs))
                            }
                            .foregroundColor(Theme.Colors.mutedForeground)
                        }
                    }
                }

                Spacer()

                // Screen time
                if member.isDataUnavailable {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("—")
                            .font(.system(size: Theme.Typography.lg, weight: .semibold))
                            .foregroundColor(Theme.Colors.mutedForeground)
                        Text("unavailable")
                            .font(.system(size: Theme.Typography.xs))
                            .foregroundColor(Theme.Colors.mutedForeground)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(displayTime)
                            .font(.system(size: Theme.Typography.lg, weight: .semibold))
                            .foregroundColor(Theme.Colors.foreground)
                        Text(timeLabel)
                            .font(.system(size: Theme.Typography.xs))
                            .foregroundColor(Theme.Colors.mutedForeground)
                    }
                }

                // Expand button (if has categories)
                if !member.topCategories.isEmpty && !member.isDataUnavailable {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(Theme.Colors.mutedForeground)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(Theme.Spacing.md)

            // Expanded categories
            if isExpanded && !member.topCategories.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Top Categories")
                        .font(.system(size: Theme.Typography.xs, weight: .medium))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    ForEach(member.topCategories) { category in
                        HStack {
                            Text(category.name)
                                .font(.system(size: Theme.Typography.sm))
                                .foregroundColor(Theme.Colors.foreground)

                            Spacer()

                            Text(category.formattedHours)
                                .font(.system(size: Theme.Typography.sm, weight: .medium))
                                .foregroundColor(Theme.Colors.mutedForeground)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.md)
                .padding(.leading, 48)  // Align with content after rank badge
            }
        }
        .background(member.isCurrentUser ? Theme.Colors.primary.opacity(0.05) : Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(member.isCurrentUser ? Theme.Colors.primary.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }

    private var rankBadge: some View {
        ZStack {
            if let rank = member.rank {
                if rank <= 3 {
                    // Medal for top 3
                    Circle()
                        .fill(rankColor.opacity(0.5))
                        .frame(width: 36, height: 36)

                    Text("\(rank)")
                        .font(.system(size: Theme.Typography.lg, weight: .black))
                        .foregroundColor(rankColor)
                } else {
                    // Number for others - use higher contrast
                    Circle()
                        .fill(Theme.Colors.muted)
                        .frame(width: 36, height: 36)

                    Text("\(rank)")
                        .font(.system(size: Theme.Typography.base, weight: .bold))
                        .foregroundColor(Theme.Colors.foreground)
                }
            } else {
                // No rank (data unavailable)
                Circle()
                    .fill(Theme.Colors.muted)
                    .frame(width: 36, height: 36)

                Text("—")
                    .font(.system(size: Theme.Typography.base, weight: .medium))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        LeaderboardRowView(
            member: LeaderboardMemberSnapshot(
                userId: UUID(),
                displayName: "Sarah",
                rank: 1,
                todayMinutes: 145,
                weeklyAvgMinutes: 180,
                topCategories: [
                    CategoryUsage(id: "social", name: "Social", hours: 1.2),
                    CategoryUsage(id: "video", name: "Video", hours: 0.8)
                ],
                isCurrentUser: false
            ),
            timeWindow: .today
        )

        LeaderboardRowView(
            member: LeaderboardMemberSnapshot(
                userId: UUID(),
                displayName: "Marco Zhuang",
                rank: 2,
                todayMinutes: 195,
                weeklyAvgMinutes: 210,
                topCategories: [
                    CategoryUsage(id: "social", name: "Social", hours: 1.5),
                    CategoryUsage(id: "games", name: "Games", hours: 1.0)
                ],
                isCurrentUser: true
            ),
            timeWindow: .today
        )

        LeaderboardRowView(
            member: LeaderboardMemberSnapshot(
                userId: UUID(),
                displayName: "Mike",
                rank: nil,
                isDataUnavailable: true,
                isCurrentUser: false
            ),
            timeWindow: .today
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

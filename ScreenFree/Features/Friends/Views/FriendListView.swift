import SwiftUI

struct FriendListView: View {
    let friends: [FriendRecord]
    let onUnfriend: (FriendRecord) -> Void
    let onBlock: (FriendRecord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Section header
            HStack {
                Text("Accountability Partners")
                    .font(.system(size: Theme.Typography.lg, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("(\(friends.count))")
                    .font(.system(size: Theme.Typography.lg))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Spacer()
            }

            // Friend rows
            VStack(spacing: Theme.Spacing.xs) {
                ForEach(friends) { friend in
                    FriendRowView(
                        friendRecord: friend,
                        onUnfriend: { onUnfriend(friend) },
                        onBlock: { onBlock(friend) }
                    )
                }
            }
        }
    }
}

#Preview {
    let friends = [
        FriendRecord(
            id: UUID(),
            requesterId: UUID(),
            recipientId: UUID(),
            status: .accepted,
            displayName: "Sarah"
        ),
        FriendRecord(
            id: UUID(),
            requesterId: UUID(),
            recipientId: UUID(),
            status: .accepted,
            displayName: "Mike"
        )
    ]

    FriendListView(
        friends: friends,
        onUnfriend: { _ in },
        onBlock: { _ in }
    )
    .padding()
    .background(Theme.Colors.background)
}

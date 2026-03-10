import SwiftUI

struct FriendRowView: View {
    let friendRecord: FriendRecord
    let onUnfriend: () -> Void
    let onBlock: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Avatar(displayName: friendRecord.displayName, size: .medium)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(friendRecord.displayName)
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("Accountability Partner")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }

            Spacer()

            Menu {
                Button(role: .destructive, action: onUnfriend) {
                    Label("Unfriend", systemImage: "person.badge.minus")
                }

                Button(role: .destructive, action: onBlock) {
                    Label("Block", systemImage: "nosign")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: Theme.Typography.base))
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 12) {
        FriendRowView(
            friendRecord: FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .accepted,
                displayName: "Sarah"
            ),
            onUnfriend: {},
            onBlock: {}
        )

        FriendRowView(
            friendRecord: FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .accepted,
                displayName: "Mike"
            ),
            onUnfriend: {},
            onBlock: {}
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

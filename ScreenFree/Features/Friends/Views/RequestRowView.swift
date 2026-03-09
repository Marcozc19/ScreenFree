import SwiftUI

struct RequestRowView: View {
    let friendRecord: FriendRecord
    let isProcessing: Bool
    let onAccept: (() -> Void)?
    let onDecline: (() -> Void)?
    let onCancel: (() -> Void)?

    private var isIncoming: Bool {
        friendRecord.status == .pendingIncoming
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Avatar(displayName: friendRecord.displayName, size: .medium)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(friendRecord.displayName)
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text(isIncoming ? "Wants to be friends" : "Request sent")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }

            Spacer()

            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            } else if isIncoming {
                // Incoming request - show accept/decline
                HStack(spacing: Theme.Spacing.xs) {
                    Button(action: { onDecline?() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: Theme.Typography.sm, weight: .semibold))
                            .foregroundColor(Theme.Colors.mutedForeground)
                            .frame(width: 36, height: 36)
                            .background(Theme.Colors.muted)
                            .clipShape(Circle())
                    }

                    Button(action: { onAccept?() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: Theme.Typography.sm, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Theme.Colors.primary)
                            .clipShape(Circle())
                    }
                }
            } else {
                // Outgoing request - show cancel
                Button(action: { onCancel?() }) {
                    Text("Cancel")
                        .font(.system(size: Theme.Typography.sm, weight: .medium))
                        .foregroundColor(Theme.Colors.mutedForeground)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Colors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }
}

#Preview {
    VStack(spacing: 12) {
        RequestRowView(
            friendRecord: FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .pendingIncoming,
                displayName: "Emma"
            ),
            isProcessing: false,
            onAccept: {},
            onDecline: {},
            onCancel: nil
        )

        RequestRowView(
            friendRecord: FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .pendingOutgoing,
                displayName: "Alex"
            ),
            isProcessing: false,
            onAccept: nil,
            onDecline: nil,
            onCancel: {}
        )

        RequestRowView(
            friendRecord: FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .pendingIncoming,
                displayName: "Processing"
            ),
            isProcessing: true,
            onAccept: {},
            onDecline: {},
            onCancel: nil
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

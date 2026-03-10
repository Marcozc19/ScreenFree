import SwiftUI

struct SearchResultCardView: View {
    let user: UserSearchMatch
    let isLoading: Bool
    let onSendRequest: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Avatar(displayName: user.displayName, size: .medium)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(user.displayName)
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("@\(user.userIdHandle)")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }

            Spacer()

            Button(action: onSendRequest) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: Theme.Typography.sm))

                        Text("Add")
                            .font(.system(size: Theme.Typography.sm, weight: .semibold))
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Theme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .disabled(isLoading)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        SearchResultCardView(
            user: UserSearchMatch(id: UUID(), displayName: "Sarah", userIdHandle: "sarah_123"),
            isLoading: false,
            onSendRequest: {}
        )

        SearchResultCardView(
            user: UserSearchMatch(id: UUID(), displayName: "Mike", userIdHandle: "mike_456"),
            isLoading: true,
            onSendRequest: {}
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

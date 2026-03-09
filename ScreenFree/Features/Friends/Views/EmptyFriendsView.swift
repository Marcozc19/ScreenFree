import SwiftUI

struct EmptyFriendsView: View {
    let onAddFriends: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Ghost avatars
            HStack(spacing: -Theme.Spacing.sm) {
                Avatar(displayName: nil, size: .medium, isGhost: true)
                    .offset(x: 8)

                Avatar(displayName: nil, size: .large, isGhost: true)
                    .zIndex(1)

                Avatar(displayName: nil, size: .medium, isGhost: true)
                    .offset(x: -8)
            }

            VStack(spacing: Theme.Spacing.xs) {
                Text("Add friends to compare")
                    .font(.system(size: Theme.Typography.lg, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("See how your screen time stacks up against your friends")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .multilineTextAlignment(.center)
            }

            Button(action: onAddFriends) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: Theme.Typography.base))

                    Text("Add Friends")
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Sizes.buttonHeight)
                .background(Theme.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    EmptyFriendsView(onAddFriends: {})
        .padding()
        .background(Theme.Colors.background)
}

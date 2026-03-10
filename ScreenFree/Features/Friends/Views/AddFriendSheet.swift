import SwiftUI

struct AddFriendSheet: View {
    @Binding var searchQuery: String
    let searchResult: FriendSearchResult
    let isProcessing: Bool
    let onSearch: () -> Void
    let onSendRequest: (UserSearchMatch) -> Void
    let onDismiss: () -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                // Search field
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Find by User ID")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    HStack(spacing: Theme.Spacing.sm) {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.Colors.mutedForeground)

                            TextField("Enter User ID", text: $searchQuery)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($isSearchFocused)
                                .onSubmit(onSearch)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        .frame(height: Theme.Sizes.inputHeight)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))

                        Button(action: onSearch) {
                            Text("Search")
                                .font(.system(size: Theme.Typography.base, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, Theme.Spacing.md)
                                .frame(height: Theme.Sizes.inputHeight)
                                .background(Theme.Colors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                        }
                        .disabled(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)

                // Search results
                VStack(spacing: Theme.Spacing.md) {
                    switch searchResult {
                    case .idle:
                        Spacer()
                        searchHint

                    case .loading:
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()

                    case .found(let user):
                        SearchResultCardView(
                            user: user,
                            isLoading: isProcessing,
                            onSendRequest: { onSendRequest(user) }
                        )
                        .padding(.horizontal, Theme.Spacing.lg)
                        Spacer()

                    case .notFound:
                        errorState(
                            icon: "person.slash",
                            message: "No user found with that ID"
                        )

                    case .selfSearch:
                        errorState(
                            icon: "face.smiling",
                            message: "That's you!"
                        )

                    case .requestAlreadySent:
                        errorState(
                            icon: "clock",
                            message: "You already have a pending request with this user"
                        )

                    case .alreadyFriend:
                        errorState(
                            icon: "person.2.fill",
                            message: "You're already accountability partners!"
                        )
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .onAppear {
                isSearchFocused = true
            }
        }
    }

    private var searchHint: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

            VStack(spacing: Theme.Spacing.xs) {
                Text("Search for friends")
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("Enter their User ID to send a friend request")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .multilineTextAlignment(.center)
            }

            // Demo hint
            VStack(spacing: Theme.Spacing.xxs) {
                Text("Try searching:")
                    .font(.system(size: Theme.Typography.xs))
                    .foregroundColor(Theme.Colors.mutedForeground)

                Text("Sarah, Mike, Emma, or Alex")
                    .font(.system(size: Theme.Typography.sm, weight: .medium))
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.top, Theme.Spacing.sm)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private func errorState(icon: String, message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

            Text(message)
                .font(.system(size: Theme.Typography.base))
                .foregroundColor(Theme.Colors.mutedForeground)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

#Preview("Idle") {
    AddFriendSheet(
        searchQuery: .constant(""),
        searchResult: .idle,
        isProcessing: false,
        onSearch: {},
        onSendRequest: { _ in },
        onDismiss: {}
    )
}

#Preview("Found") {
    AddFriendSheet(
        searchQuery: .constant("Sarah"),
        searchResult: .found(UserSearchMatch(id: UUID(), displayName: "Sarah", userIdHandle: "sarah_123")),
        isProcessing: false,
        onSearch: {},
        onSendRequest: { _ in },
        onDismiss: {}
    )
}

#Preview("Not Found") {
    AddFriendSheet(
        searchQuery: .constant("unknown"),
        searchResult: .notFound,
        isProcessing: false,
        onSearch: {},
        onSendRequest: { _ in },
        onDismiss: {}
    )
}

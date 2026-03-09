import SwiftUI

struct FriendsHubView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = FriendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Hero card with user's stats
                    FriendsHeroCard(
                        todayMins: userTodayMins,
                        weeklyAvgMins: userWeeklyAvgMins,
                        userName: appState.userProfile?.displayName
                    )

                    // Content based on state
                    switch viewModel.loadState {
                    case .loading:
                        loadingView

                    case .idle, .loaded:
                        if viewModel.hasFriends {
                            FriendListView(
                                friends: viewModel.acceptedFriends,
                                onUnfriend: { friend in
                                    Task { await viewModel.unfriend(friend) }
                                },
                                onBlock: { friend in
                                    Task { await viewModel.blockUser(friend) }
                                }
                            )
                        } else {
                            EmptyFriendsView {
                                viewModel.showAddFriendSheet = true
                            }
                        }

                    case .error(let message):
                        errorView(message: message)
                    }

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.hasPendingRequests {
                        Button {
                            viewModel.showRequestsMenu = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: Theme.Typography.lg))

                                if viewModel.pendingRequestCount > 0 {
                                    Circle()
                                        .fill(Theme.Colors.destructive)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                        .foregroundColor(Theme.Colors.foreground)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddFriendSheet = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: Theme.Typography.lg))
                    }
                    .foregroundColor(Theme.Colors.foreground)
                }
            }
            .sheet(isPresented: $viewModel.showAddFriendSheet) {
                AddFriendSheet(
                    searchQuery: $viewModel.searchQuery,
                    searchResult: viewModel.searchResult,
                    isProcessing: viewModel.isProcessingRequest,
                    onSearch: {
                        Task { await viewModel.searchUser() }
                    },
                    onSendRequest: { user in
                        Task { await viewModel.sendFriendRequest(to: user) }
                    },
                    onDismiss: {
                        viewModel.showAddFriendSheet = false
                        viewModel.searchQuery = ""
                        viewModel.searchResult = .idle
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showRequestsMenu) {
                RequestsMenuView(
                    pendingIncoming: viewModel.pendingIncoming,
                    pendingOutgoing: viewModel.pendingOutgoing,
                    isProcessing: viewModel.isProcessingRequest,
                    onAccept: { request in
                        Task { await viewModel.acceptRequest(request) }
                    },
                    onDecline: { request in
                        Task { await viewModel.declineRequest(request) }
                    },
                    onCancel: { request in
                        Task { await viewModel.cancelRequest(request) }
                    },
                    onDismiss: {
                        viewModel.showRequestsMenu = false
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .task {
                // Initialize view model with user data
                viewModel.currentUserId = appState.userProfile?.id

                // Load friends
                await viewModel.loadFriends()
            }
        }
    }

    // MARK: - User Stats (for hero card display)

    private var userTodayMins: Int {
        let hours = appState.screenTimeData?.totalHours ?? 4.0
        return Int(hours * 60 * 0.78)
    }

    private var userWeeklyAvgMins: Int {
        let hours = appState.screenTimeData?.totalHours ?? 4.0
        return Int(hours * 60)
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading friends...")
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.destructive)

            Text(message)
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.refreshFriends() }
            } label: {
                Text("Try Again")
                    .font(.system(size: Theme.Typography.sm, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
    }
}

#Preview {
    let appState = AppState()
    appState.userProfile = UserProfile(
        displayName: "Marco",
        ageRange: .age25to34,
        xp: 10,
        level: 1
    )
    appState.screenTimeData = .mock

    return FriendsHubView()
        .environment(appState)
}

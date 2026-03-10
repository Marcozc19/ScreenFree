import SwiftUI

struct SocialHubView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SocialViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Groups Section (Primary Content)
                    groupsSection

                    // Friends Section (Collapsed by default)
                    friendsSection

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Social")
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
                    Menu {
                        Button {
                            viewModel.showCreateGroupSheet = true
                        } label: {
                            Label("Create Group", systemImage: "plus.circle")
                        }

                        Button {
                            viewModel.showJoinGroupSheet = true
                        } label: {
                            Label("Join Group", systemImage: "ticket")
                        }

                        Divider()

                        Button {
                            viewModel.showAddFriendSheet = true
                        } label: {
                            Label("Add Friend", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: Theme.Typography.lg, weight: .semibold))
                    }
                    .foregroundColor(Theme.Colors.foreground)
                }
            }
            .sheet(isPresented: $viewModel.showCreateGroupSheet) {
                createGroupSheet
            }
            .sheet(isPresented: $viewModel.showJoinGroupSheet) {
                joinGroupSheet
            }
            .sheet(isPresented: $viewModel.showAddFriendSheet) {
                AddFriendSheet(
                    searchQuery: $viewModel.friendSearchQuery,
                    searchResult: viewModel.friendSearchResult,
                    isProcessing: viewModel.isProcessingAction,
                    onSearch: {
                        Task { await viewModel.searchUser() }
                    },
                    onSendRequest: { user in
                        Task { await viewModel.sendFriendRequest(to: user) }
                    },
                    onDismiss: {
                        viewModel.showAddFriendSheet = false
                        viewModel.friendSearchQuery = ""
                        viewModel.friendSearchResult = .idle
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showRequestsMenu) {
                RequestsMenuView(
                    pendingIncoming: viewModel.pendingIncoming,
                    pendingOutgoing: viewModel.pendingOutgoing,
                    isProcessing: viewModel.isProcessingAction,
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
                viewModel.currentUserId = appState.userProfile?.id
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Groups Section

    @ViewBuilder
    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header
            HStack {
                Text("Groups")
                    .font(.system(size: Theme.Typography.lg, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                if viewModel.hasGroups {
                    Text("(\(viewModel.groups.count))")
                        .font(.system(size: Theme.Typography.lg))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }

                Spacer()
            }

            // Content
            switch viewModel.loadState {
            case .loading:
                loadingView

            case .idle, .loaded:
                if viewModel.hasGroups {
                    groupsList
                } else {
                    emptyGroupsView
                }

            case .error(let message):
                errorView(message: message)
            }
        }
    }

    private var groupsList: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ForEach(viewModel.groups) { group in
                NavigationLink {
                    GroupDetailView(group: group)
                } label: {
                    GroupRowView(group: group)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyGroupsView: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Ghost group slots
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: Theme.Radius.lg)
                        .fill(Theme.Colors.muted.opacity(0.3))
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: "person.3")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.Colors.mutedForeground.opacity(0.3))
                        )
                }
            }

            VStack(spacing: Theme.Spacing.xs) {
                Text("No groups yet")
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text("Create or join a group to share your screen time progress")
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: Theme.Spacing.sm) {
                Button {
                    viewModel.showCreateGroupSheet = true
                } label: {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "plus.circle")
                        Text("Create")
                    }
                    .font(.system(size: Theme.Typography.sm, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                }

                Button {
                    viewModel.showJoinGroupSheet = true
                } label: {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: "ticket")
                        Text("Join")
                    }
                    .font(.system(size: Theme.Typography.sm, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }

    // MARK: - Friends Section (Collapsed)

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Disclosure group header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isFriendsSectionExpanded.toggle()
                    if viewModel.isFriendsSectionExpanded {
                        viewModel.logFriendsSectionExpanded()
                    }
                }
            } label: {
                HStack {
                    Text("Accountability Partners")
                        .font(.system(size: Theme.Typography.base, weight: .medium))
                        .foregroundColor(Theme.Colors.foreground)

                    Text("(\(viewModel.acceptedFriends.count))")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Spacer()

                    Image(systemName: viewModel.isFriendsSectionExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: Theme.Typography.sm, weight: .medium))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            }
            .buttonStyle(.plain)

            // Expanded content
            if viewModel.isFriendsSectionExpanded {
                if viewModel.hasFriends {
                    VStack(spacing: Theme.Spacing.xs) {
                        ForEach(viewModel.acceptedFriends) { friend in
                            FriendRowView(
                                friendRecord: friend,
                                onUnfriend: {
                                    Task { await viewModel.unfriend(friend) }
                                },
                                onBlock: {
                                    Task { await viewModel.blockUser(friend) }
                                }
                            )
                        }
                    }
                } else {
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("No accountability partners yet")
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(Theme.Colors.mutedForeground)

                        Button {
                            viewModel.showAddFriendSheet = true
                        } label: {
                            HStack(spacing: Theme.Spacing.xxs) {
                                Image(systemName: "person.badge.plus")
                                Text("Add Friend")
                            }
                            .font(.system(size: Theme.Typography.sm, weight: .semibold))
                            .foregroundColor(Theme.Colors.primary)
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }
            }
        }
    }

    // MARK: - Sheets

    private var createGroupSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Group Name")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    TextField("e.g., Work Buddies", text: $viewModel.newGroupName)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, Theme.Spacing.md)
                        .frame(height: Theme.Sizes.inputHeight)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }

                VStack(spacing: Theme.Spacing.xs) {
                    Text("You'll get a 6-character invite code to share")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }

                Spacer()

                Button {
                    Task { await viewModel.createGroup() }
                } label: {
                    HStack {
                        if viewModel.isProcessingAction {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create Group")
                        }
                    }
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Sizes.buttonHeight)
                    .background(Theme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }
                .disabled(viewModel.newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessingAction)
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showCreateGroupSheet = false
                        viewModel.newGroupName = ""
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var joinGroupSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Invite Code")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    TextField("Enter 6-character code", text: $viewModel.joinGroupCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(.horizontal, Theme.Spacing.md)
                        .frame(height: Theme.Sizes.inputHeight)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                        .onChange(of: viewModel.joinGroupCode) { _, newValue in
                            viewModel.joinGroupCode = String(newValue.uppercased().prefix(6))
                        }

                    if let error = viewModel.joinGroupError {
                        Text(error)
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(Theme.Colors.destructive)
                    }
                }

                VStack(spacing: Theme.Spacing.xs) {
                    Text("Ask your group admin for the invite code")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }

                Spacer()

                Button {
                    Task { await viewModel.joinGroup() }
                } label: {
                    HStack {
                        if viewModel.isProcessingAction {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Join Group")
                        }
                    }
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Sizes.buttonHeight)
                    .background(Theme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }
                .disabled(viewModel.joinGroupCode.count != 6 || viewModel.isProcessingAction)
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showJoinGroupSheet = false
                        viewModel.joinGroupCode = ""
                        viewModel.joinGroupError = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helper Views

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading...")
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
                Task { await viewModel.refreshData() }
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

// MARK: - Group Row View

struct GroupRowView: View {
    let group: GroupRecord

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Group icon
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.primary)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(group.groupName)
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                HStack(spacing: Theme.Spacing.xs) {
                    Text("\(group.memberCount) members")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    if group.isAdmin {
                        Text("• Admin")
                            .font(.system(size: Theme.Typography.sm, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }

            Spacer()

            // Rank badge (if available)
            if let rank = group.userCurrentRank {
                VStack(spacing: 2) {
                    Text("#\(rank)")
                        .font(.system(size: Theme.Typography.lg, weight: .bold))
                        .foregroundColor(Theme.Colors.foreground)

                    Text("rank")
                        .font(.system(size: Theme.Typography.xs))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
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

    return SocialHubView()
        .environment(appState)
}

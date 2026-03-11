import SwiftUI

struct GroupDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GroupDetailViewModel

    init(group: GroupRecord) {
        _viewModel = State(initialValue: GroupDetailViewModel(group: group))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Group Header
                groupHeader

                // Leaderboard Section
                leaderboardSection

                // Admin Section (if admin)
                if viewModel.group.isAdmin {
                    adminSection
                }

                // Leave/Delete Section
                actionSection

                Spacer(minLength: Theme.Spacing.xxl)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(viewModel.group.groupName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.group.isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showRenameSheet = true
                        } label: {
                            Label("Rename Group", systemImage: "pencil")
                        }

                        Button {
                            viewModel.regenerateInviteCode()
                        } label: {
                            Label("New Invite Code", systemImage: "arrow.triangle.2.circlepath")
                        }

                        Divider()

                        Button(role: .destructive) {
                            viewModel.showDeleteConfirmation = true
                        } label: {
                            Label("Delete Group", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: Theme.Typography.base))
                    }
                    .foregroundColor(Theme.Colors.foreground)
                }
            }
        }
        .sheet(isPresented: $viewModel.showRenameSheet) {
            renameSheet
        }
        .sheet(isPresented: $viewModel.showInviteSheet) {
            inviteSheet
        }
        .sheet(isPresented: $viewModel.showInviteFriendsSheet) {
            inviteFriendsSheet
        }
        .alert("Delete Group?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteGroup()
                    dismiss()
                }
            }
        } message: {
            Text("This will remove all members and delete the group permanently.")
        }
        .alert("Leave Group?", isPresented: $viewModel.showLeaveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                Task {
                    await viewModel.leaveGroup()
                    dismiss()
                }
            }
        } message: {
            Text("You'll need a new invite code to rejoin.")
        }
        .task {
            viewModel.currentUserId = appState.userProfile?.id
            await viewModel.loadLeaderboard()
        }
    }

    // MARK: - Group Header

    private var groupHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Group icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 72, height: 72)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.Colors.primary)
            }

            // Group info
            VStack(spacing: Theme.Spacing.xs) {
                Text("\(viewModel.group.memberCount) members")
                    .font(.system(size: Theme.Typography.base))
                    .foregroundColor(Theme.Colors.mutedForeground)

                if viewModel.group.isAdmin, let code = viewModel.group.inviteCode {
                    Button {
                        viewModel.showInviteSheet = true
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Text("Invite Code:")
                                .foregroundColor(Theme.Colors.mutedForeground)
                            Text(code)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Colors.primary)
                            Image(systemName: "square.on.square")
                                .font(.system(size: Theme.Typography.sm))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .font(.system(size: Theme.Typography.sm))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }

    // MARK: - Leaderboard Section

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header with time window picker
            HStack {
                Text("Leaderboard")
                    .font(.system(size: Theme.Typography.lg, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Spacer()

                Picker("Time Window", selection: $viewModel.selectedTimeWindow) {
                    ForEach(TimeWindow.allCases, id: \.self) { window in
                        Text(window.rawValue).tag(window)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.selectedTimeWindow) { _, _ in
                    Task { await viewModel.loadLeaderboard() }
                }
            }

            // Leaderboard content
            switch viewModel.leaderboardState {
            case .loading:
                leaderboardLoading

            case .loaded:
                if viewModel.leaderboardMembers.isEmpty {
                    leaderboardEmpty
                } else {
                    leaderboardList
                }

            case .error(let message):
                leaderboardError(message: message)
            }
        }
    }

    private var leaderboardLoading: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
            Text("Loading leaderboard...")
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
    }

    private var leaderboardEmpty: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

            Text("No data yet")
                .font(.system(size: Theme.Typography.base))
                .foregroundColor(Theme.Colors.mutedForeground)

            Text("Screen time data will appear as members sync")
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
    }

    private var leaderboardList: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ForEach(viewModel.leaderboardMembers) { member in
                LeaderboardRowView(
                    member: member,
                    timeWindow: viewModel.selectedTimeWindow
                )
            }
        }
    }

    private func leaderboardError(message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Theme.Colors.destructive)

            Text(message)
                .font(.system(size: Theme.Typography.sm))
                .foregroundColor(Theme.Colors.mutedForeground)

            Button {
                Task { await viewModel.loadLeaderboard() }
            } label: {
                Text("Retry")
                    .font(.system(size: Theme.Typography.sm, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
    }

    // MARK: - Admin Section

    private var adminSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Members")
                .font(.system(size: Theme.Typography.lg, weight: .semibold))
                .foregroundColor(Theme.Colors.foreground)

            VStack(spacing: Theme.Spacing.xs) {
                ForEach(viewModel.groupMembers) { member in
                    memberRow(member)
                }
            }
        }
    }

    private func memberRow(_ member: GroupMember) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Avatar(displayName: member.displayName, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(member.displayName)
                        .font(.system(size: Theme.Typography.base, weight: .medium))
                        .foregroundColor(Theme.Colors.foreground)

                    if member.isAdmin {
                        Text("Admin")
                            .font(.system(size: Theme.Typography.xs, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.Colors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                    }
                }

                Text("Joined \(member.joinedAt.formatted(.relative(presentation: .named)))")
                    .font(.system(size: Theme.Typography.xs))
                    .foregroundColor(Theme.Colors.mutedForeground)
            }

            Spacer()

            if !member.isAdmin && viewModel.group.isAdmin {
                Menu {
                    Button {
                        Task { await viewModel.transferAdmin(to: member) }
                    } label: {
                        Label("Make Admin", systemImage: "crown")
                    }

                    Button(role: .destructive) {
                        Task { await viewModel.removeMember(member) }
                    } label: {
                        Label("Remove", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if !viewModel.group.isAdmin {
                Button {
                    viewModel.showLeaveConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Leave Group")
                    }
                    .font(.system(size: Theme.Typography.base, weight: .medium))
                    .foregroundColor(Theme.Colors.destructive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Theme.Colors.destructive.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }
            }
        }
    }

    // MARK: - Sheets

    private var renameSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Group Name")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    TextField("Group name", text: $viewModel.newGroupName)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, Theme.Spacing.md)
                        .frame(height: Theme.Sizes.inputHeight)
                        .background(Theme.Colors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.renameGroup()
                        viewModel.showRenameSheet = false
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight)
                        .background(Theme.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                }
                .disabled(viewModel.newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
            .navigationTitle("Rename Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showRenameSheet = false
                    }
                }
            }
            .onAppear {
                viewModel.newGroupName = viewModel.group.groupName
            }
        }
        .presentationDetents([.medium])
    }

    private var inviteSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                // Invite code display
                VStack(spacing: Theme.Spacing.md) {
                    Text("Share this code")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    if let code = viewModel.group.inviteCode {
                        Text(code)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.Colors.foreground)
                            .kerning(8)
                    }

                    Text("Anyone with this code can join \(viewModel.group.groupName)")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Actions
                VStack(spacing: Theme.Spacing.sm) {
                    Button {
                        viewModel.copyInviteCode()
                    } label: {
                        HStack {
                            Image(systemName: viewModel.didCopyCode ? "checkmark" : "doc.on.doc")
                            Text(viewModel.didCopyCode ? "Copied!" : "Copy Code")
                        }
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight)
                        .background(Theme.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                    }

                    Button {
                        viewModel.shareInviteCode()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                    }

                    Button {
                        viewModel.showInviteSheet = false
                        viewModel.showInviteFriendsSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Invite Friends")
                        }
                        .font(.system(size: Theme.Typography.base, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
                    }
                }
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
            .navigationTitle("Invite Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showInviteSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var inviteFriendsSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.md) {
                if viewModel.isLoadingFriends {
                    Spacer()
                    ProgressView()
                    Text("Loading friends...")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)
                    Spacer()
                } else if viewModel.availableFriends.isEmpty {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

                        Text("No friends to invite")
                            .font(.system(size: Theme.Typography.base, weight: .medium))
                            .foregroundColor(Theme.Colors.mutedForeground)

                        Text("All your accountability partners are already in this group, or you haven't added any yet.")
                            .font(.system(size: Theme.Typography.sm))
                            .foregroundColor(Theme.Colors.mutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.Spacing.xl)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.xs) {
                            ForEach(viewModel.availableFriends) { friend in
                                inviteFriendRow(friend)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, Theme.Spacing.md)
                    }
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showInviteFriendsSheet = false
                    }
                }
            }
            .task {
                await viewModel.loadAvailableFriends()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func inviteFriendRow(_ friend: FriendRecord) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Avatar(displayName: friend.displayName, size: .small)

            Text(friend.displayName)
                .font(.system(size: Theme.Typography.base, weight: .medium))
                .foregroundColor(Theme.Colors.foreground)

            Spacer()

            if viewModel.isFriendInvited(friend) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                    Text("Invited")
                }
                .font(.system(size: Theme.Typography.sm, weight: .medium))
                .foregroundColor(Theme.Colors.primary)
            } else {
                Button {
                    Task {
                        await viewModel.inviteFriendToGroup(friend)
                    }
                } label: {
                    Text("Invite")
                        .font(.system(size: Theme.Typography.sm, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Colors.primary)
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
    NavigationStack {
        GroupDetailView(group: GroupRecord(
            groupName: "Work Buddies",
            inviteCode: "ABC123",
            isAdmin: true,
            memberCount: 4,
            userCurrentRank: 2
        ))
    }
    .environment(AppState())
}

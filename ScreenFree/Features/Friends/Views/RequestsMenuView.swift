import SwiftUI

struct RequestsMenuView: View {
    let pendingIncoming: [FriendRecord]
    let pendingOutgoing: [FriendRecord]
    let isProcessing: Bool
    let onAccept: (FriendRecord) -> Void
    let onDecline: (FriendRecord) -> Void
    let onCancel: (FriendRecord) -> Void
    let onDismiss: () -> Void

    @State private var selectedTab: RequestTab = .received

    enum RequestTab: String, CaseIterable {
        case received = "Received"
        case sent = "Sent"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("Request Type", selection: $selectedTab) {
                    ForEach(RequestTab.allCases, id: \.self) { tab in
                        HStack {
                            Text(tab.rawValue)
                            if tab == .received && !pendingIncoming.isEmpty {
                                Text("(\(pendingIncoming.count))")
                            } else if tab == .sent && !pendingOutgoing.isEmpty {
                                Text("(\(pendingOutgoing.count))")
                            }
                        }
                        .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)

                Divider()

                // Content
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        switch selectedTab {
                        case .received:
                            if pendingIncoming.isEmpty {
                                emptyState(
                                    icon: "tray",
                                    title: "No pending requests",
                                    message: "Friend requests you receive will appear here"
                                )
                            } else {
                                ForEach(pendingIncoming) { request in
                                    RequestRowView(
                                        friendRecord: request,
                                        isProcessing: isProcessing,
                                        onAccept: { onAccept(request) },
                                        onDecline: { onDecline(request) },
                                        onCancel: nil
                                    )
                                }
                            }

                        case .sent:
                            if pendingOutgoing.isEmpty {
                                emptyState(
                                    icon: "paperplane",
                                    title: "No sent requests",
                                    message: "Requests you send will appear here"
                                )
                            } else {
                                ForEach(pendingOutgoing) { request in
                                    RequestRowView(
                                        friendRecord: request,
                                        isProcessing: isProcessing,
                                        onAccept: nil,
                                        onDecline: nil,
                                        onCancel: { onCancel(request) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("Friend Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.mutedForeground.opacity(0.5))

            VStack(spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(.system(size: Theme.Typography.base, weight: .semibold))
                    .foregroundColor(Theme.Colors.foreground)

                Text(message)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.mutedForeground)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
    }
}

#Preview {
    RequestsMenuView(
        pendingIncoming: [
            FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .pendingIncoming,
                displayName: "Emma"
            )
        ],
        pendingOutgoing: [
            FriendRecord(
                requesterId: UUID(),
                recipientId: UUID(),
                status: .pendingOutgoing,
                displayName: "Alex"
            )
        ],
        isProcessing: false,
        onAccept: { _ in },
        onDecline: { _ in },
        onCancel: { _ in },
        onDismiss: {}
    )
}

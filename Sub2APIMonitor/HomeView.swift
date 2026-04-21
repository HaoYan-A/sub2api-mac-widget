import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var session: UserSession
    @State private var isRefreshing: Bool = false
    @State private var autoRefreshTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if let stats = session.latestStats {
                statsView(stats)
            } else {
                ContentUnavailableView(
                    "No data yet",
                    systemImage: "icloud.slash",
                    description: Text("Tap refresh to fetch your latest usage")
                )
                .frame(maxHeight: .infinity)
            }
            Divider()
            footer
        }
        .task {
            await session.refreshNow()
            startAutoRefresh()
        }
        .onDisappear {
            autoRefreshTask?.cancel()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, \(session.email)")
                    .font(.headline)
                if let updated = session.lastUpdatedAt {
                    Text("Last updated: \(Formatting.relativeTime(updated))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(action: manualRefresh) {
                if isRefreshing {
                    ProgressView().controlSize(.small)
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .disabled(isRefreshing)
        }
        .padding()
    }

    private func statsView(_ stats: DashboardStats) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Today Cost", value: Formatting.cost(stats.todayActualCost), accent: .orange)
                StatCard(title: "Today Tokens", value: Formatting.shortNumber(stats.todayTokens), accent: .blue)
                StatCard(title: "Today Requests", value: Formatting.longNumber(stats.todayRequests), accent: .green)
                StatCard(title: "Total Cost", value: Formatting.cost(stats.totalActualCost), accent: .purple)
                StatCard(title: "RPM / TPM", value: "\(stats.rpm) / \(Formatting.shortNumber(stats.tpm))", accent: .teal)
                StatCard(title: "Active Keys", value: "\(stats.activeAPIKeys) / \(stats.totalAPIKeys)", accent: .indigo)
            }
            .padding()
        }
    }

    private var footer: some View {
        HStack {
            if let err = session.errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Auto refresh every 30s when app is open")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive) {
                Task {
                    await AuthService.shared.logout()
                    session.markLoggedOut()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } label: {
                Text("Sign Out").font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func manualRefresh() {
        isRefreshing = true
        Task {
            defer { isRefreshing = false }
            await session.refreshNow()
        }
    }

    /// 主 App 打开时的高频自刷新（关闭后停止，不影响 widget）
    private func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                if Task.isCancelled { break }
                await session.refreshNow()
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
    }
}

import WidgetKit
import Foundation

struct UsageProvider: TimelineProvider {

    // Xcode 预览 / 首次展示占位
    func placeholder(in context: Context) -> UsageEntry {
        .placeholder
    }

    // Widget Gallery 预览 / 添加时的快照
    func getSnapshot(in context: Context, completion: @escaping (UsageEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        completion(currentCachedEntry())
    }

    // 真实调度
    func getTimeline(in context: Context, completion: @escaping (Timeline<UsageEntry>) -> Void) {
        Task {
            let entry = await fetchLatestEntry()
            // 下一次刷新点：N 分钟后（系统会按预算决定是否真的执行）
            let nextUpdate = Date().addingTimeInterval(AppConfig.widgetRefreshInterval)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    // MARK: - 数据获取

    /// 纯读缓存，不发网络（为 getSnapshot 准备）
    private func currentCachedEntry() -> UsageEntry {
        UsageEntry(
            date: SharedStore.lastStatsAt ?? .now,
            stats: SharedStore.lastStats,
            trend: SharedStore.lastTrend ?? [],
            errorMessage: SharedStore.serverURL == nil ? "Open app to configure" : nil
        )
    }

    /// 带网络请求：尝试刷新，失败则退回缓存
    private func fetchLatestEntry() async -> UsageEntry {
        // 服务器未配置或未登录
        guard SharedStore.serverURL != nil,
              SharedStore.userEmail != nil else {
            return .notConfigured
        }

        do {
            async let statsTask = AuthService.shared.fetchDashboardStats()
            async let trendTask = AuthService.shared.fetchTrend()
            let stats = try await statsTask
            let trend = (try? await trendTask) ?? (SharedStore.lastTrend ?? [])
            return UsageEntry(date: .now, stats: stats, trend: trend, errorMessage: nil)
        } catch {
            // 网络/鉴权失败：用缓存兜底，显示错误徽标
            return UsageEntry(
                date: SharedStore.lastStatsAt ?? .now,
                stats: SharedStore.lastStats,
                trend: SharedStore.lastTrend ?? [],
                errorMessage: error.localizedDescription
            )
        }
    }
}

import AppIntents
import WidgetKit

/// Widget 上的"刷新"按钮绑定的 Intent
/// macOS 14+ 支持在 widget 里放 Button(intent:) 来立即触发刷新
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Usage"
    static var description = IntentDescription("Fetch the latest AI usage from sub2api")

    func perform() async throws -> some IntentResult {
        // 直接拉一次最新数据，顺便更新 SharedStore
        _ = try? await AuthService.shared.fetchDashboardStats()
        _ = try? await AuthService.shared.fetchTrend()
        // 触发 widget 重新获取 timeline
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

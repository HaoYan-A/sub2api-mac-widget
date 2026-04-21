import Foundation

/// 应用全局常量配置
enum AppConfig {
    /// App Group ID — 主 App 和 Widget Extension 共享数据需要两端 Entitlements 保持一致
    static let appGroupID = "group.com.yanhao.sub2api.monitor"

    /// Keychain 共享服务名
    static let keychainService = "com.yanhao.sub2api.monitor"

    /// 用户偏好设置 Key
    enum PreferencesKey {
        static let serverURL = "server_url"
        static let userEmail = "user_email"
        static let lastStats = "last_dashboard_stats"
        static let lastStatsTimestamp = "last_dashboard_stats_timestamp"
        static let lastTrend = "last_dashboard_trend"
    }

    /// Widget 刷新间隔（秒）。苹果实际会按系统预算调度，这个值是建议值
    static let widgetRefreshInterval: TimeInterval = 15 * 60

    /// Token 续期阈值：距离过期少于此时间时触发 refresh
    static let tokenRefreshThreshold: TimeInterval = 5 * 60
}

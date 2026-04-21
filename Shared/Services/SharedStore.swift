import Foundation

/// App Group 共享存储
/// 主 App 把最新数据写入这里，Widget Extension 读取以实现秒开
enum SharedStore {

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard
    }

    // MARK: - 服务器配置

    static var serverURL: String? {
        get { defaults.string(forKey: AppConfig.PreferencesKey.serverURL) }
        set { defaults.set(newValue, forKey: AppConfig.PreferencesKey.serverURL) }
    }

    static var userEmail: String? {
        get { defaults.string(forKey: AppConfig.PreferencesKey.userEmail) }
        set { defaults.set(newValue, forKey: AppConfig.PreferencesKey.userEmail) }
    }

    // MARK: - 缓存的统计数据

    static var lastStats: DashboardStats? {
        get {
            guard let data = defaults.data(forKey: AppConfig.PreferencesKey.lastStats) else { return nil }
            return try? JSONDecoder().decode(DashboardStats.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: AppConfig.PreferencesKey.lastStats)
                defaults.set(Date().timeIntervalSince1970, forKey: AppConfig.PreferencesKey.lastStatsTimestamp)
            } else {
                defaults.removeObject(forKey: AppConfig.PreferencesKey.lastStats)
                defaults.removeObject(forKey: AppConfig.PreferencesKey.lastStatsTimestamp)
            }
        }
    }

    static var lastStatsAt: Date? {
        let ts = defaults.double(forKey: AppConfig.PreferencesKey.lastStatsTimestamp)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }

    static var lastTrend: [TrendPoint]? {
        get {
            guard let data = defaults.data(forKey: AppConfig.PreferencesKey.lastTrend) else { return nil }
            return try? JSONDecoder().decode([TrendPoint].self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: AppConfig.PreferencesKey.lastTrend)
            } else {
                defaults.removeObject(forKey: AppConfig.PreferencesKey.lastTrend)
            }
        }
    }

    /// 清除所有缓存
    static func clearCache() {
        defaults.removeObject(forKey: AppConfig.PreferencesKey.lastStats)
        defaults.removeObject(forKey: AppConfig.PreferencesKey.lastStatsTimestamp)
        defaults.removeObject(forKey: AppConfig.PreferencesKey.lastTrend)
    }
}

import Foundation

/// 对应 GET /api/v1/usage/dashboard/stats
struct DashboardStats: Codable, Equatable {
    let totalAPIKeys: Int64
    let activeAPIKeys: Int64

    // 累计
    let totalRequests: Int64
    let totalInputTokens: Int64
    let totalOutputTokens: Int64
    let totalCacheCreationTokens: Int64
    let totalCacheReadTokens: Int64
    let totalTokens: Int64
    let totalCost: Double
    let totalActualCost: Double

    // 今日
    let todayRequests: Int64
    let todayInputTokens: Int64
    let todayOutputTokens: Int64
    let todayCacheCreationTokens: Int64
    let todayCacheReadTokens: Int64
    let todayTokens: Int64
    let todayCost: Double
    let todayActualCost: Double

    // 实时
    let averageDurationMs: Double
    let rpm: Int64
    let tpm: Int64

    enum CodingKeys: String, CodingKey {
        case totalAPIKeys = "total_api_keys"
        case activeAPIKeys = "active_api_keys"
        case totalRequests = "total_requests"
        case totalInputTokens = "total_input_tokens"
        case totalOutputTokens = "total_output_tokens"
        case totalCacheCreationTokens = "total_cache_creation_tokens"
        case totalCacheReadTokens = "total_cache_read_tokens"
        case totalTokens = "total_tokens"
        case totalCost = "total_cost"
        case totalActualCost = "total_actual_cost"
        case todayRequests = "today_requests"
        case todayInputTokens = "today_input_tokens"
        case todayOutputTokens = "today_output_tokens"
        case todayCacheCreationTokens = "today_cache_creation_tokens"
        case todayCacheReadTokens = "today_cache_read_tokens"
        case todayTokens = "today_tokens"
        case todayCost = "today_cost"
        case todayActualCost = "today_actual_cost"
        case averageDurationMs = "average_duration_ms"
        case rpm
        case tpm
    }

    /// 用于 SwiftUI 预览和 widget placeholder 的假数据
    static let preview = DashboardStats(
        totalAPIKeys: 8,
        activeAPIKeys: 6,
        totalRequests: 144_559,
        totalInputTokens: 1_146_832_620,
        totalOutputTokens: 75_536_718,
        totalCacheCreationTokens: 441_574_583,
        totalCacheReadTokens: 14_014_545_989,
        totalTokens: 15_678_489_910,
        totalCost: 15_437.70,
        totalActualCost: 15_437.70,
        todayRequests: 283,
        todayInputTokens: 2_240_112,
        todayOutputTokens: 186_784,
        todayCacheCreationTokens: 555_780,
        todayCacheReadTokens: 8_299_839,
        todayTokens: 11_282_515,
        todayCost: 16.49,
        todayActualCost: 16.49,
        averageDurationMs: 11_550.37,
        rpm: 1,
        tpm: 785
    )
}

/// 对应 GET /api/v1/usage/dashboard/trend（最近 N 天每日汇总）
struct TrendResponse: Codable {
    let startDate: String
    let endDate: String
    let granularity: String
    let trend: [TrendPoint]

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case granularity
        case trend
    }
}

struct TrendPoint: Codable, Equatable, Identifiable {
    let date: String
    let requests: Int64
    let totalTokens: Int64
    let actualCost: Double

    var id: String { date }

    enum CodingKeys: String, CodingKey {
        case date
        case requests
        case totalTokens = "total_tokens"
        case actualCost = "actual_cost"
    }

    static let previewList: [TrendPoint] = [
        .init(date: "2026-04-14", requests: 4584, totalTokens: 614_386_499, actualCost: 645.87),
        .init(date: "2026-04-15", requests: 5262, totalTokens: 820_139_814, actualCost: 1047.90),
        .init(date: "2026-04-16", requests: 8768, totalTokens: 910_786_418, actualCost: 1450.29),
        .init(date: "2026-04-17", requests: 5661, totalTokens: 785_458_896, actualCost: 1937.19),
        .init(date: "2026-04-18", requests: 2863, totalTokens: 395_034_471, actualCost: 298.35),
        .init(date: "2026-04-19", requests: 4162, totalTokens: 773_440_389, actualCost: 523.31),
        .init(date: "2026-04-20", requests: 8957, totalTokens: 1_154_032_952, actualCost: 1034.32),
        .init(date: "2026-04-21", requests: 283, totalTokens: 11_282_515, actualCost: 16.49)
    ]
}

import WidgetKit

/// Widget Timeline 单条目：某一时刻要显示的快照
struct UsageEntry: TimelineEntry {
    let date: Date
    let stats: DashboardStats?
    let trend: [TrendPoint]
    let errorMessage: String?

    static let placeholder = UsageEntry(
        date: .now,
        stats: .preview,
        trend: TrendPoint.previewList,
        errorMessage: nil
    )

    static let notConfigured = UsageEntry(
        date: .now,
        stats: nil,
        trend: [],
        errorMessage: "Open app to configure"
    )
}

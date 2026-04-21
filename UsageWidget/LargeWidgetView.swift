import SwiftUI
import WidgetKit
import Charts

struct LargeWidgetView: View {
    let entry: UsageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部 header
            HStack {
                Label("Sub2API Monitor", systemImage: "chart.bar.xaxis.ascending")
                    .font(.caption).bold()
                Spacer()
                Button(intent: RefreshIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }

            if let stats = entry.stats {
                // 4 格指标
                HStack(spacing: 8) {
                    BigStatCell(title: "Today Cost",
                                value: Formatting.cost(stats.todayActualCost),
                                color: .orange)
                    BigStatCell(title: "Today Tokens",
                                value: Formatting.shortNumber(stats.todayTokens),
                                color: .blue)
                }
                HStack(spacing: 8) {
                    BigStatCell(title: "Requests",
                                value: Formatting.longNumber(stats.todayRequests),
                                color: .green)
                    BigStatCell(title: "Total Cost",
                                value: Formatting.cost(stats.totalActualCost),
                                color: .purple)
                }

                // 7 天趋势柱状图
                if !entry.trend.isEmpty {
                    Chart(entry.trend) { point in
                        BarMark(
                            x: .value("Date", shortDate(point.date)),
                            y: .value("Cost", point.actualCost)
                        )
                        .foregroundStyle(Color.orange.gradient)
                        .cornerRadius(3)
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing) { _ in
                            AxisValueLabel().font(.system(size: 8))
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel().font(.system(size: 8))
                        }
                    }
                    .frame(height: 70)
                }

                Spacer(minLength: 0)

                // 底部状态行
                HStack {
                    Label("\(stats.activeAPIKeys)/\(stats.totalAPIKeys) keys active",
                          systemImage: "key.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label("\(stats.rpm) rpm", systemImage: "speedometer")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if let err = entry.errorMessage {
                    Label(err, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                }
            } else {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "icloud.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(entry.errorMessage ?? "No data")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
        }
    }

    /// "2026-04-21" → "04-21"
    private func shortDate(_ s: String) -> String {
        let parts = s.split(separator: "-")
        guard parts.count == 3 else { return s }
        return "\(parts[1])-\(parts[2])"
    }
}

#Preview(as: .systemLarge) {
    UsageWidget()
} timeline: {
    UsageEntry.placeholder
}

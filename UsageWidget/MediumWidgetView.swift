import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: UsageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 顶部
            HStack {
                Label("Sub2API Today", systemImage: "chart.bar.fill")
                    .font(.caption).bold()
                    .foregroundStyle(.secondary)
                Spacer()
                Button(intent: RefreshIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
            }

            if let stats = entry.stats {
                HStack(spacing: 10) {
                    BigStatCell(title: "Cost",
                                value: Formatting.cost(stats.todayActualCost),
                                color: .orange)
                    BigStatCell(title: "Tokens",
                                value: Formatting.shortNumber(stats.todayTokens),
                                color: .blue)
                    BigStatCell(title: "Requests",
                                value: Formatting.longNumber(stats.todayRequests),
                                color: .green)
                }

                Spacer(minLength: 0)

                HStack {
                    Label("Total \(Formatting.cost(stats.totalActualCost))",
                          systemImage: "sum")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let err = entry.errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    } else {
                        Text(entry.date, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                Spacer()
                VStack {
                    Image(systemName: "icloud.slash")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(entry.errorMessage ?? "No data")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
        }
    }
}

struct BigStatCell: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview(as: .systemMedium) {
    UsageWidget()
} timeline: {
    UsageEntry.placeholder
}

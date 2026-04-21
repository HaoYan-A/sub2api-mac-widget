import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: UsageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("TODAY")
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if let stats = entry.stats {
                Text(Formatting.cost(stats.todayActualCost))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                HStack(spacing: 8) {
                    IconStat(icon: "paperplane.fill",
                             value: Formatting.longNumber(stats.todayRequests),
                             color: .blue)
                    IconStat(icon: "doc.text.fill",
                             value: Formatting.shortNumber(stats.todayTokens),
                             color: .purple)
                }
                .font(.caption2)
            } else {
                Text(entry.errorMessage ?? "No data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                Text(entry.date, style: .time)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct IconStat: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value).bold()
                .foregroundStyle(.primary)
        }
    }
}

#Preview(as: .systemSmall) {
    UsageWidget()
} timeline: {
    UsageEntry.placeholder
}

import WidgetKit
import SwiftUI

/// Widget 定义：三种 family 共用一个 widget kind，内部按 family 渲染不同视图
struct UsageWidget: Widget {
    let kind: String = "UsageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UsageProvider()) { entry in
            UsageWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(.windowBackgroundColor).opacity(0.95),
                                 Color(.windowBackgroundColor)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Sub2API Usage")
        .description("View your AI usage at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct UsageWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: UsageEntry

    var body: some View {
        switch family {
        case .systemSmall: SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge: LargeWidgetView(entry: entry)
        default: MediumWidgetView(entry: entry)
        }
    }
}

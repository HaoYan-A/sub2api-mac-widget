import Foundation

/// 数字格式化工具
enum Formatting {

    /// 花费：保留 2 位小数，千分位
    /// 16.48838125 → "16.49"
    /// 15437.70057126 → "15,437.70"
    static func cost(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 短 Token 数：大数转 K/M/B
    /// 283 → "283"
    /// 11282515 → "11.3M"
    /// 15678489910 → "15.7B"
    static func shortNumber(_ value: Int64) -> String {
        let n = Double(value)
        let absN = abs(n)
        switch absN {
        case 1_000_000_000...:
            return String(format: "%.1fB", n / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.1fM", n / 1_000_000)
        case 10_000...:
            return String(format: "%.1fK", n / 1_000)
        case 1_000...:
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            return nf.string(from: NSNumber(value: value)) ?? "\(value)"
        default:
            return "\(value)"
        }
    }

    /// 长 Token 数：带千分位
    /// 11282515 → "11,282,515"
    static func longNumber(_ value: Int64) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 相对时间 "3 分钟前"
    static func relativeTime(_ date: Date, now: Date = Date()) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: now)
    }
}

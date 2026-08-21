import SwiftUI

// MARK: - Palette
//
// Cool sage green, warm cream, soft charcoal, and a single coral accent that is
// reserved for "overdue" so it never loses its meaning by being decorative.

enum RGTheme {
    static let charcoal   = Color(red: 0.161, green: 0.180, blue: 0.176) // 292E2D
    static let cream      = Color(red: 0.973, green: 0.961, blue: 0.933) // F8F5EE
    static let creamDeep  = Color(red: 0.937, green: 0.918, blue: 0.878) // EFEAE0
    static let card       = Color(red: 1.000, green: 0.996, blue: 0.988) // FFFEFC
    static let sage       = Color(red: 0.404, green: 0.545, blue: 0.475) // 678B79
    static let sageDeep   = Color(red: 0.271, green: 0.400, blue: 0.341) // 456657
    static let sageMist   = Color(red: 0.827, green: 0.871, blue: 0.839) // D3DED6
    static let coral      = Color(red: 0.847, green: 0.427, blue: 0.353) // D86D5A
    static let coralMist  = Color(red: 0.976, green: 0.898, blue: 0.878) // F9E5E0
    static let clay       = Color(red: 0.780, green: 0.639, blue: 0.427) // C7A36D
    static let slateBlue  = Color(red: 0.396, green: 0.475, blue: 0.561) // 65798F

    static let ink        = charcoal
    static let inkSoft    = charcoal.opacity(0.62)
    static let inkFaint   = charcoal.opacity(0.34)
    static let inkGhost   = charcoal.opacity(0.16)
    static let hairline   = charcoal.opacity(0.10)
    static let cardEdge   = charcoal.opacity(0.07)

    /// Stable colour chips assigned to methods, in method catalogue order.
    static let chips: [Color] = [
        Color(red: 0.396, green: 0.475, blue: 0.561), // slate blue  - razor
        Color(red: 0.443, green: 0.545, blue: 0.596), // steel       - electric
        Color(red: 0.545, green: 0.451, blue: 0.612), // plum        - epilator
        Color(red: 0.780, green: 0.639, blue: 0.427), // clay        - hot wax
        Color(red: 0.702, green: 0.545, blue: 0.400), // caramel     - sugaring
        Color(red: 0.482, green: 0.596, blue: 0.541), // sea sage    - cream
        Color(red: 0.573, green: 0.545, blue: 0.427), // olive       - threading
        Color(red: 0.678, green: 0.400, blue: 0.404)  // rose brick  - laser
    ]

    static func chip(_ index: Int) -> Color {
        guard !chips.isEmpty else { return sage }
        let i = ((index % chips.count) + chips.count) % chips.count
        return chips[i]
    }

    /// Shading ramp used by the irritation heat grid (low -> high).
    static func heat(_ fraction: Double) -> Color {
        let f = RGMath.clamp(fraction.isFinite ? fraction : 0, 0, 1)
        // sage mist -> clay -> coral
        if f < 0.5 {
            let t = f / 0.5
            return Color(red: 0.827 + (0.925 - 0.827) * t,
                         green: 0.871 + (0.831 - 0.871) * t,
                         blue: 0.839 + (0.722 - 0.839) * t)
        } else {
            let t = (f - 0.5) / 0.5
            return Color(red: 0.925 + (0.847 - 0.925) * t,
                         green: 0.831 + (0.427 - 0.831) * t,
                         blue: 0.722 + (0.353 - 0.722) * t)
        }
    }
}

// MARK: - Typography

enum RGFont {
    static func display(_ size: CGFloat = 26) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func title(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func heading(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    static func mono(_ size: CGFloat = 13) -> Font { .system(size: size, weight: .medium, design: .monospaced) }
    static func label(_ size: CGFloat = 11) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
}

// MARK: - Safe maths (pitfall 13: nothing NaN reaches the UI)

enum RGMath {
    static func safeDivide(_ a: Double, _ b: Double) -> Double? {
        guard b != 0, a.isFinite, b.isFinite else { return nil }
        let r = a / b
        return r.isFinite ? r : nil
    }

    static func ratio(_ part: Int, of total: Int) -> Double? {
        guard total > 0 else { return nil }
        return Double(part) / Double(total)
    }

    static func clamp<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T {
        if lo > hi { return lo }
        return min(max(v, lo), hi)
    }

    static func mean(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0, +)
        guard sum.isFinite else { return nil }
        return sum / Double(values.count)
    }

    /// Population standard deviation. nil for fewer than two samples.
    static func stdDev(_ values: [Double]) -> Double? {
        guard values.count >= 2, let m = mean(values) else { return nil }
        let sq = values.reduce(0.0) { $0 + ($1 - m) * ($1 - m) }
        let v = sq / Double(values.count)
        guard v.isFinite, v >= 0 else { return nil }
        return v.squareRoot()
    }

    /// Coefficient of variation. nil when the mean is zero or the sample is too small.
    static func coefficientOfVariation(_ values: [Double]) -> Double? {
        guard let m = mean(values), m > 0, let sd = stdDev(values) else { return nil }
        return safeDivide(sd, m)
    }

    /// Least-squares slope of y over the index 0..n-1. nil below two points.
    static func slope(_ values: [Double]) -> Double? {
        let n = values.count
        guard n >= 2 else { return nil }
        let xs = (0..<n).map { Double($0) }
        guard let mx = mean(xs), let my = mean(values) else { return nil }
        var num = 0.0
        var den = 0.0
        for i in 0..<n {
            num += (xs[i] - mx) * (values[i] - my)
            den += (xs[i] - mx) * (xs[i] - mx)
        }
        return safeDivide(num, den)
    }
}

// MARK: - Formatting (pitfall 12: every formatter pinned to en_US_POSIX)

enum RGFormat {
    static let posix = Locale(identifier: "en_US_POSIX")
    static let dash = "\u{2014}"

    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = posix
        f.calendar = RGCal.cal
        f.timeZone = TimeZone.current
        f.dateFormat = format
        return f
    }

    // The formatter objects are built once, but their time zone is re-checked on
    // every access. Holding them as plain `static let` froze `TimeZone.current`
    // at first use while `RGCal` kept re-reading it, so a phone that crossed a
    // zone boundary mid-session could print a date one day off the key it came
    // from.
    private static let dayMonthStore     = formatter("d MMM")
    private static let dayMonthYearStore = formatter("d MMM yyyy")
    private static let monthShortStore   = formatter("MMM")
    private static let monthYearStore    = formatter("MMM yyyy")
    private static let weekdayStore      = formatter("EEE")

    private static func tuned(_ f: DateFormatter) -> DateFormatter {
        let tz = TimeZone.current
        if f.timeZone != tz {
            f.timeZone = tz
            f.calendar = RGCal.cal
        }
        return f
    }

    static var dayMonth: DateFormatter     { tuned(dayMonthStore) }
    static var dayMonthYear: DateFormatter { tuned(dayMonthYearStore) }
    static var monthShort: DateFormatter   { tuned(monthShortStore) }
    static var monthYear: DateFormatter    { tuned(monthYearStore) }
    static var weekday: DateFormatter      { tuned(weekdayStore) }

    static func date(_ d: Date) -> String { dayMonthYear.string(from: d) }
    static func shortDate(_ d: Date) -> String { dayMonth.string(from: d) }

    /// One decimal place, never NaN.
    static func oneDecimal(_ v: Double?) -> String {
        guard let v = v, v.isFinite else { return dash }
        return String(format: "%.1f", v)
    }

    static func whole(_ v: Double?) -> String {
        guard let v = v, v.isFinite else { return dash }
        return String(format: "%.0f", v.rounded())
    }

    static func percent(_ fraction: Double?) -> String {
        guard let f = fraction, f.isFinite else { return dash }
        return String(format: "%.0f%%", RGMath.clamp(f, 0, 1) * 100)
    }

    /// Percentages that are genuinely allowed to exceed 100, such as a
    /// coefficient of variation. Clamping those to 100% would contradict the
    /// confidence badge printed beside them, which uses the raw value.
    static func percentUnclamped(_ fraction: Double?) -> String {
        guard let f = fraction, f.isFinite else { return dash }
        return String(format: "%.0f%%", f * 100)
    }

    static func money(_ v: Double?, symbol: String) -> String {
        guard let v = v, v.isFinite else { return dash }
        if v >= 1000 {
            return symbol + String(format: "%.0f", v)
        }
        return symbol + String(format: "%.2f", v)
    }

    static func moneyWhole(_ v: Double?, symbol: String) -> String {
        guard let v = v, v.isFinite else { return dash }
        return symbol + String(format: "%.0f", v.rounded())
    }

    static func days(_ v: Double?) -> String {
        guard let v = v, v.isFinite else { return dash }
        let r = v.rounded()
        if abs(r - 1) < 0.01 { return "1 day" }
        return String(format: "%.0f days", r)
    }

    static func minutes(_ v: Int) -> String {
        if v < 60 { return "\(v) min" }
        let h = v / 60
        let m = v % 60
        if m == 0 { return "\(h) h" }
        return "\(h) h \(m) m"
    }
}

// MARK: - Calendar / day keys (pitfall 16: never compare raw Dates)

enum RGCal {
    private static func build() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = RGFormat.posix
        c.timeZone = TimeZone.current
        return c
    }

    private static var cachedCal: Calendar = RGCal.build()
    private static var cachedZone: TimeZone = TimeZone.current

    /// Built once and reused. As a computed property this allocated a fresh
    /// `Calendar` on every call, and `daysBetween` alone touches it five times,
    /// which ran to thousands of allocations per frame on the Due tab. The cache
    /// is dropped only when the device time zone actually changes, so the day
    /// keys still follow the phone.
    static var cal: Calendar {
        let now = TimeZone.current
        if now != cachedZone {
            cachedZone = now
            cachedCal = build()
        }
        return cachedCal
    }

    static func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }

    /// yyyymmdd integer key.
    static func key(_ d: Date) -> Int {
        let c = cal.dateComponents([.year, .month, .day], from: d)
        let y = c.year ?? 2000
        let m = c.month ?? 1
        let day = c.day ?? 1
        return y * 10000 + m * 100 + day
    }

    static func date(fromKey k: Int) -> Date {
        var c = DateComponents()
        c.year = k / 10000
        c.month = (k / 100) % 100
        c.day = k % 100
        c.hour = 12
        return cal.date(from: c) ?? Date()
    }

    static var todayKey: Int { key(Date()) }

    static func daysBetween(_ a: Int, _ b: Int) -> Int {
        let da = startOfDay(date(fromKey: a))
        let db = startOfDay(date(fromKey: b))
        let comps = cal.dateComponents([.day], from: da, to: db)
        return comps.day ?? 0
    }

    static func addingDays(_ k: Int, _ n: Int) -> Int {
        let d = date(fromKey: k)
        guard let out = cal.date(byAdding: .day, value: n, to: d) else { return k }
        return key(out)
    }

    static func monthKey(_ k: Int) -> Int { k / 100 } // yyyymm

    static func monthLabel(_ ym: Int) -> String {
        var c = DateComponents()
        c.year = ym / 100
        c.month = ym % 100
        c.day = 1
        c.hour = 12
        guard let d = cal.date(from: c) else { return "" }
        return RGFormat.monthShort.string(from: d)
    }

    static func monthYearLabel(_ ym: Int) -> String {
        var c = DateComponents()
        c.year = ym / 100
        c.month = ym % 100
        c.day = 1
        c.hour = 12
        guard let d = cal.date(from: c) else { return "" }
        return RGFormat.monthYear.string(from: d)
    }

    /// The last `count` month keys ending with the month containing `today`.
    static func recentMonthKeys(_ count: Int, endingAt today: Date = Date()) -> [Int] {
        guard count > 0 else { return [] }
        var out: [Int] = []
        let base = cal.startOfDay(for: today)
        for i in stride(from: count - 1, through: 0, by: -1) {
            if let d = cal.date(byAdding: .month, value: -i, to: base) {
                out.append(key(d) / 100)
            }
        }
        return out
    }
}

// MARK: - Haptics

enum RGHaptic {
    static func tap(_ enabled: Bool) {
        guard enabled else { return }
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred()
    }

    static func success(_ enabled: Bool) {
        guard enabled else { return }
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }
}

// MARK: - Screen metrics (iOS 15 safe)

enum RGDevice {
    /// The width a layout may actually use. `UIScreen.main.bounds` is
    /// interface-oriented, so in landscape on a notched phone it reports 844 pt
    /// while the safe area is 47 pt narrower on each side. Every width in
    /// `RGLayout` derives from this, so it has to be the usable figure or every
    /// card, canvas and calendar runs off the right edge in landscape.
    static var width: CGFloat {
        let raw = UIScreen.main.bounds.width
        let insets = safeAreaInsets
        return max(raw - insets.left - insets.right, 200)
    }

    static var height: CGFloat { UIScreen.main.bounds.height }

    /// True on the 375 x 667 class of device, where fixed layouts collapse.
    static var isCompact: Bool { UIScreen.main.bounds.height <= 700 }

    /// Horizontal insets of the active window. Zero in portrait on every phone,
    /// so portrait arithmetic is untouched.
    private static var safeAreaInsets: UIEdgeInsets {
        guard Thread.isMainThread else { return .zero }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if let window = windowScene.windows.first(where: { $0.isKeyWindow })
                ?? windowScene.windows.first {
                return window.safeAreaInsets
            }
        }
        return .zero
    }
}

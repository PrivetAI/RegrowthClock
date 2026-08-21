import Foundation

// MARK: - Confidence

enum RGConfidence: Int, Comparable {
    case learning = 0
    case low = 1
    case medium = 2
    case high = 3

    static func < (a: RGConfidence, b: RGConfidence) -> Bool { a.rawValue < b.rawValue }

    var title: String {
        switch self {
        case .learning: return "Learning"
        case .low:      return "Low"
        case .medium:   return "Medium"
        case .high:     return "High"
        }
    }

    var explanation: String {
        switch self {
        case .learning:
            return "Fewer than two measured gaps. The estimate is still the published starting figure for this zone and method, not your own."
        case .low:
            return "Either too few gaps to judge, or your gaps vary widely. Treat the date as a rough marker."
        case .medium:
            return "Enough gaps to be useful, with moderate spread between them."
        case .high:
            return "Several gaps that agree closely with each other. This is the app predicting from your own pattern."
        }
    }
}

// MARK: - Prediction

struct RGPrediction {
    let zoneID: String
    let methodID: String
    /// Number of measured gaps between consecutive sessions (sessions - 1).
    let gapCount: Int
    let sessionCount: Int
    /// nil when there is no session at all.
    let lastDayKey: Int?
    /// Predicted interval in days. Always finite when non-nil.
    let interval: Double?
    /// The authored cold-start figure, before any of the user's own data.
    let prior: Double
    let confidence: RGConfidence
    /// Coefficient of variation across the gaps, nil below two gaps.
    let cv: Double?
    /// Least-squares slope of the gap series, days per session. nil below five gaps.
    let driftPerSession: Double?
    let isCourseBased: Bool

    /// yyyymmdd of the next due date, nil when nothing has been logged.
    var dueDayKey: Int? {
        guard let last = lastDayKey, let iv = interval, iv.isFinite, iv > 0 else { return nil }
        return RGCal.addingDays(last, Int(iv.rounded()))
    }

    /// Negative = overdue by that many days. nil when nothing has been logged.
    func daysUntilDue(from todayKey: Int) -> Int? {
        guard let due = dueDayKey else { return nil }
        return RGCal.daysBetween(todayKey, due)
    }

    var hasOwnData: Bool { gapCount >= 1 }
}

// MARK: - Bucketing for the Due tab

enum RGDueBucket: Int, CaseIterable, Identifiable {
    case overdue = 0
    case today = 1
    case thisWeek = 2
    case later = 3
    case unscheduled = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .overdue:     return "Overdue"
        case .today:       return "Due today"
        case .thisWeek:    return "This week"
        case .later:       return "Later"
        case .unscheduled: return "No date yet"
        }
    }

    var emptyMessage: String {
        switch self {
        case .overdue:
            return "Nothing has slipped past its predicted date. This is the state the app is trying to keep you in."
        case .today:
            return "Nothing lands on today."
        case .thisWeek:
            return "Nothing is predicted in the next seven days."
        case .later:
            return "Nothing further out yet. Predictions appear here once a pair has a date."
        case .unscheduled:
            return "Every tracked pair has a predicted date."
        }
    }

    static func bucket(for days: Int?) -> RGDueBucket {
        guard let d = days else { return .unscheduled }
        if d < 0 { return .overdue }
        if d == 0 { return .today }
        if d <= 7 { return .thisWeek }
        return .later
    }
}

// MARK: - Laser / IPL course state

struct RGCourseState {
    let zoneID: String
    let sessionsDone: Int
    let plannedSessions: Int
    let lastDayKey: Int?
    /// Weeks until the next appointment, taken from the zone group and how far
    /// through the course you are.
    let nextGapWeeks: Int
    let nextDayKey: Int?
    let complete: Bool

    var progress: Double {
        guard plannedSessions > 0 else { return 0 }
        return RGMath.clamp(Double(sessionsDone) / Double(plannedSessions), 0, 1)
    }

    func daysUntilNext(from todayKey: Int) -> Int? {
        guard let n = nextDayKey else { return nil }
        return RGCal.daysBetween(todayKey, n)
    }
}

// MARK: - The engine

/// Per-(zone, method) interval learner.
///
/// The prediction is an exponentially weighted moving average of the measured
/// gaps, blended with an authored cold-start prior whose weight decays to zero
/// as the sample count reaches `priorFadeAt`. Recent gaps dominate, so a change
/// of habit is picked up within a few sessions instead of being averaged away.
enum RGIntervalEngine {

    /// EWMA decay. The most recent gap carries weight 1, the one before it 0.6,
    /// then 0.36, and so on.
    static let decay: Double = 0.6
    /// Starting weight of the authored prior, in units of "one measured gap".
    static let priorWeightStart: Double = 3.0
    /// Sample count at which the prior no longer contributes at all.
    static let priorFadeAt: Double = 6.0
    /// Gaps outside this range are treated as data-entry noise, not cadence.
    static let minPlausibleGap: Double = 1
    static let maxPlausibleGap: Double = 400

    // MARK: Cold-start prior

    static func prior(zoneID: String, methodID: String) -> Double {
        let zonePrior = RGZoneCatalog.zone(zoneID)?.priorDays ?? 5
        let mult = RGMethodCatalog.method(methodID)?.intervalMultiplier ?? 1
        let value = zonePrior * mult
        guard value.isFinite, value > 0 else { return 7 }
        return RGMath.clamp(value, 1, 365)
    }

    // MARK: Gaps

    /// Day gaps between consecutive sessions, oldest first. Same-day duplicates
    /// produce a zero gap and are dropped so they cannot collapse the average.
    static func gaps(from dayKeys: [Int]) -> [Double] {
        let sorted = dayKeys.sorted()
        guard sorted.count >= 2 else { return [] }
        var out: [Double] = []
        for i in 1..<sorted.count {
            let d = Double(RGCal.daysBetween(sorted[i - 1], sorted[i]))
            guard d.isFinite, d >= minPlausibleGap, d <= maxPlausibleGap else { continue }
            out.append(d)
        }
        return out
    }

    // MARK: The blend

    /// `predicted = (priorWeight * prior + sum(w_i * gap_i)) / (priorWeight + sum(w_i))`
    /// with `w_i = decay^(n-1-i)` and `priorWeight` falling from 3 to 0 as n reaches 6.
    static func blend(prior p: Double, gaps g: [Double]) -> Double? {
        guard p.isFinite, p > 0 else { return nil }
        let n = g.count
        if n == 0 { return p }

        var weightedSum = 0.0
        var weightTotal = 0.0
        for (i, gap) in g.enumerated() {
            let exponent = Double(n - 1 - i)
            let w = pow(decay, exponent)
            guard w.isFinite, w > 0 else { continue }
            weightedSum += w * gap
            weightTotal += w
        }

        let fade = RGMath.clamp(1.0 - Double(n) / priorFadeAt, 0, 1)
        let priorWeight = priorWeightStart * fade

        let numerator = priorWeight * p + weightedSum
        let denominator = priorWeight + weightTotal
        guard let result = RGMath.safeDivide(numerator, denominator), result > 0 else { return nil }
        return RGMath.clamp(result, 1, 365)
    }

    // MARK: Confidence

    static func confidence(gapCount n: Int, cv: Double?) -> RGConfidence {
        if n < 2 { return .learning }
        if n < 5 { return .low }
        guard let c = cv, c.isFinite else { return .low }
        if c < 0.20 { return .high }
        if c < 0.40 { return .medium }
        return .low
    }

    // MARK: Whole prediction

    static func predict(zoneID: String,
                        methodID: String,
                        dayKeys: [Int]) -> RGPrediction {
        let p = prior(zoneID: zoneID, methodID: methodID)
        let sorted = dayKeys.sorted()
        let g = gaps(from: sorted)
        let cv = g.count >= 2 ? RGMath.coefficientOfVariation(g) : nil
        let course = RGMethodCatalog.method(methodID)?.isCourseBased ?? false

        var interval: Double? = nil
        if course {
            // Laser / IPL does not learn a cadence: it follows a course schedule.
            interval = nil
        } else if sorted.isEmpty {
            interval = nil
        } else {
            interval = blend(prior: p, gaps: g)
        }

        var drift: Double? = nil
        if g.count >= 5 {
            drift = RGMath.slope(g)
        }

        return RGPrediction(zoneID: zoneID,
                            methodID: methodID,
                            gapCount: g.count,
                            sessionCount: sorted.count,
                            lastDayKey: sorted.last,
                            interval: interval,
                            prior: p,
                            confidence: course ? .learning : confidence(gapCount: g.count, cv: cv),
                            cv: cv,
                            driftPerSession: drift,
                            isCourseBased: course)
    }

    // MARK: Laser course schedule

    /// Weeks between session `index` (1-based, the session already done) and the
    /// next one. Gaps widen as the course progresses, and the base cadence
    /// depends on the region.
    static func laserGapWeeks(zoneID: String, afterSession index: Int) -> Int {
        let group = RGZoneCatalog.zone(zoneID)?.group ?? .upperBody
        let base = group.laserBaseWeeks
        // Early sessions run at the base cadence; later ones stretch by two weeks,
        // then by four, which is how published course schedules are usually laid out.
        if index <= 3 { return base }
        if index <= 6 { return base + 2 }
        return base + 4
    }

    static func courseState(zoneID: String, dayKeys: [Int]) -> RGCourseState {
        let sorted = dayKeys.sorted()
        let planned = RGZoneCatalog.zone(zoneID)?.laserCourseSessions ?? 8
        let done = sorted.count
        let complete = done >= planned
        let weeks = laserGapWeeks(zoneID: zoneID, afterSession: max(1, done))
        var next: Int? = nil
        if let last = sorted.last, !complete {
            next = RGCal.addingDays(last, weeks * 7)
        }
        return RGCourseState(zoneID: zoneID,
                             sessionsDone: done,
                             plannedSessions: planned,
                             lastDayKey: sorted.last,
                             nextGapWeeks: weeks,
                             nextDayKey: next,
                             complete: complete)
    }

    // MARK: Drift wording

    static func driftDescription(_ slope: Double?, gapCount: Int) -> String {
        guard gapCount >= 5 else {
            return "Not enough gaps yet. Cadence drift needs at least five measured gaps before it says anything."
        }
        guard let s = slope, s.isFinite else {
            return "The gap series is too flat or too irregular to fit a trend."
        }
        let perTen = s * 10
        if abs(perTen) < 1 {
            return "Steady. Your gaps are not trending in either direction."
        }
        if perTen > 0 {
            return String(format: "Lengthening by about %.1f days over ten sessions.", perTen)
        }
        return String(format: "Shortening by about %.1f days over ten sessions.", abs(perTen))
    }
}

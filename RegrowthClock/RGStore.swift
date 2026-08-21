import SwiftUI
import Combine

// MARK: - Row models built by the store

struct RGDueRow: Identifiable {
    let zoneID: String
    let methodID: String
    let prediction: RGPrediction
    let course: RGCourseState?
    let daysUntil: Int?
    let bucket: RGDueBucket

    var id: String { zoneID + "|" + methodID }

    var zoneName: String { RGZoneCatalog.name(zoneID) }
    var methodName: String { RGMethodCatalog.shortName(methodID) }
}

struct RGPairStat: Identifiable {
    let zoneID: String
    let methodID: String
    let sessionCount: Int
    let irritationCount: Int
    let totalCost: Double
    let costSamples: Int
    let totalMinutes: Int
    let minuteSamples: Int
    let prediction: RGPrediction

    var id: String { zoneID + "|" + methodID }

    var irritationRate: Double? { RGMath.ratio(irritationCount, of: sessionCount) }
    var averageCost: Double? { RGMath.safeDivide(totalCost, Double(max(costSamples, 0))) }
    var averageMinutes: Double? { RGMath.safeDivide(Double(totalMinutes), Double(max(minuteSamples, 0))) }
}

// MARK: - Persistence payload

private struct RGArchive: Codable {
    var sessions: [RGSession]
    var products: [RGProduct]
    var settings: RGSettings

    init(sessions: [RGSession], products: [RGProduct], settings: RGSettings) {
        self.sessions = sessions
        self.products = products
        self.settings = settings
    }

    enum CodingKeys: String, CodingKey { case sessions, products, settings }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sessions = ((try? c.decodeIfPresent([RGSession].self, forKey: .sessions)) ?? nil) ?? []
        products = ((try? c.decodeIfPresent([RGProduct].self, forKey: .products)) ?? nil) ?? []
        settings = ((try? c.decodeIfPresent(RGSettings.self, forKey: .settings)) ?? nil) ?? RGSettings()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(sessions, forKey: .sessions)
        try c.encode(products, forKey: .products)
        try c.encode(settings, forKey: .settings)
    }
}

// MARK: - Store

final class RGStore: ObservableObject {

    @Published private(set) var sessions: [RGSession] = [] {
        didSet { sessionStamp &+= 1 }
    }
    @Published private(set) var products: [RGProduct] = []
    @Published var settings: RGSettings = RGSettings() {
        didSet { if settings != oldValue { persist() } }
    }

    private let fileName = "regrowth-clock-archive.json"
    private let defaultsKey = "regrowthClockArchiveV1"
    private var loading = true

    /// Bumped by every write to `sessions`, which is the only input `dueRows`
    /// has. Together with the day key it makes the cache below impossible to
    /// leave stale.
    private var sessionStamp: Int = 0
    private var cachedDueRows: (stamp: Int, todayKey: Int, rows: [RGDueRow])? = nil

    init() {
        load()
        loading = false
    }

    // MARK: Storage location

    private var archiveURL: URL? {
        let fm = FileManager.default
        guard let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let dir = base.appendingPathComponent("RegrowthClock", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    private func load() {
        // The file first, the UserDefaults mirror second. A file that exists but
        // fails to decode used to end the load right there, skipping the mirror
        // that exists precisely for that case, and the next persist() then wrote
        // over both copies.
        var candidates: [Data] = []
        if let url = archiveURL, let d = try? Data(contentsOf: url) {
            candidates.append(d)
        }
        if let d = UserDefaults.standard.data(forKey: defaultsKey) {
            candidates.append(d)
        }
        let decoder = JSONDecoder()
        for payload in candidates {
            guard let archive = try? decoder.decode(RGArchive.self, from: payload) else { continue }
            sessions = archive.sessions.sorted { $0.dayKey > $1.dayKey }
            products = archive.products
            settings = archive.settings
            return
        }
    }

    private func persist() {
        guard !loading else { return }
        let archive = RGArchive(sessions: sessions, products: products, settings: settings)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(archive) else { return }
        if let url = archiveURL {
            try? data.write(to: url, options: .atomic)
        }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    // MARK: Mutations

    func addSession(_ s: RGSession) {
        sessions.append(s)
        sessions.sort { $0.dayKey > $1.dayKey }
        persist()
    }

    func quickLog(zoneID: String, methodID: String) {
        let s = RGSession(zoneID: zoneID, methodID: methodID, dayKey: RGCal.todayKey)
        addSession(s)
    }

    func updateSession(_ s: RGSession) {
        guard let idx = sessions.firstIndex(where: { $0.id == s.id }) else { return }
        sessions[idx] = s
        sessions.sort { $0.dayKey > $1.dayKey }
        persist()
    }

    func deleteSession(id: UUID) {
        sessions.removeAll { $0.id == id }
        persist()
    }

    func session(id: UUID) -> RGSession? {
        sessions.first { $0.id == id }
    }

    func addProduct(_ p: RGProduct) {
        products.append(p)
        persist()
    }

    func updateProduct(_ p: RGProduct) {
        guard let idx = products.firstIndex(where: { $0.id == p.id }) else { return }
        products[idx] = p
        persist()
    }

    func replaceProduct(id: UUID) {
        guard let idx = products.firstIndex(where: { $0.id == id }) else { return }
        var p = products[idx]
        p.startDayKey = RGCal.todayKey
        p.carriedUses = 0
        p.replacements += 1
        p.retired = false
        products[idx] = p
        persist()
    }

    func deleteProduct(id: UUID) {
        products.removeAll { $0.id == id }
        persist()
    }

    func resetEverything() {
        sessions = []
        products = []
        var fresh = RGSettings()
        fresh.onboardingComplete = true
        settings = fresh   // didSet persists
        persist()
    }

    // MARK: Queries

    func sessions(zoneID: String) -> [RGSession] {
        sessions.filter { $0.zoneID == zoneID }
    }

    func sessions(zoneID: String, methodID: String) -> [RGSession] {
        sessions.filter { $0.zoneID == zoneID && $0.methodID == methodID }
    }

    func sessions(methodID: String) -> [RGSession] {
        sessions.filter { $0.methodID == methodID }
    }

    /// Every (zone, method) pair that has at least one logged session.
    var trackedPairs: [(zoneID: String, methodID: String)] {
        var seen = Set<String>()
        var out: [(String, String)] = []
        for s in sessions {
            let key = s.zoneID + "|" + s.methodID
            if seen.contains(key) { continue }
            guard RGZoneCatalog.zone(s.zoneID) != nil, RGMethodCatalog.method(s.methodID) != nil else { continue }
            seen.insert(key)
            out.append((s.zoneID, s.methodID))
        }
        return out
    }

    func methodsUsed(inZone zoneID: String) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for s in sessions where s.zoneID == zoneID {
            if seen.contains(s.methodID) { continue }
            guard RGMethodCatalog.method(s.methodID) != nil else { continue }
            seen.insert(s.methodID)
            out.append(s.methodID)
        }
        // Keep catalogue order so the UI is stable.
        return RGMethodCatalog.all.map { $0.id }.filter { out.contains($0) }
    }

    var zonesWithData: [String] {
        var seen = Set<String>()
        for s in sessions { seen.insert(s.zoneID) }
        return RGZoneCatalog.all.map { $0.id }.filter { seen.contains($0) }
    }

    func sessionCount(zoneID: String) -> Int {
        sessions.reduce(0) { $0 + ($1.zoneID == zoneID ? 1 : 0) }
    }

    // MARK: Predictions

    func prediction(zoneID: String, methodID: String) -> RGPrediction {
        let keys = sessions(zoneID: zoneID, methodID: methodID).map { $0.dayKey }
        return RGIntervalEngine.predict(zoneID: zoneID, methodID: methodID, dayKeys: keys)
    }

    func courseState(zoneID: String) -> RGCourseState {
        let keys = sessions(zoneID: zoneID, methodID: "laser").map { $0.dayKey }
        return RGIntervalEngine.courseState(zoneID: zoneID, dayKeys: keys)
    }

    /// Every tracked pair, most overdue first.
    ///
    /// Cached, because the Due tab badge in the root view re-reads this on every
    /// store publish and the Zones grid reads it once per body pass.
    func dueRows(todayKey: Int = RGCal.todayKey) -> [RGDueRow] {
        if let cached = cachedDueRows, cached.stamp == sessionStamp, cached.todayKey == todayKey {
            return cached.rows
        }
        var rows: [RGDueRow] = []
        for pair in trackedPairs {
            let pred = prediction(zoneID: pair.zoneID, methodID: pair.methodID)
            var course: RGCourseState? = nil
            var days: Int? = nil
            if pred.isCourseBased {
                let cs = courseState(zoneID: pair.zoneID)
                course = cs
                days = cs.complete ? nil : cs.daysUntilNext(from: todayKey)
            } else {
                days = pred.daysUntilDue(from: todayKey)
            }
            rows.append(RGDueRow(zoneID: pair.zoneID,
                                 methodID: pair.methodID,
                                 prediction: pred,
                                 course: course,
                                 daysUntil: days,
                                 bucket: RGDueBucket.bucket(for: days)))
        }
        rows.sort { a, b in
            let da = a.daysUntil ?? Int.max
            let db = b.daysUntil ?? Int.max
            if da != db { return da < db }
            return a.zoneName < b.zoneName
        }
        cachedDueRows = (sessionStamp, todayKey, rows)
        return rows
    }

    var overdueCount: Int {
        dueRows().reduce(0) { $0 + ($1.bucket == .overdue ? 1 : 0) }
    }

    // MARK: Stats

    func cost(of s: RGSession) -> Double {
        if let c = s.cost, c.isFinite, c >= 0 { return c }
        return RGMethodCatalog.method(s.methodID)?.typicalCost ?? 0
    }

    /// True when the figure came from the user rather than the authored default.
    func costIsUserEntered(_ s: RGSession) -> Bool {
        if let c = s.cost, c.isFinite, c >= 0 { return true }
        return false
    }

    func pairStat(zoneID: String, methodID: String) -> RGPairStat {
        let list = sessions(zoneID: zoneID, methodID: methodID)
        var irritation = 0
        var totalCost = 0.0
        var costSamples = 0
        var totalMinutes = 0
        var minuteSamples = 0
        for s in list {
            if s.reaction.countsAsIrritation { irritation += 1 }
            if let c = s.cost, c.isFinite, c >= 0 {
                totalCost += c
                costSamples += 1
            }
            if let m = s.minutes, m > 0 {
                totalMinutes += m
                minuteSamples += 1
            }
        }
        return RGPairStat(zoneID: zoneID,
                          methodID: methodID,
                          sessionCount: list.count,
                          irritationCount: irritation,
                          totalCost: totalCost,
                          costSamples: costSamples,
                          totalMinutes: totalMinutes,
                          minuteSamples: minuteSamples,
                          prediction: prediction(zoneID: zoneID, methodID: methodID))
    }

    /// Total spend per month key (yyyymm) across the given month keys.
    func spendByMonth(_ monthKeys: [Int]) -> [Int: Double] {
        var out: [Int: Double] = [:]
        for k in monthKeys { out[k] = 0 }
        for s in sessions {
            let mk = RGCal.monthKey(s.dayKey)
            guard out[mk] != nil else { continue }
            out[mk] = (out[mk] ?? 0) + cost(of: s)
        }
        return out
    }

    func spendByMethod() -> [(methodID: String, total: Double, count: Int)] {
        var totals: [String: Double] = [:]
        var counts: [String: Int] = [:]
        for s in sessions {
            totals[s.methodID] = (totals[s.methodID] ?? 0) + cost(of: s)
            counts[s.methodID] = (counts[s.methodID] ?? 0) + 1
        }
        return RGMethodCatalog.all.compactMap { m in
            guard let t = totals[m.id], let c = counts[m.id], c > 0 else { return nil }
            return (m.id, t, c)
        }.sorted { $0.total > $1.total }
    }

    func spendByZone() -> [(zoneID: String, total: Double, count: Int)] {
        var totals: [String: Double] = [:]
        var counts: [String: Int] = [:]
        for s in sessions {
            totals[s.zoneID] = (totals[s.zoneID] ?? 0) + cost(of: s)
            counts[s.zoneID] = (counts[s.zoneID] ?? 0) + 1
        }
        return RGZoneCatalog.all.compactMap { z in
            guard let t = totals[z.id], let c = counts[z.id], c > 0 else { return nil }
            return (z.id, t, c)
        }.sorted { $0.total > $1.total }
    }

    var totalSpend: Double {
        sessions.reduce(0.0) { $0 + cost(of: $1) }
    }

    var totalMinutes: Int {
        sessions.reduce(0) { $0 + ($1.minutes ?? 0) }
    }

    var minuteSampleCount: Int {
        sessions.reduce(0) { $0 + (($1.minutes ?? 0) > 0 ? 1 : 0) }
    }

    func averageMinutes(methodID: String) -> Double? {
        var total = 0
        var n = 0
        for s in sessions where s.methodID == methodID {
            if let m = s.minutes, m > 0 { total += m; n += 1 }
        }
        return RGMath.safeDivide(Double(total), Double(n))
    }

    func irritationRate(zoneID: String, methodID: String) -> Double? {
        let list = sessions(zoneID: zoneID, methodID: methodID)
        guard !list.isEmpty else { return nil }
        let irr = list.reduce(0) { $0 + ($1.reaction.countsAsIrritation ? 1 : 0) }
        return RGMath.ratio(irr, of: list.count)
    }

    func reactionBreakdown() -> [(RGReaction, Int)] {
        var counts: [RGReaction: Int] = [:]
        for s in sessions { counts[s.reaction] = (counts[s.reaction] ?? 0) + 1 }
        return RGReaction.allCases.compactMap { r in
            guard let c = counts[r], c > 0 else { return nil }
            return (r, c)
        }
    }

    var overallIrritationRate: Double? {
        guard !sessions.isEmpty else { return nil }
        let irr = sessions.reduce(0) { $0 + ($1.reaction.countsAsIrritation ? 1 : 0) }
        return RGMath.ratio(irr, of: sessions.count)
    }

    // MARK: Twelve-month projection

    /// Annual cost of keeping one zone on one method at the learned (or prior)
    /// cadence, using the user's own average session cost where they have one.
    func annualProjection(zoneID: String, methodID: String) -> (cost: Double, sessions: Double, usesOwnCost: Bool)? {
        guard let method = RGMethodCatalog.method(methodID) else { return nil }
        if method.isCourseBased {
            let planned = Double(RGZoneCatalog.zone(zoneID)?.laserCourseSessions ?? 8)
            let stat = pairStat(zoneID: zoneID, methodID: methodID)
            let per = stat.averageCost ?? method.typicalCost
            return (per * planned, planned, stat.averageCost != nil)
        }
        let pred = prediction(zoneID: zoneID, methodID: methodID)
        let interval = pred.interval ?? pred.prior
        guard interval.isFinite, interval > 0 else { return nil }
        guard let count = RGMath.safeDivide(365.0, interval) else { return nil }
        let stat = pairStat(zoneID: zoneID, methodID: methodID)
        let per = stat.averageCost ?? method.typicalCost
        let total = per * count
        guard total.isFinite else { return nil }
        return (total, count, stat.averageCost != nil)
    }

    // MARK: Products

    func productStatus(_ p: RGProduct) -> RGProductStatus {
        let life = p.customLife ?? RGMethodCatalog.method(p.methodID)?.consumableLife ?? 0
        var uses = p.carriedUses
        for s in sessions where s.methodID == p.methodID && s.dayKey >= p.startDayKey {
            uses += 1
        }
        let days = max(0, RGCal.daysBetween(p.startDayKey, RGCal.todayKey))
        return RGProductStatus(product: p, uses: uses, life: life, daysInService: days)
    }

    var productsNeedingReplacement: Int {
        products.filter { !$0.retired && productStatus($0).isDue }.count
    }

    // MARK: Defaults

    func defaultMethod(for zoneID: String) -> String {
        if let m = settings.defaultMethodByZone[zoneID], RGMethodCatalog.method(m) != nil { return m }
        // Otherwise the most recently used method in that zone, else the razor.
        if let recent = sessions.first(where: { $0.zoneID == zoneID })?.methodID,
           RGMethodCatalog.method(recent) != nil {
            return recent
        }
        return RGMethodCatalog.defaultMethodID
    }

    func setDefaultMethod(_ methodID: String?, for zoneID: String) {
        var s = settings
        if let m = methodID {
            s.defaultMethodByZone[zoneID] = m
        } else {
            s.defaultMethodByZone.removeValue(forKey: zoneID)
        }
        settings = s
    }

    // MARK: Streak-ish summary numbers for the Due header

    var sessionsThisMonth: Int {
        let mk = RGCal.monthKey(RGCal.todayKey)
        return sessions.reduce(0) { $0 + (RGCal.monthKey($1.dayKey) == mk ? 1 : 0) }
    }

    var daysSinceLastSession: Int? {
        guard let last = sessions.map({ $0.dayKey }).max() else { return nil }
        return RGCal.daysBetween(last, RGCal.todayKey)
    }

    /// Zone x method irritation grid for the Insights heat map.
    func irritationGrid() -> [(zoneID: String, cells: [(methodID: String, rate: Double?, n: Int)])] {
        let zones = zonesWithData
        let methods = RGMethodCatalog.all.map { $0.id }
        return zones.map { z in
            let cells = methods.map { m -> (String, Double?, Int) in
                let list = sessions(zoneID: z, methodID: m)
                guard !list.isEmpty else { return (m, nil, 0) }
                let irr = list.reduce(0) { $0 + ($1.reaction.countsAsIrritation ? 1 : 0) }
                return (m, RGMath.ratio(irr, of: list.count), list.count)
            }
            return (z, cells)
        }
    }
}

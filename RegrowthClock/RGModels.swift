import SwiftUI

// MARK: - Zone

enum RGZoneGroup: String, Codable, CaseIterable {
    case face
    case upperBody
    case lowerBody
    case intimate

    var title: String {
        switch self {
        case .face:      return "Face and neck"
        case .upperBody: return "Arms and torso"
        case .lowerBody: return "Legs, hands and feet"
        case .intimate:  return "Underarms and bikini"
        }
    }

    /// Laser / IPL courses run on a different cadence per body region.
    var laserBaseWeeks: Int {
        switch self {
        case .face:      return 4
        case .intimate:  return 6
        case .upperBody: return 6
        case .lowerBody: return 8
        }
    }
}

struct RGZone: Identifiable {
    let id: String
    let name: String
    let group: RGZoneGroup
    /// Cold-start prior in days, expressed for a cartridge razor. Other methods scale it.
    let priorDays: Double
    /// Short human hint shown before the learner has data.
    let regrowthHint: String
    /// Authored care note, 2-4 sentences.
    let careNote: String
    /// Index into the glyph set drawn in RGZoneGlyph.
    let glyph: Int
    /// Typical published length of a laser / IPL course for this region.
    let laserCourseSessions: Int
    /// Care card ids that are especially relevant here.
    let cardIDs: [String]
}

// MARK: - Method

struct RGMethod: Identifiable {
    let id: String
    let name: String
    let shortName: String
    /// Multiplies the zone prior. A razor is 1.0 by definition.
    let intervalMultiplier: Double
    /// Authored default cost per session, used when the user logs no cost.
    let typicalCost: Double
    /// Authored default minutes per session, used only as a hint in the log sheet.
    let typicalMinutes: Int
    let irritationProfile: String
    /// 3-5 sentence technique note.
    let techniqueNote: String
    /// Consumable that wears out with this method, if any.
    let consumableName: String?
    /// Recommended number of sessions before replacing that consumable.
    let consumableLife: Int?
    let glyph: Int
    let chipIndex: Int
    /// Laser / IPL bypasses the interval learner and follows a course schedule.
    var isCourseBased: Bool { id == "laser" }
}

// MARK: - Skin reaction

enum RGReaction: String, Codable, CaseIterable, Identifiable {
    case none
    case redness
    case razorBurn
    case ingrown
    case bumps
    case itching
    case cuts
    case dryness

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:      return "None"
        case .redness:   return "Redness"
        case .razorBurn: return "Razor burn"
        case .ingrown:   return "Ingrown hairs"
        case .bumps:     return "Bumps"
        case .itching:   return "Itching"
        case .cuts:      return "Cuts or nicks"
        case .dryness:   return "Dryness"
        }
    }

    var blurb: String {
        switch self {
        case .none:      return "Skin looked and felt normal afterwards."
        case .redness:   return "Temporary flushing that settled on its own."
        case .razorBurn: return "Stinging, raw-feeling patches after a blade pass."
        case .ingrown:   return "Hairs curling back into the skin instead of out of it."
        case .bumps:     return "Small raised spots around the follicles."
        case .itching:   return "Persistent itch during regrowth or right after."
        case .cuts:      return "Nicks, weeping points or broken skin."
        case .dryness:   return "Tight, flaky skin after the session."
        }
    }

    /// Counts toward the irritation rate. "None" obviously does not.
    var countsAsIrritation: Bool { self != .none }

    var accent: Color {
        switch self {
        case .none:      return RGTheme.sage
        case .redness:   return RGTheme.clay
        case .razorBurn: return RGTheme.coral
        case .ingrown:   return RGTheme.coral
        case .bumps:     return RGTheme.coral
        case .itching:   return RGTheme.clay
        case .cuts:      return RGTheme.coral
        case .dryness:   return RGTheme.clay
        }
    }
}

// MARK: - Session (pitfall 4: every field decoded with decodeIfPresent)

struct RGSession: Identifiable, Codable, Equatable {
    var id: UUID
    var zoneID: String
    var methodID: String
    /// yyyymmdd (pitfall 16)
    var dayKey: Int
    var minutes: Int?
    var cost: Double?
    var reaction: RGReaction
    var note: String

    init(id: UUID = UUID(),
         zoneID: String,
         methodID: String,
         dayKey: Int,
         minutes: Int? = nil,
         cost: Double? = nil,
         reaction: RGReaction = .none,
         note: String = "") {
        self.id = id
        self.zoneID = zoneID
        self.methodID = methodID
        self.dayKey = dayKey
        self.minutes = minutes
        self.cost = cost
        self.reaction = reaction
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case id, zoneID, methodID, dayKey, minutes, cost, reaction, note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = ((try? c.decodeIfPresent(UUID.self, forKey: .id)) ?? nil) ?? UUID()
        zoneID   = ((try? c.decodeIfPresent(String.self, forKey: .zoneID)) ?? nil) ?? ""
        methodID = ((try? c.decodeIfPresent(String.self, forKey: .methodID)) ?? nil) ?? ""
        dayKey   = ((try? c.decodeIfPresent(Int.self, forKey: .dayKey)) ?? nil) ?? RGCal.todayKey
        minutes  = (try? c.decodeIfPresent(Int.self, forKey: .minutes)) ?? nil
        cost     = (try? c.decodeIfPresent(Double.self, forKey: .cost)) ?? nil
        let raw  = ((try? c.decodeIfPresent(String.self, forKey: .reaction)) ?? nil) ?? RGReaction.none.rawValue
        reaction = RGReaction(rawValue: raw) ?? .none
        note     = ((try? c.decodeIfPresent(String.self, forKey: .note)) ?? nil) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(zoneID, forKey: .zoneID)
        try c.encode(methodID, forKey: .methodID)
        try c.encode(dayKey, forKey: .dayKey)
        try c.encodeIfPresent(minutes, forKey: .minutes)
        try c.encodeIfPresent(cost, forKey: .cost)
        try c.encode(reaction.rawValue, forKey: .reaction)
        try c.encode(note, forKey: .note)
    }

    var date: Date { RGCal.date(fromKey: dayKey) }
}

// MARK: - Consumable / product tracking

struct RGProduct: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var methodID: String
    var startDayKey: Int
    /// Sessions already on the clock before this app started counting.
    var carriedUses: Int
    /// User override of the authored recommended life, when they know their own kit.
    var customLife: Int?
    var replacements: Int
    var retired: Bool

    init(id: UUID = UUID(),
         name: String,
         methodID: String,
         startDayKey: Int,
         carriedUses: Int = 0,
         customLife: Int? = nil,
         replacements: Int = 0,
         retired: Bool = false) {
        self.id = id
        self.name = name
        self.methodID = methodID
        self.startDayKey = startDayKey
        self.carriedUses = carriedUses
        self.customLife = customLife
        self.replacements = replacements
        self.retired = retired
    }

    enum CodingKeys: String, CodingKey {
        case id, name, methodID, startDayKey, carriedUses, customLife, replacements, retired
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = ((try? c.decodeIfPresent(UUID.self, forKey: .id)) ?? nil) ?? UUID()
        name         = ((try? c.decodeIfPresent(String.self, forKey: .name)) ?? nil) ?? "Product"
        methodID     = ((try? c.decodeIfPresent(String.self, forKey: .methodID)) ?? nil) ?? "razor"
        startDayKey  = ((try? c.decodeIfPresent(Int.self, forKey: .startDayKey)) ?? nil) ?? RGCal.todayKey
        carriedUses  = ((try? c.decodeIfPresent(Int.self, forKey: .carriedUses)) ?? nil) ?? 0
        customLife   = (try? c.decodeIfPresent(Int.self, forKey: .customLife)) ?? nil
        replacements = ((try? c.decodeIfPresent(Int.self, forKey: .replacements)) ?? nil) ?? 0
        retired      = ((try? c.decodeIfPresent(Bool.self, forKey: .retired)) ?? nil) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(methodID, forKey: .methodID)
        try c.encode(startDayKey, forKey: .startDayKey)
        try c.encode(carriedUses, forKey: .carriedUses)
        try c.encodeIfPresent(customLife, forKey: .customLife)
        try c.encode(replacements, forKey: .replacements)
        try c.encode(retired, forKey: .retired)
    }
}

struct RGProductStatus {
    let product: RGProduct
    let uses: Int
    let life: Int
    let daysInService: Int

    var fraction: Double {
        guard life > 0 else { return 0 }
        return RGMath.clamp(Double(uses) / Double(life), 0, 1.4)
    }

    var isDue: Bool { life > 0 && uses >= life }
    var isNearlyDue: Bool { life > 0 && !isDue && Double(uses) >= Double(life) * 0.75 }

    var statusText: String {
        if life <= 0 { return "No wear guidance" }
        if isDue { return "Replace now" }
        if isNearlyDue { return "Replace soon" }
        return "\(max(0, life - uses)) uses left"
    }

    var accent: Color {
        if isDue { return RGTheme.coral }
        if isNearlyDue { return RGTheme.clay }
        return RGTheme.sage
    }
}

// MARK: - Care card

struct RGCareCard: Identifiable {
    let id: String
    let title: String
    let category: RGCardCategory
    let summary: String
    let body: String
    /// Free-text keywords used by the library search.
    let tags: [String]
}

enum RGCardCategory: String, CaseIterable, Identifiable {
    case prep
    case aftercare
    case ingrown
    case technique
    case hygiene
    case myths
    case whenToAsk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prep:      return "Before a session"
        case .aftercare: return "Aftercare"
        case .ingrown:   return "Ingrown hairs"
        case .technique: return "Technique"
        case .hygiene:   return "Kit and hygiene"
        case .myths:     return "Common myths"
        case .whenToAsk: return "When to ask a professional"
        }
    }

    var accent: Color {
        switch self {
        case .prep:      return RGTheme.sage
        case .aftercare: return RGTheme.sageDeep
        case .ingrown:   return RGTheme.coral
        case .technique: return RGTheme.slateBlue
        case .hygiene:   return RGTheme.clay
        case .myths:     return RGTheme.chip(2)
        case .whenToAsk: return RGTheme.chip(7)
        }
    }
}

// MARK: - Settings

struct RGSettings: Codable, Equatable {
    var currencySymbol: String
    var defaultMethodByZone: [String: String]
    var privacyLockEnabled: Bool
    var hapticsEnabled: Bool
    var onboardingComplete: Bool
    var showConfidenceBadges: Bool

    init() {
        currencySymbol = "$"
        defaultMethodByZone = [:]
        privacyLockEnabled = false
        hapticsEnabled = true
        onboardingComplete = false
        showConfidenceBadges = true
    }

    enum CodingKeys: String, CodingKey {
        case currencySymbol, defaultMethodByZone, privacyLockEnabled, hapticsEnabled
        case onboardingComplete, showConfidenceBadges
    }

    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currencySymbol       = ((try? c.decodeIfPresent(String.self, forKey: .currencySymbol)) ?? nil) ?? "$"
        defaultMethodByZone  = ((try? c.decodeIfPresent([String: String].self, forKey: .defaultMethodByZone)) ?? nil) ?? [:]
        privacyLockEnabled   = ((try? c.decodeIfPresent(Bool.self, forKey: .privacyLockEnabled)) ?? nil) ?? false
        hapticsEnabled       = ((try? c.decodeIfPresent(Bool.self, forKey: .hapticsEnabled)) ?? nil) ?? true
        onboardingComplete   = ((try? c.decodeIfPresent(Bool.self, forKey: .onboardingComplete)) ?? nil) ?? false
        showConfidenceBadges = ((try? c.decodeIfPresent(Bool.self, forKey: .showConfidenceBadges)) ?? nil) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(currencySymbol, forKey: .currencySymbol)
        try c.encode(defaultMethodByZone, forKey: .defaultMethodByZone)
        try c.encode(privacyLockEnabled, forKey: .privacyLockEnabled)
        try c.encode(hapticsEnabled, forKey: .hapticsEnabled)
        try c.encode(onboardingComplete, forKey: .onboardingComplete)
        try c.encode(showConfidenceBadges, forKey: .showConfidenceBadges)
    }
}

// MARK: - Currency options

struct RGCurrencyOption: Identifiable {
    let id: String
    let symbol: String
    let label: String
}

enum RGCurrency {
    static let options: [RGCurrencyOption] = [
        RGCurrencyOption(id: "usd", symbol: "$",  label: "US dollar"),
        RGCurrencyOption(id: "eur", symbol: "\u{20AC}", label: "Euro"),
        RGCurrencyOption(id: "gbp", symbol: "\u{00A3}", label: "Pound sterling"),
        RGCurrencyOption(id: "cad", symbol: "C$", label: "Canadian dollar"),
        RGCurrencyOption(id: "aud", symbol: "A$", label: "Australian dollar"),
        RGCurrencyOption(id: "generic", symbol: "\u{00A4}", label: "Generic currency")
    ]
}

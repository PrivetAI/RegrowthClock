import SwiftUI

struct RGZoneDetailView: View {
    @ObservedObject var store: RGStore
    let zoneID: String

    @State private var logSheet: RGRootSheet? = nil

    private var zone: RGZone? { RGZoneCatalog.zone(zoneID) }

    var body: some View {
        Group {
            if let z = zone {
                content(z)
            } else {
                RGSubScreen(title: "Zone unavailable") {
                    RGEmptyState(title: "That zone is not in the catalog",
                                 message: "It may have come from an older version of the app. Nothing else is affected.",
                                 glyph: .warning)
                }
            }
        }
        .sheet(item: $logSheet) { which in
            switch which {
            case .newSession(let z, let m):
                RGSessionEditor(store: store,
                                presetZoneID: z,
                                presetMethodID: m,
                                editingID: nil) { logSheet = nil }
            case .editSession(let id):
                RGSessionEditor(store: store,
                                presetZoneID: nil,
                                presetMethodID: nil,
                                editingID: id) { logSheet = nil }
            case .newProduct:
                RGProductEditor(store: store, editingID: nil) { logSheet = nil }
            case .editProduct(let id):
                RGProductEditor(store: store, editingID: id) { logSheet = nil }
            }
        }
    }

    private func content(_ z: RGZone) -> some View {
        let used = store.methodsUsed(inZone: z.id)
        let unused = RGMethodCatalog.all.map { $0.id }.filter { !used.contains($0) }
        let zoneSessions = store.sessions(zoneID: z.id)

        return RGSubScreen(title: z.name, subtitle: z.group.title) {

            RGCard {
                HStack(alignment: .top, spacing: 12) {
                    RGZoneGlyph(index: z.glyph, side: 46, color: RGTheme.sageDeep)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Starting figure")
                            .font(RGFont.label(10))
                            .foregroundColor(RGTheme.inkFaint)
                        Text(RGFormat.days(z.priorDays) + " on a razor")
                            .font(RGFont.heading(15))
                            .foregroundColor(RGTheme.ink)
                        Text(z.regrowthHint)
                            .font(RGFont.body(12))
                            .foregroundColor(RGTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            RGPrimaryButton(title: "Log a session here") {
                logSheet = .newSession(zoneID: z.id, methodID: store.defaultMethod(for: z.id))
            }

            RGSectionHeader(text: "Care note")
            RGCard {
                Text(z.careNote)
                    .font(RGFont.body(13.5))
                    .foregroundColor(RGTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }

            RGSectionHeader(text: "Methods used here",
                            detail: used.isEmpty ? nil : "\(used.count)")
            if used.isEmpty {
                RGEmptyState(title: "Nothing logged in this zone",
                             message: "Once two sessions exist for a method here, the app can measure a gap and start replacing the published figure above with your own.",
                             glyph: .clock,
                             actionTitle: "Log the first session") {
                    logSheet = .newSession(zoneID: z.id, methodID: store.defaultMethod(for: z.id))
                }
            } else {
                ForEach(used, id: \.self) { mid in
                    methodComparisonCard(zone: z, methodID: mid)
                }
                if used.count >= 2 {
                    comparisonSummary(zone: z, methods: used)
                }
            }

            if !unused.isEmpty {
                RGSectionHeader(text: "Not tried here yet")
                RGCard {
                    Text("Logging one of these starts a separate clock. The app never mixes two methods into one interval, because they do not behave the same way on the same skin.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    RGWrapChips(items: unused.map { ($0, RGMethodCatalog.shortName($0)) },
                                selected: "",
                                width: RGLayout.cardInnerWidth,
                                color: RGTheme.slateBlue) { id in
                        logSheet = .newSession(zoneID: z.id, methodID: id)
                    }
                }
            }

            RGSectionHeader(text: "Last six months", detail: "\(zoneSessions.count) total")
            RGCard {
                RGZoneTimeline(sessions: zoneSessions, width: RGLayout.cardInnerWidth)
            }

            RGSectionHeader(text: "Default method")
            RGCard {
                Text("Picked automatically when you log from the Due list or from this screen.")
                    .font(RGFont.body(12))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                RGWrapChips(items: RGMethodCatalog.all.map { ($0.id, $0.shortName) },
                            selected: store.settings.defaultMethodByZone[z.id] ?? "",
                            width: RGLayout.cardInnerWidth) { id in
                    if store.settings.defaultMethodByZone[z.id] == id {
                        store.setDefaultMethod(nil, for: z.id)
                    } else {
                        store.setDefaultMethod(id, for: z.id)
                    }
                }
                Text(store.settings.defaultMethodByZone[z.id] == nil
                     ? "No default set. The app uses the method you last logged here."
                     : "Default: " + RGMethodCatalog.name(store.settings.defaultMethodByZone[z.id] ?? ""))
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
            }

            RGSectionHeader(text: "Care cards for this zone")
            ForEach(RGCareLibrary.cards(z.cardIDs)) { card in
                NavigationLink(destination: RGCareCardView(card: card)) {
                    RGCareCardRow(card: card)
                }
                .buttonStyle(PlainButtonStyle())
            }

            RGDisclaimerNote()
        }
    }

    // MARK: Per-method comparison card

    private func methodComparisonCard(zone: RGZone, methodID: String) -> some View {
        let stat = store.pairStat(zoneID: zone.id, methodID: methodID)
        let pred = stat.prediction
        let isCourse = pred.isCourseBased
        let course = isCourse ? store.courseState(zoneID: zone.id) : nil
        let colour = RGMethodCatalog.color(methodID)

        return RGCard(padding: 13, accent: colour) {
            HStack(alignment: .center, spacing: 10) {
                RGMethodGlyph(index: RGMethodCatalog.glyph(methodID), side: 28,
                              color: colour, lineWidth: 1.6)
                VStack(alignment: .leading, spacing: 2) {
                    Text(RGMethodCatalog.name(methodID))
                        .font(RGFont.heading(14.5))
                        .foregroundColor(RGTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("\(stat.sessionCount) session" + (stat.sessionCount == 1 ? "" : "s") + " here")
                        .font(RGFont.label(10))
                        .foregroundColor(RGTheme.inkFaint)
                }
                Spacer(minLength: 4)
                if !isCourse && store.settings.showConfidenceBadges {
                    RGConfidenceBadge(confidence: pred.confidence, compact: true)
                }
            }

            RGDivider()

            if isCourse, let c = course {
                VStack(alignment: .leading, spacing: 8) {
                    RGStatRow(label: "Course progress",
                              value: "\(min(c.sessionsDone, c.plannedSessions)) of \(c.plannedSessions)",
                              accent: RGTheme.ink,
                              detail: RGFormat.percent(c.progress) + " complete")
                    RGCourseLadder(done: c.sessionsDone,
                                   planned: c.plannedSessions,
                                   width: RGLayout.cardInnerWidth - 2)
                    RGStatRow(label: "Next appointment",
                              value: nextCourseText(c),
                              accent: RGTheme.sageDeep,
                              detail: "cadence \(c.nextGapWeeks) weeks for this region")
                    Text("A light-based course does not use the interval learner. Sessions are spaced to catch hair in its growing phase, so the schedule comes from the region rather than from your own gaps.")
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    RGStatRow(label: "Learned interval",
                              value: RGFormat.days(pred.interval),
                              accent: RGTheme.ink,
                              detail: pred.hasOwnData
                                ? "\(pred.gapCount) measured gap" + (pred.gapCount == 1 ? "" : "s")
                                : "published starting figure")
                    RGStatRow(label: "Starting figure",
                              value: RGFormat.days(pred.prior),
                              accent: RGTheme.inkSoft)
                    RGStatRow(label: "Next due",
                              value: dueText(pred),
                              accent: dueColour(pred))
                    RGStatRow(label: "Irritation rate",
                              value: RGFormat.percent(stat.irritationRate),
                              accent: irritationColour(stat.irritationRate),
                              detail: "\(stat.irritationCount) of \(stat.sessionCount)")
                    RGStatRow(label: "Average cost",
                              value: RGFormat.money(stat.averageCost, symbol: store.settings.currencySymbol),
                              accent: RGTheme.ink,
                              detail: stat.costSamples == 0
                                ? "no cost entered"
                                : "\(stat.costSamples) entered")
                    if let avgMin = stat.averageMinutes {
                        RGStatRow(label: "Average duration",
                                  value: RGFormat.oneDecimal(avgMin) + " min",
                                  accent: RGTheme.ink,
                                  detail: "\(stat.minuteSamples) timed")
                    }
                    if store.settings.showConfidenceBadges {
                        Text(pred.confidence.explanation)
                            .font(RGFont.body(11.5))
                            .foregroundColor(RGTheme.inkFaint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            HStack(spacing: 8) {
                Button(action: { logSheet = .newSession(zoneID: zone.id, methodID: methodID) }) {
                    Text("Log with this method")
                        .font(RGFont.label(11))
                        .foregroundColor(colour)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(colour.opacity(0.13)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                Spacer(minLength: 0)
            }
        }
    }

    private func nextCourseText(_ c: RGCourseState) -> String {
        if c.complete { return "course complete" }
        guard let days = c.daysUntilNext(from: RGCal.todayKey) else { return RGFormat.dash }
        if days < 0 { return "\(-days) days over" }
        if days == 0 { return "today" }
        return "in \(days) days"
    }

    private func dueText(_ p: RGPrediction) -> String {
        guard let days = p.daysUntilDue(from: RGCal.todayKey), let due = p.dueDayKey else {
            return RGFormat.dash
        }
        let dateText = RGFormat.shortDate(RGCal.date(fromKey: due))
        if days < 0 { return dateText + " (\(-days) over)" }
        if days == 0 { return dateText + " (today)" }
        return dateText + " (in \(days))"
    }

    private func dueColour(_ p: RGPrediction) -> Color {
        guard let days = p.daysUntilDue(from: RGCal.todayKey) else { return RGTheme.inkFaint }
        if days < 0 { return RGTheme.coral }
        if days == 0 { return RGTheme.clay }
        return RGTheme.sageDeep
    }

    private func irritationColour(_ rate: Double?) -> Color {
        guard let r = rate else { return RGTheme.inkFaint }
        if r >= 0.5 { return RGTheme.coral }
        if r >= 0.25 { return RGTheme.clay }
        return RGTheme.sageDeep
    }

    // MARK: The comparison that earns the app its keep

    private func comparisonSummary(zone: RGZone, methods: [String]) -> some View {
        let stats = methods.map { store.pairStat(zoneID: zone.id, methodID: $0) }
        let rated = stats.filter { $0.sessionCount >= 2 && $0.irritationRate != nil }
        let gentlest = rated.min { ($0.irritationRate ?? 1) < ($1.irritationRate ?? 1) }

        return RGCard(padding: 13, accent: RGTheme.sage) {
            Text("Side by side on this zone")
                .font(RGFont.heading(14.5))
                .foregroundColor(RGTheme.ink)

            RGShareBars(rows: stats.compactMap { s in
                guard let r = s.irritationRate else { return nil }
                return RGShareBars.Row(id: s.methodID,
                                       label: RGMethodCatalog.shortName(s.methodID),
                                       value: r,
                                       detail: "n=\(s.sessionCount)",
                                       color: RGMethodCatalog.color(s.methodID))
            }, width: RGLayout.cardInnerWidth, valueText: { RGFormat.percent($0) })

            Text(RGZoneDetailView.gentlestSentence(gentlest))
                .font(RGFont.body(12))
                .foregroundColor(gentlest == nil ? RGTheme.inkFaint : RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    static func gentlestSentence(_ stat: RGPairStat?) -> String {
        guard let g = stat, let r = g.irritationRate, g.sessionCount >= 2 else {
            return "Two sessions with a method are needed before its irritation rate says anything at all. Keep logging and this paragraph fills itself in."
        }
        var out = "Lowest irritation rate here: "
        out += RGMethodCatalog.shortName(g.methodID)
        out += " at "
        out += RGFormat.percent(r)
        out += " over "
        out += String(g.sessionCount)
        out += " sessions."
        if g.sessionCount < 5 {
            out += " That is still a small sample, so read it as a hint rather than a verdict."
        }
        return out
    }
}

// MARK: - Care card row and detail

struct RGCareCardRow: View {
    let card: RGCareCard

    var body: some View {
        RGCard(padding: 12) {
            HStack(alignment: .top, spacing: 10) {
                Rectangle()
                    .fill(card.category.accent)
                    .frame(width: 3, height: 38)
                    .cornerRadius(2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(card.title)
                        .font(RGFont.heading(13.5))
                        .foregroundColor(RGTheme.ink)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(card.summary)
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                RGIconView(glyph: .chevronRight, side: 14, color: RGTheme.inkFaint)
                    .padding(.top, 6)
            }
            .contentShape(Rectangle())
        }
    }
}

struct RGCareCardView: View {
    let card: RGCareCard

    var body: some View {
        RGSubScreen(title: card.title, subtitle: card.category.title) {
            RGCard(accent: card.category.accent) {
                Text(card.summary)
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            RGCard {
                Text(card.body)
                    .font(RGFont.body(14))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            RGDisclaimerNote(text: "General information, not medical advice. If something on your skin worries you, or does not settle, speak to a pharmacist, doctor or dermatologist.")
        }
    }
}

// MARK: - Method detail

struct RGMethodDetailView: View {
    @ObservedObject var store: RGStore
    let methodID: String

    private var method: RGMethod? { RGMethodCatalog.method(methodID) }

    var body: some View {
        Group {
            if let m = method {
                content(m)
            } else {
                RGSubScreen(title: "Method unavailable") {
                    RGEmptyState(title: "Not in the catalog",
                                 message: "This method is not one of the eight the app tracks.",
                                 glyph: .warning)
                }
            }
        }
    }

    private func content(_ m: RGMethod) -> some View {
        let sessions = store.sessions(methodID: m.id)
        let zones = RGZoneCatalog.all.map { $0.id }.filter { zid in
            !store.sessions(zoneID: zid, methodID: m.id).isEmpty
        }
        let colour = RGTheme.chip(m.chipIndex)

        return RGSubScreen(title: m.name, subtitle: subtitle(m, count: sessions.count)) {
            RGCard(accent: colour) {
                HStack(alignment: .top, spacing: 12) {
                    RGMethodGlyph(index: m.glyph, side: 44, color: colour)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Typical interval multiplier")
                            .font(RGFont.label(10))
                            .foregroundColor(RGTheme.inkFaint)
                        Text(String(format: "%.2fx a razor", m.intervalMultiplier))
                            .font(RGFont.heading(15))
                            .foregroundColor(RGTheme.ink)
                        Text("Used only as a starting figure. As soon as you have measured gaps in a zone, they take over.")
                            .font(RGFont.body(11.5))
                            .foregroundColor(RGTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            RGCard {
                RGStatRow(label: "Typical cost per session",
                          value: RGFormat.money(m.typicalCost, symbol: store.settings.currencySymbol),
                          accent: RGTheme.ink)
                RGStatRow(label: "Typical duration",
                          value: "\(m.typicalMinutes) min",
                          accent: RGTheme.ink)
                if let c = m.consumableName {
                    RGStatRow(label: "Consumable",
                              value: c,
                              accent: RGTheme.ink,
                              detail: m.consumableLife != nil ? "about \(m.consumableLife ?? 0) uses" : nil)
                }
                RGStatRow(label: "Sessions logged",
                          value: "\(sessions.count)",
                          accent: RGTheme.ink,
                          detail: "\(zones.count) zone" + (zones.count == 1 ? "" : "s"))
                if let avg = store.averageMinutes(methodID: m.id) {
                    RGStatRow(label: "Your average duration",
                              value: RGFormat.oneDecimal(avg) + " min",
                              accent: RGTheme.sageDeep)
                }
            }

            RGSectionHeader(text: "Irritation profile")
            RGCard {
                Text(m.irritationProfile)
                    .font(RGFont.body(13.5))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "Technique")
            RGCard {
                Text(m.techniqueNote)
                    .font(RGFont.body(13.5))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !zones.isEmpty {
                RGSectionHeader(text: "Where you use it")
                RGCard {
                    RGShareBars(rows: zones.compactMap { zid in
                        guard let r = store.irritationRate(zoneID: zid, methodID: m.id) else { return nil }
                        let n = store.sessions(zoneID: zid, methodID: m.id).count
                        return RGShareBars.Row(id: zid,
                                               label: RGZoneCatalog.name(zid),
                                               value: r,
                                               detail: "n=\(n)",
                                               color: colour)
                    }, width: RGLayout.cardInnerWidth, valueText: { RGFormat.percent($0) })
                    Text("Irritation rate is reactions divided by sessions. A cell built on one or two sessions is noise, which is why the sample size is printed next to every figure in this app.")
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            RGSectionHeader(text: "Related care cards")
            ForEach(RGCareLibrary.forMethod(m.id)) { card in
                NavigationLink(destination: RGCareCardView(card: card)) {
                    RGCareCardRow(card: card)
                }
                .buttonStyle(PlainButtonStyle())
            }

            RGDisclaimerNote()
        }
    }

    private func subtitle(_ m: RGMethod, count: Int) -> String {
        if count == 0 { return "Not used yet" }
        return "\(count) session" + (count == 1 ? "" : "s") + " logged"
    }
}

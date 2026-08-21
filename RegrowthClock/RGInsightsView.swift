import SwiftUI

struct RGInsightsView: View {
    @ObservedObject var store: RGStore

    @State private var section: Int = 0
    @State private var projectionZone: String? = nil
    @State private var driftPair: String? = nil

    private var currency: String { store.settings.currencySymbol }

    var body: some View {
        RGScreen(title: "Insights",
                 subtitle: subtitleText) {

            sectionPicker

            if store.sessions.isEmpty {
                RGEmptyState(title: "Nothing to analyze yet",
                             message: "Insights are computed entirely from your own log. Cost needs sessions, drift needs at least five measured gaps in one zone and method, and the irritation grid needs you to record what your skin did. None of it is estimated for you.",
                             glyph: .insights)
                RGDisclaimerNote()
            } else {
                switch section {
                case 0: costSection
                case 1: timeSection
                case 2: irritationSection
                default: driftSection
                }
                RGDisclaimerNote()
            }
        }
    }

    private var subtitleText: String {
        let n = store.sessions.count
        if n == 0 { return "Waiting on your first session" }
        return "\(n) session" + (n == 1 ? "" : "s") + " \u{00B7} " + RGFormat.moneyWhole(store.totalSpend, symbol: currency) + " estimated"
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                RGChoiceChip(text: "Cost", selected: section == 0) { section = 0 }
                RGChoiceChip(text: "Time", selected: section == 1) { section = 1 }
                RGChoiceChip(text: "Irritation", selected: section == 2, color: RGTheme.coral) { section = 2 }
                RGChoiceChip(text: "Cadence drift", selected: section == 3, color: RGTheme.slateBlue) { section = 3 }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Cost

    private var costSection: some View {
        let monthKeys = RGCal.recentMonthKeys(12)
        let spend = store.spendByMonth(monthKeys)
        let bars = monthKeys.enumerated().map { idx, mk in
            RGBarChart.Bar(id: mk,
                           label: RGCal.monthLabel(mk),
                           value: spend[mk] ?? 0,
                           highlighted: idx == monthKeys.count - 1)
        }
        let methodRows = store.spendByMethod()
        let zoneRows = store.spendByZone()
        let monthlyValues = monthKeys.compactMap { spend[$0] }
        let avgMonth = RGMath.mean(monthlyValues.filter { $0 > 0 })

        return VStack(alignment: .leading, spacing: 14) {
            RGSectionHeader(text: "Spend by month", detail: "last 12")
            RGCard {
                RGBarChart(bars: bars,
                           width: RGLayout.cardInnerWidth,
                           height: 138,
                           color: RGTheme.sage,
                           valueFormatter: { RGFormat.moneyWhole($0, symbol: currency) })
                RGDivider()
                RGStatRow(label: "This month",
                          value: RGFormat.money(spend[RGCal.monthKey(RGCal.todayKey)], symbol: currency),
                          accent: RGTheme.ink)
                RGStatRow(label: "Average active month",
                          value: RGFormat.money(avgMonth, symbol: currency),
                          accent: RGTheme.ink,
                          detail: "months with any spend")
                RGStatRow(label: "Recorded total",
                          value: RGFormat.money(store.totalSpend, symbol: currency),
                          accent: RGTheme.sageDeep,
                          detail: "\(store.sessions.count) sessions")
                Text("Sessions where you entered no price are valued at the published typical figure for that method, so a month is never silently zero.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "Spend by method")
            RGCard {
                if methodRows.isEmpty {
                    Text("Nothing logged yet.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                } else {
                    RGShareBars(rows: methodRows.map { r in
                        RGShareBars.Row(id: r.methodID,
                                        label: RGMethodCatalog.shortName(r.methodID),
                                        value: r.total,
                                        detail: "n=\(r.count)",
                                        color: RGMethodCatalog.color(r.methodID))
                    }, width: RGLayout.cardInnerWidth,
                       valueText: { RGFormat.moneyWhole($0, symbol: currency) })
                }
            }

            RGSectionHeader(text: "Spend by zone")
            RGCard {
                if zoneRows.isEmpty {
                    Text("Nothing logged yet.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                } else {
                    RGShareBars(rows: zoneRows.map { r in
                        RGShareBars.Row(id: r.zoneID,
                                        label: RGZoneCatalog.name(r.zoneID),
                                        value: r.total,
                                        detail: "n=\(r.count)",
                                        color: RGTheme.sage)
                    }, width: RGLayout.cardInnerWidth,
                       valueText: { RGFormat.moneyWhole($0, symbol: currency) })
                }
            }

            projectionCard
        }
    }

    private var projectionCard: some View {
        let zones = store.zonesWithData
        // A chip selection can outlive its data. If every session in the picked
        // zone is deleted the stored id is no longer in the list, and without
        // this the chips would show nothing selected while the card below still
        // rendered the vanished zone.
        let selected = zones.first(where: { $0 == projectionZone }) ?? zones.first
        return VStack(alignment: .leading, spacing: 12) {
            RGSectionHeader(text: "Twelve-month projection")
            RGCard {
                Text("At your current cadence")
                    .font(RGFont.heading(14.5))
                    .foregroundColor(RGTheme.ink)
                Text("Each method is costed at the interval this app has learned for it in this zone, or at the published starting figure where you have not used it. Prices are your own average where you have entered one, otherwise the published typical figure.")
                    .font(RGFont.body(12))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                if zones.isEmpty || selected == nil {
                    Text("Log a session in any zone to unlock the projection.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                } else {
                    RGWrapChips(items: zones.map { ($0, RGZoneCatalog.name($0)) },
                                selected: selected ?? "",
                                width: RGLayout.cardInnerWidth) { id in
                        projectionZone = id
                    }

                    if let z = selected {
                        let rows = RGMethodCatalog.all.compactMap { m -> RGShareBars.Row? in
                            guard let p = store.annualProjection(zoneID: z, methodID: m.id) else { return nil }
                            let detail = m.isCourseBased
                                ? "\(RGFormat.whole(p.sessions)) session course"
                                : "\(RGFormat.whole(p.sessions))/yr"
                            return RGShareBars.Row(id: m.id,
                                                   label: m.shortName,
                                                   value: p.cost,
                                                   detail: detail,
                                                   color: RGTheme.chip(m.chipIndex))
                        }
                        RGShareBars(rows: rows,
                                    width: RGLayout.cardInnerWidth,
                                    valueText: { RGFormat.moneyWhole($0, symbol: currency) })
                        projectionSentence(zoneID: z)
                    }
                }
            }
        }
    }

    private func projectionSentence(zoneID: String) -> some View {
        let used = store.methodsUsed(inZone: zoneID).filter { $0 != "laser" }
        let mainMethod = used.first
        var text = ""
        if let m = mainMethod,
           let current = store.annualProjection(zoneID: zoneID, methodID: m),
           let laser = store.annualProjection(zoneID: zoneID, methodID: "laser") {
            let zoneName = RGZoneCatalog.name(zoneID).lowercased()
            text = "At your current cadence, keeping " + zoneName + " on "
                + RGMethodCatalog.shortName(m).lowercased() + " costs about "
                + RGFormat.moneyWhole(current.cost, symbol: currency) + " a year over about "
                + RGFormat.whole(current.sessions) + " sessions. A light-based course for the same zone is about "
                + RGFormat.moneyWhole(laser.cost, symbol: currency) + " once, across "
                + RGFormat.whole(laser.sessions) + " appointments, and its outcome depends on your hair and skin rather than on your cadence."
            if !current.usesOwnCost {
                text += " The recurring figure uses the published typical price because you have not entered one for this pair."
            }
        } else {
            text = "Log a couple of sessions in this zone and this paragraph compares your recurring cost against a one-off course."
        }
        return Text(text)
            .font(RGFont.body(12.5))
            .foregroundColor(RGTheme.inkSoft)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Time

    private var timeSection: some View {
        let methodRows = RGMethodCatalog.all.compactMap { m -> RGShareBars.Row? in
            guard let avg = store.averageMinutes(methodID: m.id) else { return nil }
            let n = store.sessions(methodID: m.id).filter { ($0.minutes ?? 0) > 0 }.count
            return RGShareBars.Row(id: m.id,
                                   label: m.shortName,
                                   value: avg,
                                   detail: "n=\(n)",
                                   color: RGTheme.chip(m.chipIndex))
        }
        let timed = store.minuteSampleCount

        return VStack(alignment: .leading, spacing: 14) {
            RGSectionHeader(text: "Time logged")
            RGCard {
                RGStatRow(label: "Total recorded minutes",
                          value: timed > 0 ? RGFormat.minutes(store.totalMinutes) : RGFormat.dash,
                          accent: RGTheme.ink,
                          detail: "\(timed) timed session" + (timed == 1 ? "" : "s"))
                RGStatRow(label: "Average per timed session",
                          value: timed > 0
                            ? RGFormat.oneDecimal(RGMath.safeDivide(Double(store.totalMinutes), Double(timed))) + " min"
                            : RGFormat.dash,
                          accent: RGTheme.ink)
                RGStatRow(label: "Sessions without a duration",
                          value: "\(max(store.sessions.count - timed, 0))",
                          accent: RGTheme.inkSoft,
                          detail: "not counted above")
                Text("Duration is optional, and only the sessions where you entered one are averaged. Nothing here is filled in with a default, because a made-up minute count would make the comparison useless.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "Average minutes by method")
            RGCard {
                if methodRows.isEmpty {
                    Text("No session has a duration recorded yet. Add one in the log editor and this fills in.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    RGShareBars(rows: methodRows,
                                width: RGLayout.cardInnerWidth,
                                valueText: { RGFormat.oneDecimal($0) + " min" })
                }
            }

            RGSectionHeader(text: "Published typical durations")
            RGCard {
                ForEach(RGMethodCatalog.all) { m in
                    RGStatRow(label: m.shortName,
                              value: "\(m.typicalMinutes) min",
                              accent: RGTheme.inkSoft)
                }
                Text("These are the figures the app falls back on for guidance only. They never enter the averages above.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Irritation

    private var irritationSection: some View {
        let grid = store.irritationGrid()
        let breakdown = store.reactionBreakdown()

        return VStack(alignment: .leading, spacing: 14) {
            RGSectionHeader(text: "Zone by method")
            RGCard(padding: 12) {
                if grid.isEmpty {
                    Text("Nothing logged yet.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        RGHeatGrid(rows: grid, width: max(RGLayout.cardInnerWidth, 330))
                    }
                    Text("Shading is the share of sessions that recorded any reaction. The number inside each cell is the sample size, printed so that a single unlucky session cannot masquerade as a trend.")
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                    heatLegend
                }
            }

            RGSectionHeader(text: "Overall")
            RGCard {
                RGStatRow(label: "Sessions with any reaction",
                          value: RGFormat.percent(store.overallIrritationRate),
                          accent: RGTheme.coral,
                          detail: "\(store.sessions.count) sessions")
                RGDivider()
                if breakdown.isEmpty {
                    Text("No reactions recorded.")
                        .font(RGFont.body(12))
                        .foregroundColor(RGTheme.inkFaint)
                } else {
                    RGShareBars(rows: breakdown.map { r, n in
                        RGShareBars.Row(id: r.rawValue,
                                        label: r.title,
                                        value: Double(n),
                                        detail: RGFormat.percent(RGMath.ratio(n, of: store.sessions.count)),
                                        color: r.accent)
                    }, width: RGLayout.cardInnerWidth,
                       valueText: { RGFormat.whole($0) })
                }
            }

            RGSectionHeader(text: "Reading this honestly")
            RGCard {
                Text("Irritation rate is a count of what you recorded, nothing more. It cannot tell you why skin reacted, it does not identify a condition, and a run of bad sessions may have nothing to do with the method. If something on your skin is painful, spreading or not settling within a couple of weeks, that is a conversation for a pharmacist, doctor or dermatologist rather than a number on this screen.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var heatLegend: some View {
        HStack(spacing: 8) {
            Text("0%")
                .font(RGFont.label(9))
                .foregroundColor(RGTheme.inkFaint)
            Canvas { ctx, _ in
                let w: CGFloat = 110
                let h: CGFloat = 8
                let steps = 22
                for i in 0..<steps {
                    let f = Double(i) / Double(max(steps - 1, 1))
                    var seg = Path()
                    seg.addRect(CGRect(x: w * CGFloat(i) / CGFloat(steps), y: 0,
                                       width: w / CGFloat(steps) + 0.6, height: h))
                    ctx.fill(seg, with: .color(RGTheme.heat(f)))
                }
            }
            .frame(width: 110, height: 8)
            .allowsHitTesting(false)
            Text("100%")
                .font(RGFont.label(9))
                .foregroundColor(RGTheme.inkFaint)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Cadence drift

    private var driftSection: some View {
        let pairs = store.trackedPairs.filter { !(RGMethodCatalog.method($0.methodID)?.isCourseBased ?? false) }
        let pairIDs = pairs.map { $0.zoneID + "|" + $0.methodID }
        // Same as the projection chips: the stored id has to be checked against
        // the current list, or deleting the selected pair leaves the detail card
        // rendering a pair that no longer exists.
        let selectedID = pairIDs.first(where: { $0 == driftPair }) ?? pairIDs.first

        return VStack(alignment: .leading, spacing: 14) {
            RGSectionHeader(text: "Is a zone speeding up or slowing down?")
            RGCard {
                Text("The app fits a straight line through the gaps between your sessions for one zone and method. A rising line means you are going longer between sessions; a falling one means you are going more often. Below five gaps it says so instead of drawing a shape out of noise.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if pairs.isEmpty {
                RGEmptyState(title: "No pair to fit yet",
                             message: "Cadence drift needs a zone and method you have logged repeatedly. Light-based courses are excluded because their schedule is fixed rather than learned.",
                             glyph: .insights)
            } else {
                RGCard {
                    RGWrapChips(items: pairs.map { p in
                        (p.zoneID + "|" + p.methodID,
                         RGZoneCatalog.name(p.zoneID) + " / " + RGMethodCatalog.shortName(p.methodID))
                    }, selected: selectedID ?? "",
                       width: RGLayout.cardInnerWidth,
                       color: RGTheme.slateBlue) { id in
                        driftPair = id
                    }
                }

                if let sid = selectedID {
                    driftDetail(pairID: sid)
                }

                RGSectionHeader(text: "Every tracked pair")
                RGCard {
                    ForEach(pairIDs, id: \.self) { pid in
                        driftSummaryRow(pairID: pid)
                    }
                }
            }
        }
    }

    private func driftDetail(pairID: String) -> some View {
        let parts = pairID.split(separator: "|").map(String.init)
        let zoneID = parts.count > 0 ? parts[0] : ""
        let methodID = parts.count > 1 ? parts[1] : ""
        let keys = store.sessions(zoneID: zoneID, methodID: methodID).map { $0.dayKey }
        let gaps = RGIntervalEngine.gaps(from: keys)
        let pred = store.prediction(zoneID: zoneID, methodID: methodID)

        return RGCard(accent: RGTheme.slateBlue) {
            Text(RGZoneCatalog.name(zoneID) + " \u{00B7} " + RGMethodCatalog.shortName(methodID))
                .font(RGFont.heading(14.5))
                .foregroundColor(RGTheme.ink)

            RGDriftChart(gaps: gaps, width: RGLayout.cardInnerWidth, height: 100)

            RGDivider()

            RGStatRow(label: "Measured gaps",
                      value: "\(gaps.count)",
                      accent: RGTheme.ink,
                      detail: "\(pred.sessionCount) sessions")
            RGStatRow(label: "Learned interval",
                      value: RGFormat.days(pred.interval),
                      accent: RGTheme.sageDeep)
            RGStatRow(label: "Spread",
                      value: pred.cv != nil ? RGFormat.percentUnclamped(pred.cv) : RGFormat.dash,
                      accent: RGTheme.ink,
                      detail: "coefficient of variation")
            if store.settings.showConfidenceBadges {
                HStack {
                    Text("Confidence")
                        .font(RGFont.body(13))
                        .foregroundColor(RGTheme.inkSoft)
                    Spacer(minLength: 6)
                    RGConfidenceBadge(confidence: pred.confidence)
                }
            }

            Text(RGIntervalEngine.driftDescription(pred.driftPerSession, gapCount: gaps.count))
                .font(RGFont.body(12.5))
                .foregroundColor(RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func driftSummaryRow(pairID: String) -> some View {
        let parts = pairID.split(separator: "|").map(String.init)
        let zoneID = parts.count > 0 ? parts[0] : ""
        let methodID = parts.count > 1 ? parts[1] : ""
        let pred = store.prediction(zoneID: zoneID, methodID: methodID)
        let label = RGZoneCatalog.name(zoneID) + " / " + RGMethodCatalog.shortName(methodID)
        let value: String
        let accent: Color
        if pred.gapCount < 5 {
            value = "needs \(max(5 - pred.gapCount, 0)) more"
            accent = RGTheme.inkFaint
        } else if let d = pred.driftPerSession, d.isFinite {
            let perTen = d * 10
            if abs(perTen) < 1 {
                value = "steady"
                accent = RGTheme.sageDeep
            } else if perTen > 0 {
                value = "+" + RGFormat.oneDecimal(perTen) + " d/10"
                accent = RGTheme.sage
            } else {
                value = RGFormat.oneDecimal(perTen) + " d/10"
                accent = RGTheme.coral
            }
        } else {
            value = RGFormat.dash
            accent = RGTheme.inkFaint
        }
        return RGStatRow(label: label, value: value, accent: accent,
                         detail: "\(pred.gapCount) gap" + (pred.gapCount == 1 ? "" : "s"))
    }
}

import SwiftUI

struct RGDueView: View {
    @ObservedObject var store: RGStore
    let onLog: (String?, String?) -> Void
    let onOpenZones: () -> Void

    private var hasAnything: Bool { !store.sessions.isEmpty }

    var body: some View {
        // The whole prediction set is built once per body pass and then reused by
        // the subtitle, the summary card and the sections. Reading it separately
        // from each of those rebuilt it three times, each rebuild being
        // O(pairs x sessions).
        let rows = store.dueRows()
        let overdue = rows.reduce(0) { $0 + ($1.bucket == .overdue ? 1 : 0) }
        let tracked = rows.count
        let grouped: [(RGDueBucket, [RGDueRow])] =
            RGDueBucket.allCases.map { b in (b, rows.filter { $0.bucket == b }) }

        return RGScreen(title: "Due",
                 subtitle: subtitleText(overdue: overdue, tracked: tracked),
                 trailing: AnyView(
                    RGIconButton(glyph: .plus, side: 20, color: RGTheme.sageDeep) {
                        onLog(nil, nil)
                    }
                 )) {

            if !hasAnything {
                RGEmptyState(title: "Nothing tracked yet",
                             message: "Log one session and Regrowth Clock starts a clock for that zone and method. After a second session it has a real gap to learn from, and the prediction stops being a published average and starts being yours.",
                             glyph: .clock,
                             actionTitle: "Log a first session") {
                    onLog(nil, nil)
                }
                RGCard {
                    Text("How the prediction works")
                        .font(RGFont.heading(15))
                        .foregroundColor(RGTheme.ink)
                    Text("Every zone and method pair keeps its own interval. Until you have two sessions, the app shows the published starting figure for that combination and labels it Learning. From the second session onward it averages your own gaps, weighting the most recent ones far more heavily, and it tells you how confident that number is instead of hiding the uncertainty.")
                        .font(RGFont.body(13))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                RGDisclaimerNote()
            } else {
                summaryCard(overdue: overdue, tracked: tracked)

                ForEach(grouped, id: \.0.rawValue) { bucket, rows in
                    if !rows.isEmpty || bucket == .overdue {
                        RGSectionHeader(text: bucket.title,
                                        detail: rows.isEmpty ? nil : "\(rows.count)")
                        if rows.isEmpty {
                            Text(bucket.emptyMessage)
                                .font(RGFont.body(12))
                                .foregroundColor(RGTheme.inkFaint)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 2)
                        } else {
                            ForEach(rows) { row in
                                RGDueRowCard(store: store, row: row) {
                                    store.quickLog(zoneID: row.zoneID, methodID: row.methodID)
                                    RGHaptic.success(store.settings.hapticsEnabled)
                                }
                            }
                        }
                    }
                }

                RGSectionHeader(text: "Reminder model")
                RGCard {
                    Text("This list is the reminder")
                        .font(RGFont.heading(14))
                        .foregroundColor(RGTheme.ink)
                    Text("Regrowth Clock sends no notifications at all. Everything it knows is on this screen, sorted so the most overdue pair is at the top. Open it when you are deciding what to do, not because something buzzed.")
                        .font(RGFont.body(12.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    RGSecondaryButton(title: "Browse all zones", action: onOpenZones)
                }
                RGDisclaimerNote()
            }
        }
    }

    private func subtitleText(overdue: Int, tracked: Int) -> String {
        guard hasAnything else { return "Nothing scheduled yet" }
        if overdue > 0 {
            return "\(overdue) overdue of \(tracked) tracked pair" + (tracked == 1 ? "" : "s")
        }
        return "\(tracked) tracked pair" + (tracked == 1 ? "" : "s") + ", none overdue"
    }

    private func summaryCard(overdue: Int, tracked: Int) -> some View {
        RGCard {
            HStack(alignment: .top, spacing: 0) {
                summaryCell(value: "\(tracked)", label: "Pairs")
                divider
                summaryCell(value: "\(overdue)",
                            label: "Overdue",
                            accent: overdue > 0 ? RGTheme.coral : RGTheme.sage)
                divider
                summaryCell(value: "\(store.sessionsThisMonth)", label: "This month")
                divider
                summaryCell(value: lastSessionText, label: "Last")
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(RGTheme.hairline)
            .frame(width: 1, height: 34)
    }

    private func summaryCell(value: String, label: String, accent: Color = RGTheme.ink) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(RGFont.title(18))
                .foregroundColor(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(RGFont.label(9.5))
                .foregroundColor(RGTheme.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var lastSessionText: String {
        guard let d = store.daysSinceLastSession else { return RGFormat.dash }
        if d <= 0 { return "today" }
        if d == 1 { return "1d" }
        return "\(d)d"
    }
}

// MARK: - One row

struct RGDueRowCard: View {
    @ObservedObject var store: RGStore
    let row: RGDueRow
    let onQuickLog: () -> Void

    private var accent: Color {
        switch row.bucket {
        case .overdue: return RGTheme.coral
        case .today:   return RGTheme.clay
        default:       return RGTheme.sage
        }
    }

    var body: some View {
        RGCard(padding: 13, accent: row.bucket == .overdue ? RGTheme.coral : nil) {
            NavigationLink(destination: RGZoneDetailView(store: store, zoneID: row.zoneID)) {
                HStack(alignment: .top, spacing: 11) {
                    RGMethodGlyph(index: RGMethodCatalog.glyph(row.methodID),
                                  side: 30,
                                  color: RGMethodCatalog.color(row.methodID),
                                  lineWidth: 1.6)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(row.zoneName)
                                .font(RGFont.heading(15))
                                .foregroundColor(RGTheme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 4)
                            Text(dueText)
                                .font(RGFont.label(11))
                                .foregroundColor(accent)
                                .lineLimit(1)
                        }

                        HStack(spacing: 6) {
                            Text(row.methodName)
                                .font(RGFont.body(12))
                                .foregroundColor(RGTheme.inkSoft)
                                .lineLimit(1)
                            Text("\u{00B7}")
                                .font(RGFont.body(12))
                                .foregroundColor(RGTheme.inkFaint)
                            Text(intervalText)
                                .font(RGFont.mono(11.5))
                                .foregroundColor(RGTheme.inkSoft)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            if store.settings.showConfidenceBadges && !row.prediction.isCourseBased {
                                RGConfidenceBadge(confidence: row.prediction.confidence, compact: true)
                            }
                        }

                        RGUrgencyBar(daysUntil: row.daysUntil,
                                     interval: barInterval,
                                     width: RGLayout.cardInnerWidth - 41,
                                     height: 11)
                            .padding(.top, 2)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            RGDivider()

            HStack(spacing: 10) {
                Button(action: onQuickLog) {
                    HStack(spacing: 5) {
                        RGIconView(glyph: .plus, side: 12, color: RGTheme.sageDeep, lineWidth: 1.6)
                        Text("Log now")
                            .font(RGFont.label(11.5))
                            .foregroundColor(RGTheme.sageDeep)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(RGTheme.sage.opacity(0.13)))
                    .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 4)

                Text(footnote)
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }

    private var barInterval: Double? {
        if row.prediction.isCourseBased {
            guard let c = row.course else { return nil }
            return Double(c.nextGapWeeks * 7)
        }
        return row.prediction.interval
    }

    private var dueText: String {
        guard let d = row.daysUntil else {
            if row.prediction.isCourseBased, let c = row.course, c.complete { return "Course done" }
            return RGFormat.dash
        }
        if d < 0 {
            let n = -d
            return n == 1 ? "1 day over" : "\(n) days over"
        }
        if d == 0 { return "Due today" }
        if d == 1 { return "Tomorrow" }
        return "in \(d) days"
    }

    private var intervalText: String {
        if row.prediction.isCourseBased {
            guard let c = row.course else { return RGFormat.dash }
            return "session \(min(c.sessionsDone, c.plannedSessions)) of \(c.plannedSessions)"
        }
        guard let iv = row.prediction.interval else { return RGFormat.dash }
        return "every " + RGFormat.days(iv)
    }

    private var footnote: String {
        if row.prediction.isCourseBased {
            guard let c = row.course else { return "" }
            if c.complete { return "course complete" }
            return "next gap \(c.nextGapWeeks) weeks"
        }
        guard let last = row.prediction.lastDayKey else { return "" }
        let n = RGCal.daysBetween(last, RGCal.todayKey)
        let base = n <= 0 ? "logged today" : (n == 1 ? "1 day ago" : "\(n) days ago")
        return base + " \u{00B7} \(row.prediction.sessionCount) logged"
    }
}

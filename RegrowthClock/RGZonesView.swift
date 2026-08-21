import SwiftUI

struct RGZonesView: View {
    @ObservedObject var store: RGStore
    let onLog: (String?, String?) -> Void

    @State private var groupFilter: RGZoneGroup? = nil
    @State private var onlyTracked: Bool = false

    private var zones: [RGZone] {
        RGZoneCatalog.all.filter { z in
            if let g = groupFilter, z.group != g { return false }
            if onlyTracked && store.sessionCount(zoneID: z.id) == 0 { return false }
            return true
        }
    }

    private var cardWidth: CGFloat {
        max((RGLayout.contentWidth - 12) / 2, 130)
    }

    /// Built once per body pass: recomputing the whole due list inside every
    /// card would be O(zones x pairs x sessions) on each render.
    private func minDaysByZone() -> [String: Int] {
        var out: [String: Int] = [:]
        for row in store.dueRows() {
            guard let d = row.daysUntil else { continue }
            if let existing = out[row.zoneID] {
                out[row.zoneID] = min(existing, d)
            } else {
                out[row.zoneID] = d
            }
        }
        return out
    }

    var body: some View {
        let dueMap = minDaysByZone()
        return RGScreen(title: "Zones",
                 subtitle: "\(RGZoneCatalog.all.count) zones \u{00B7} \(store.zonesWithData.count) with data",
                 trailing: AnyView(
                    RGIconButton(glyph: .plus, side: 20, color: RGTheme.sageDeep) {
                        onLog(nil, nil)
                    }
                 )) {

            filterRow

            if zones.isEmpty {
                RGEmptyState(title: "No zones match",
                             message: "Nothing has been logged in this group yet. Turn the tracked-only filter off to see the whole set.",
                             glyph: .zones,
                             actionTitle: "Show everything") {
                    onlyTracked = false
                    groupFilter = nil
                }
            } else {
                ForEach(rowIndices, id: \.self) { r in
                    HStack(alignment: .top, spacing: 12) {
                        zoneCard(zones[r * 2], dueDays: dueMap[zones[r * 2].id])
                        if r * 2 + 1 < zones.count {
                            zoneCard(zones[r * 2 + 1], dueDays: dueMap[zones[r * 2 + 1].id])
                        } else {
                            Color.clear.frame(width: cardWidth, height: 1)
                        }
                    }
                }
            }

            RGSectionHeader(text: "Methods")
            ForEach(RGMethodCatalog.all) { m in
                NavigationLink(destination: RGMethodDetailView(store: store, methodID: m.id)) {
                    methodRow(m)
                }
                .buttonStyle(PlainButtonStyle())
            }

            RGDisclaimerNote()
        }
    }

    private var rowIndices: [Int] {
        let n = zones.count
        guard n > 0 else { return [] }
        return Array(0...((n - 1) / 2))
    }

    private var filterRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    RGChoiceChip(text: "All", selected: groupFilter == nil) { groupFilter = nil }
                    ForEach(RGZoneGroup.allCases, id: \.rawValue) { g in
                        RGChoiceChip(text: g.title, selected: groupFilter == g) {
                            groupFilter = (groupFilter == g) ? nil : g
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            RGChoiceChip(text: onlyTracked ? "Showing tracked only" : "Show tracked only",
                         selected: onlyTracked,
                         color: RGTheme.slateBlue) {
                onlyTracked.toggle()
            }
        }
    }

    private func zoneCard(_ zone: RGZone, dueDays: Int?) -> some View {
        NavigationLink(destination: RGZoneDetailView(store: store, zoneID: zone.id)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    RGZoneGlyph(index: zone.glyph, side: 38,
                                color: tracked(zone) ? RGTheme.sageDeep : RGTheme.inkFaint)
                    Spacer(minLength: 0)
                    if let days = dueDays {
                        Text(days < 0 ? "\(-days)d over" : (days == 0 ? "today" : "\(days)d"))
                            .font(RGFont.label(9.5))
                            .foregroundColor(days < 0 ? RGTheme.coral : RGTheme.sage)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill((days < 0 ? RGTheme.coral : RGTheme.sage).opacity(0.13)))
                    }
                }

                Text(zone.name)
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle(zone))
                    .font(RGFont.label(9.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(11)
            .frame(width: cardWidth, height: 132, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous).fill(RGTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(tracked(zone) ? RGTheme.sage.opacity(0.3) : RGTheme.cardEdge, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func tracked(_ zone: RGZone) -> Bool {
        store.sessionCount(zoneID: zone.id) > 0
    }

    private func subtitle(_ zone: RGZone) -> String {
        let n = store.sessionCount(zoneID: zone.id)
        if n == 0 {
            return "Not tracked \u{00B7} prior " + RGFormat.days(zone.priorDays)
        }
        let methods = store.methodsUsed(inZone: zone.id).count
        return "\(n) session" + (n == 1 ? "" : "s") + " \u{00B7} \(methods) method" + (methods == 1 ? "" : "s")
    }

    private func methodRow(_ m: RGMethod) -> some View {
        RGCard(padding: 12) {
            HStack(alignment: .center, spacing: 11) {
                RGMethodGlyph(index: m.glyph, side: 28,
                              color: RGTheme.chip(m.chipIndex), lineWidth: 1.6)
                VStack(alignment: .leading, spacing: 3) {
                    Text(m.name)
                        .font(RGFont.heading(14))
                        .foregroundColor(RGTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(methodSubtitle(m))
                        .font(RGFont.label(10))
                        .foregroundColor(RGTheme.inkFaint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer(minLength: 4)
                RGIconView(glyph: .chevronRight, side: 15, color: RGTheme.inkFaint)
            }
            .contentShape(Rectangle())
        }
    }

    private func methodSubtitle(_ m: RGMethod) -> String {
        let n = store.sessions(methodID: m.id).count
        let cost = RGFormat.money(m.typicalCost, symbol: store.settings.currencySymbol)
        if n == 0 {
            return "not used \u{00B7} typical " + cost + " per session"
        }
        return "\(n) session" + (n == 1 ? "" : "s") + " logged \u{00B7} typical " + cost
    }
}

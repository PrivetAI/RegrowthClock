import SwiftUI

// MARK: - Custom day picker (no system DatePicker anywhere in this app)

struct RGDayPicker: View {
    @Binding var dayKey: Int
    let width: CGFloat

    @State private var visibleMonth: Int = RGCal.monthKey(RGCal.todayKey)

    private var todayKey: Int { RGCal.todayKey }

    var body: some View {
        // Built once per body pass. As a computed property the whole month grid
        // was rebuilt for the row count and again for every one of the 42 cells.
        let weeks = makeWeeks()
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Button(action: { shiftMonth(-1) }) {
                    RGIconView(glyph: .back, side: 16, color: RGTheme.sageDeep)
                        .frame(width: 34, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Text(RGCal.monthYearLabel(visibleMonth))
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                    .frame(maxWidth: .infinity)

                Button(action: { shiftMonth(1) }) {
                    RGIconView(glyph: .chevronRight, side: 16,
                               color: canGoForward ? RGTheme.sageDeep : RGTheme.inkGhost)
                        .frame(width: 34, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canGoForward)
            }

            HStack(spacing: 0) {
                ForEach(weekdayLabels, id: \.self) { d in
                    Text(d)
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                        .frame(width: cellWidth, height: 14)
                }
            }

            VStack(spacing: 4) {
                ForEach(0..<weeks.count, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { c in
                            dayCell(weeks[r][c])
                        }
                    }
                }
            }

            HStack(spacing: 7) {
                RGChoiceChip(text: "Today", selected: dayKey == todayKey) {
                    dayKey = todayKey
                    visibleMonth = RGCal.monthKey(todayKey)
                }
                RGChoiceChip(text: "Yesterday", selected: dayKey == RGCal.addingDays(todayKey, -1)) {
                    dayKey = RGCal.addingDays(todayKey, -1)
                    visibleMonth = RGCal.monthKey(dayKey)
                }
                RGChoiceChip(text: "3 days ago", selected: dayKey == RGCal.addingDays(todayKey, -3)) {
                    dayKey = RGCal.addingDays(todayKey, -3)
                    visibleMonth = RGCal.monthKey(dayKey)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(width: width, alignment: .leading)
        .onAppear { visibleMonth = RGCal.monthKey(dayKey) }
    }

    private var cellWidth: CGFloat { max(width / 7, 20) }

    private var weekdayLabels: [String] { ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] }

    private var canGoForward: Bool {
        visibleMonth < RGCal.monthKey(todayKey)
    }

    private func shiftMonth(_ delta: Int) {
        var y = visibleMonth / 100
        var m = visibleMonth % 100 + delta
        while m > 12 { m -= 12; y += 1 }
        while m < 1 { m += 12; y -= 1 }
        let candidate = y * 100 + m
        if delta > 0 && candidate > RGCal.monthKey(todayKey) { return }
        if candidate < 190001 { return }
        visibleMonth = candidate
    }

    /// Six rows of seven day keys; 0 means an empty cell.
    private func makeWeeks() -> [[Int]] {
        let year = visibleMonth / 100
        let month = visibleMonth % 100
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        comps.hour = 12
        let cal = RGCal.cal
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else {
            return Array(repeating: Array(repeating: 0, count: 7), count: 5)
        }
        // Monday-first index of the first day.
        let weekday = cal.component(.weekday, from: first) // 1 = Sunday
        let leading = (weekday + 5) % 7
        let dayCount = range.count
        var flat: [Int] = Array(repeating: 0, count: leading)
        for d in 1...dayCount {
            flat.append(year * 10000 + month * 100 + d)
        }
        while flat.count % 7 != 0 { flat.append(0) }
        var out: [[Int]] = []
        var i = 0
        while i < flat.count {
            out.append(Array(flat[i..<min(i + 7, flat.count)]))
            i += 7
        }
        return out
    }

    private func dayCell(_ key: Int) -> some View {
        let isEmpty = key == 0
        let isFuture = !isEmpty && key > todayKey
        let selected = !isEmpty && key == dayKey
        let isToday = !isEmpty && key == todayKey
        return Button(action: {
            guard !isEmpty, !isFuture else { return }
            dayKey = key
        }) {
            ZStack {
                if selected {
                    Circle().fill(RGTheme.sageDeep)
                } else if isToday {
                    Circle().stroke(RGTheme.sage, lineWidth: 1.2)
                }
                if !isEmpty {
                    Text("\(key % 100)")
                        .font(RGFont.body(12.5))
                        .foregroundColor(selected ? RGTheme.card
                                         : (isFuture ? RGTheme.inkGhost : RGTheme.ink))
                }
            }
            .frame(width: cellWidth, height: 30)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isEmpty || isFuture)
    }
}

// MARK: - Session editor sheet

struct RGSessionEditor: View {
    @ObservedObject var store: RGStore
    let presetZoneID: String?
    let presetMethodID: String?
    let editingID: UUID?
    let onDone: () -> Void

    private enum Field: Hashable { case cost, minutes, note }

    @State private var zoneID: String = RGZoneCatalog.all.first?.id ?? "underarms"
    @State private var methodID: String = RGMethodCatalog.defaultMethodID
    @State private var dayKey: Int = RGCal.todayKey
    @State private var costText: String = ""
    @State private var minutesText: String = ""
    @State private var reaction: RGReaction = .none
    @State private var note: String = ""
    @State private var loaded: Bool = false
    @FocusState private var focus: Field?

    private var isEditing: Bool { editingID != nil }

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                RGSheetHeader(title: isEditing ? "Edit session" : "New session",
                              subtitle: headerSubtitle,
                              onClose: onDone)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        section("Zone") {
                            zonePicker
                        }

                        section("Method") {
                            methodPicker
                        }

                        section("Date") {
                            RGDayPicker(dayKey: $dayKey, width: RGLayout.contentWidth - 24)
                        }

                        section("Cost and duration", detail: "optional") {
                            VStack(alignment: .leading, spacing: 10) {
                                fieldRow(label: "Cost (\(store.settings.currencySymbol))",
                                         placeholder: defaultCostPlaceholder,
                                         text: $costText,
                                         field: .cost,
                                         keyboard: .decimalPad)
                                fieldRow(label: "Minutes",
                                         placeholder: defaultMinutesPlaceholder,
                                         text: $minutesText,
                                         field: .minutes,
                                         keyboard: .numberPad)
                                if focus == .cost || focus == .minutes {
                                    Button(action: { focus = nil }) {
                                        Text("Done editing")
                                            .font(RGFont.label(11))
                                            .foregroundColor(RGTheme.sageDeep)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Capsule().fill(RGTheme.sage.opacity(0.13)))
                                            .contentShape(Capsule())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                Text("Left blank, the app uses the published typical figure for this method so the projections still work. Entered values always win.")
                                    .font(RGFont.body(11.5))
                                    .foregroundColor(RGTheme.inkFaint)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        section("Skin reaction") {
                            VStack(alignment: .leading, spacing: 8) {
                                reactionPicker
                                Text(reaction.blurb)
                                    .font(RGFont.body(12))
                                    .foregroundColor(RGTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        section("Note", detail: "optional") {
                            noteField
                        }

                        RGPrimaryButton(title: isEditing ? "Save changes" : "Log this session") {
                            save()
                        }
                        .padding(.top, 2)

                        if isEditing {
                            RGSecondaryButton(title: "Cancel", color: RGTheme.inkSoft, action: onDone)
                        }

                        RGDisclaimerNote(text: "Recording a skin reaction here is what lets the app compare methods honestly. It is a record, not an assessment.")
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onAppear(perform: loadOnce)
    }

    // MARK: Pieces

    private func section<C: View>(_ title: String,
                                  detail: String? = nil,
                                  @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            RGFieldLabel(text: title, detail: detail)
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(RGTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(RGTheme.cardEdge, lineWidth: 1)
        )
    }

    private var zonePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(RGZoneCatalog.grouped(), id: \.0.rawValue) { group, zones in
                VStack(alignment: .leading, spacing: 6) {
                    Text(group.title)
                        .font(RGFont.label(9.5))
                        .foregroundColor(RGTheme.inkFaint)
                    RGWrapChips(items: zones.map { ($0.id, $0.name) },
                                selected: zoneID,
                                width: RGLayout.contentWidth - 24) { id in
                        zoneID = id
                        focus = nil
                        if let d = store.settings.defaultMethodByZone[id],
                           RGMethodCatalog.method(d) != nil {
                            methodID = d
                        }
                    }
                }
            }
        }
    }

    private var methodPicker: some View {
        VStack(alignment: .leading, spacing: 9) {
            RGWrapChips(items: RGMethodCatalog.all.map { ($0.id, $0.shortName) },
                        selected: methodID,
                        width: RGLayout.contentWidth - 24) { id in
                methodID = id
                focus = nil
            }
            if let m = RGMethodCatalog.method(methodID) {
                Text(m.irritationProfile)
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var reactionPicker: some View {
        RGWrapChips(items: RGReaction.allCases.map { ($0.rawValue, $0.title) },
                    selected: reaction.rawValue,
                    width: RGLayout.contentWidth - 24,
                    color: RGTheme.coral) { id in
            reaction = RGReaction(rawValue: id) ?? .none
            focus = nil
        }
    }

    private func fieldRow(label: String,
                          placeholder: String,
                          text: Binding<String>,
                          field: Field,
                          keyboard: UIKeyboardType) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(RGFont.body(13))
                .foregroundColor(RGTheme.inkSoft)
                .frame(width: 92, alignment: .leading)
            TextField(placeholder, text: text)
                .font(RGFont.mono(14))
                .foregroundColor(RGTheme.ink)
                .keyboardType(keyboard)
                .focused($focus, equals: field)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(RGTheme.creamDeep.opacity(0.55))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(focus == field ? RGTheme.sage : RGTheme.hairline, lineWidth: 1)
                )
                // pitfall 3: without this, only the first field in the sheet takes a tap
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .onTapGesture { focus = field }
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("How did it go?", text: $note)
                .font(RGFont.body(13.5))
                .foregroundColor(RGTheme.ink)
                .focused($focus, equals: .note)
                .padding(.horizontal, 10)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(RGTheme.creamDeep.opacity(0.55))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(focus == .note ? RGTheme.sage : RGTheme.hairline, lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .onTapGesture { focus = .note }

            if focus == .note {
                Button(action: { focus = nil }) {
                    Text("Done editing")
                        .font(RGFont.label(11))
                        .foregroundColor(RGTheme.sageDeep)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(RGTheme.sage.opacity(0.13)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: Data

    private var headerSubtitle: String {
        let z = RGZoneCatalog.name(zoneID)
        let m = RGMethodCatalog.shortName(methodID)
        return z + " \u{00B7} " + m + " \u{00B7} " + RGFormat.date(RGCal.date(fromKey: dayKey))
    }

    private var defaultCostPlaceholder: String {
        guard let m = RGMethodCatalog.method(methodID) else { return "0" }
        return String(format: "%.2f typical", m.typicalCost)
    }

    private var defaultMinutesPlaceholder: String {
        guard let m = RGMethodCatalog.method(methodID) else { return "0" }
        return "\(m.typicalMinutes) typical"
    }

    private func loadOnce() {
        guard !loaded else { return }
        loaded = true
        if let id = editingID, let s = store.session(id: id) {
            zoneID = s.zoneID
            methodID = s.methodID
            dayKey = s.dayKey
            reaction = s.reaction
            note = s.note
            if let c = s.cost { costText = String(format: "%.2f", c) }
            if let m = s.minutes { minutesText = "\(m)" }
            return
        }
        if let z = presetZoneID, RGZoneCatalog.zone(z) != nil { zoneID = z }
        if let m = presetMethodID, RGMethodCatalog.method(m) != nil {
            methodID = m
        } else {
            methodID = store.defaultMethod(for: zoneID)
        }
        dayKey = RGCal.todayKey
    }

    private func parsedCost() -> Double? {
        let cleaned = costText.replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, let v = Double(cleaned), v.isFinite, v >= 0, v < 100000 else { return nil }
        return v
    }

    private func parsedMinutes() -> Int? {
        let cleaned = minutesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, let v = Int(cleaned), v > 0, v < 1440 else { return nil }
        return v
    }

    private func save() {
        focus = nil
        let safeDay = min(dayKey, RGCal.todayKey)
        if let id = editingID, var existing = store.session(id: id) {
            existing.zoneID = zoneID
            existing.methodID = methodID
            existing.dayKey = safeDay
            existing.cost = parsedCost()
            existing.minutes = parsedMinutes()
            existing.reaction = reaction
            existing.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updateSession(existing)
        } else {
            let s = RGSession(zoneID: zoneID,
                              methodID: methodID,
                              dayKey: safeDay,
                              minutes: parsedMinutes(),
                              cost: parsedCost(),
                              reaction: reaction,
                              note: note.trimmingCharacters(in: .whitespacesAndNewlines))
            store.addSession(s)
        }
        RGHaptic.success(store.settings.hapticsEnabled)
        onDone()
    }
}

// MARK: - Wrapping chip row (no LazyVGrid, iOS 15 friendly)

struct RGWrapChips: View {
    let items: [(String, String)]
    let selected: String
    let width: CGFloat
    var color: Color = RGTheme.sage
    let onPick: (String) -> Void

    var body: some View {
        let rows = RGWrapChips.layout(items: items, width: width)
        return VStack(alignment: .leading, spacing: 7) {
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: 7) {
                    ForEach(rows[r], id: \.0) { item in
                        RGChoiceChip(text: item.1,
                                     selected: selected == item.0,
                                     color: color) {
                            onPick(item.0)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }

    /// Rough width estimate; chips have 12 pt horizontal padding each side and a
    /// 12 pt semibold rounded label, which averages close to 7 pt per character.
    static func layout(items: [(String, String)], width: CGFloat) -> [[(String, String)]] {
        var rows: [[(String, String)]] = [[]]
        var used: CGFloat = 0
        let available = max(width, 100)
        for item in items {
            let w = CGFloat(item.1.count) * 7.0 + 26
            if used + w > available && !(rows[rows.count - 1].isEmpty) {
                rows.append([])
                used = 0
            }
            rows[rows.count - 1].append(item)
            used += w + 7
        }
        return rows
    }
}

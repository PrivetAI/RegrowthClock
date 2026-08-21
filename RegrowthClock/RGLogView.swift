import SwiftUI

private enum RGPendingDelete: Identifiable {
    case session(UUID)
    case product(UUID)

    var id: String {
        switch self {
        case .session(let u): return "s" + u.uuidString
        case .product(let u): return "p" + u.uuidString
        }
    }
}

struct RGLogView: View {
    @ObservedObject var store: RGStore
    let onNew: () -> Void
    let onEdit: (UUID) -> Void
    let onNewProduct: () -> Void
    let onEditProduct: (UUID) -> Void

    @State private var zoneFilter: String? = nil
    @State private var methodFilter: String? = nil
    @State private var showProducts: Bool = true
    @State private var pendingDelete: RGPendingDelete? = nil
    @State private var confirmVisible: Bool = false

    private var filtered: [RGSession] {
        store.sessions.filter { s in
            if let z = zoneFilter, s.zoneID != z { return false }
            if let m = methodFilter, s.methodID != m { return false }
            return true
        }
    }

    var body: some View {
        RGScreen(title: "Log",
                 subtitle: subtitleText,
                 trailing: AnyView(
                    RGIconButton(glyph: .plus, side: 20, color: RGTheme.sageDeep, action: onNew)
                 )) {

            RGPrimaryButton(title: "Add a session", action: onNew)

            productsSection

            RGSectionHeader(text: "History", detail: "\(filtered.count) shown")

            filterRow

            if store.sessions.isEmpty {
                RGEmptyState(title: "No sessions recorded",
                             message: "Every prediction in this app is built from entries you make here. A session needs a zone, a method and a date; cost, duration, skin reaction and a note are all optional but they are what makes the Insights tab worth opening.",
                             glyph: .log,
                             actionTitle: "Add the first one",
                             action: onNew)
            } else if filtered.isEmpty {
                RGEmptyState(title: "Nothing matches that filter",
                             message: "You have \(store.sessions.count) recorded session" + (store.sessions.count == 1 ? "" : "s") + ", but none in this zone and method combination. Clear the filters to see everything again.",
                             glyph: .filter,
                             actionTitle: "Clear filters") {
                    zoneFilter = nil
                    methodFilter = nil
                }
            } else {
                ForEach(filtered) { s in
                    RGSessionRow(session: s,
                                 currency: store.settings.currencySymbol,
                                 usedDefaultCost: !store.costIsUserEntered(s),
                                 defaultCost: store.cost(of: s),
                                 onEdit: { onEdit(s.id) },
                                 onDelete: {
                                    pendingDelete = .session(s.id)
                                    confirmVisible = true
                                 })
                }
            }

            RGDisclaimerNote()
        }
        .confirmationDialog(confirmTitle,
                            isPresented: $confirmVisible,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                performDelete()
            }
            Button("Keep it", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text(confirmMessage)
        }
    }

    private var subtitleText: String {
        let n = store.sessions.count
        if n == 0 { return "Nothing recorded yet" }
        let spend = RGFormat.moneyWhole(store.totalSpend, symbol: store.settings.currencySymbol)
        return "\(n) session" + (n == 1 ? "" : "s") + " \u{00B7} " + spend + " estimated total"
    }

    // MARK: Filters

    private var filterRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    RGChoiceChip(text: "All zones", selected: zoneFilter == nil) {
                        zoneFilter = nil
                    }
                    ForEach(store.zonesWithData, id: \.self) { z in
                        RGChoiceChip(text: RGZoneCatalog.name(z),
                                     selected: zoneFilter == z) {
                            zoneFilter = (zoneFilter == z) ? nil : z
                        }
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    RGChoiceChip(text: "All methods", selected: methodFilter == nil) {
                        methodFilter = nil
                    }
                    ForEach(RGMethodCatalog.all) { m in
                        if !store.sessions(methodID: m.id).isEmpty {
                            RGChoiceChip(text: m.shortName,
                                         selected: methodFilter == m.id,
                                         color: RGTheme.chip(m.chipIndex)) {
                                methodFilter = (methodFilter == m.id) ? nil : m.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: Products

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RGSectionHeader(text: "Blade and product life",
                                detail: store.products.isEmpty ? nil : "\(store.products.count)")
                Button(action: { showProducts.toggle() }) {
                    RGIconView(glyph: showProducts ? .chevronDown : .chevronRight,
                               side: 15, color: RGTheme.inkFaint)
                        .frame(width: 28, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            if showProducts {
                if store.products.isEmpty {
                    RGEmptyState(title: "No kit registered",
                                 message: "Register a cartridge, an epilator head or a wax pot with the date you started it. Every session logged with that method counts against its recommended life, so the app can tell you it is worn out before your skin does.",
                                 glyph: .timer,
                                 actionTitle: "Register a product",
                                 action: onNewProduct)
                } else {
                    ForEach(store.products) { p in
                        RGProductRow(status: store.productStatus(p),
                                     onReplace: {
                                        store.replaceProduct(id: p.id)
                                        RGHaptic.success(store.settings.hapticsEnabled)
                                     },
                                     onEdit: { onEditProduct(p.id) },
                                     onDelete: {
                                        pendingDelete = .product(p.id)
                                        confirmVisible = true
                                     })
                    }
                    RGSecondaryButton(title: "Register another product", action: onNewProduct)
                }
            }
        }
    }

    // MARK: Delete confirmation

    private var confirmTitle: String {
        switch pendingDelete {
        case .session: return "Delete this session?"
        case .product: return "Remove this product?"
        case .none:    return "Delete?"
        }
    }

    private var confirmMessage: String {
        switch pendingDelete {
        case .session:
            return "The gap it created disappears from the learner, so the predicted interval for that zone and method will change."
        case .product:
            return "The wear count goes with it. Your session history is not affected."
        case .none:
            return ""
        }
    }

    private func performDelete() {
        switch pendingDelete {
        case .session(let id):
            store.deleteSession(id: id)
        case .product(let id):
            store.deleteProduct(id: id)
        case .none:
            break
        }
        pendingDelete = nil
    }
}

// MARK: - Session row

struct RGSessionRow: View {
    let session: RGSession
    let currency: String
    let usedDefaultCost: Bool
    let defaultCost: Double
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        RGCard(padding: 12) {
            HStack(alignment: .top, spacing: 10) {
                RGMethodGlyph(index: RGMethodCatalog.glyph(session.methodID),
                              side: 26,
                              color: RGMethodCatalog.color(session.methodID),
                              lineWidth: 1.5)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(RGZoneCatalog.name(session.zoneID))
                            .font(RGFont.heading(14))
                            .foregroundColor(RGTheme.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(RGFormat.shortDate(session.date))
                            .font(RGFont.mono(11))
                            .foregroundColor(RGTheme.inkSoft)
                    }

                    HStack(spacing: 6) {
                        Text(RGMethodCatalog.shortName(session.methodID))
                            .font(RGFont.body(11.5))
                            .foregroundColor(RGTheme.inkSoft)
                        if session.reaction.countsAsIrritation {
                            RGPill(text: session.reaction.title, color: session.reaction.accent)
                        }
                        Spacer(minLength: 2)
                        Text(costText)
                            .font(RGFont.mono(11))
                            .foregroundColor(usedDefaultCost ? RGTheme.inkFaint : RGTheme.ink)
                    }

                    if let m = session.minutes, m > 0 {
                        Text(RGFormat.minutes(m))
                            .font(RGFont.label(10))
                            .foregroundColor(RGTheme.inkFaint)
                    }

                    if !session.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(session.note)
                            .font(RGFont.body(12))
                            .foregroundColor(RGTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 1)
                    }
                }
            }

            RGDivider()

            HStack(spacing: 8) {
                Button(action: onEdit) {
                    HStack(spacing: 5) {
                        RGIconView(glyph: .pencil, side: 12, color: RGTheme.slateBlue, lineWidth: 1.5)
                        Text("Edit")
                            .font(RGFont.label(11))
                            .foregroundColor(RGTheme.slateBlue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(RGTheme.slateBlue.opacity(0.12)))
                    .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onDelete) {
                    HStack(spacing: 5) {
                        RGIconView(glyph: .trash, side: 12, color: RGTheme.coral, lineWidth: 1.5)
                        Text("Delete")
                            .font(RGFont.label(11))
                            .foregroundColor(RGTheme.coral)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(RGTheme.coral.opacity(0.10)))
                    .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 0)

                if usedDefaultCost {
                    Text("estimated cost")
                        .font(RGFont.label(9))
                        .foregroundColor(RGTheme.inkFaint)
                }
            }
        }
    }

    private var costText: String {
        if let c = session.cost, c.isFinite, c >= 0 {
            return RGFormat.money(c, symbol: currency)
        }
        return "~" + RGFormat.money(defaultCost, symbol: currency)
    }
}

// MARK: - Product row

struct RGProductRow: View {
    let status: RGProductStatus
    let onReplace: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        RGCard(padding: 12, accent: status.isDue ? RGTheme.coral : nil) {
            HStack(alignment: .top, spacing: 10) {
                RGMethodGlyph(index: RGMethodCatalog.glyph(status.product.methodID),
                              side: 26,
                              color: RGMethodCatalog.color(status.product.methodID),
                              lineWidth: 1.5)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(status.product.name)
                            .font(RGFont.heading(14))
                            .foregroundColor(RGTheme.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(status.statusText)
                            .font(RGFont.label(10.5))
                            .foregroundColor(status.accent)
                            .lineLimit(1)
                    }

                    Text(subtitleText)
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    RGProgressBar(fraction: status.fraction,
                                  width: RGLayout.cardInnerWidth - 36,
                                  height: 7,
                                  color: status.accent,
                                  trackColor: RGTheme.creamDeep)
                }
            }

            RGDivider()

            HStack(spacing: 8) {
                Button(action: onReplace) {
                    Text("Mark replaced")
                        .font(RGFont.label(11))
                        .foregroundColor(RGTheme.sageDeep)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(RGTheme.sage.opacity(0.13)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onEdit) {
                    Text("Edit")
                        .font(RGFont.label(11))
                        .foregroundColor(RGTheme.slateBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(RGTheme.slateBlue.opacity(0.12)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onDelete) {
                    Text("Remove")
                        .font(RGFont.label(11))
                        .foregroundColor(RGTheme.coral)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(RGTheme.coral.opacity(0.10)))
                        .contentShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 0)
            }
        }
    }

    private var subtitleText: String {
        let m = RGMethodCatalog.shortName(status.product.methodID)
        let lifeText = status.life > 0 ? "\(status.uses) of \(status.life) uses" : "\(status.uses) uses"
        let daysText = status.daysInService == 1 ? "1 day in service" : "\(status.daysInService) days in service"
        var out = m + " \u{00B7} " + lifeText + " \u{00B7} " + daysText
        if status.product.replacements > 0 {
            out += " \u{00B7} replaced \(status.product.replacements)x"
        }
        return out
    }
}

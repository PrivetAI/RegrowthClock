import SwiftUI

struct RGProductEditor: View {
    @ObservedObject var store: RGStore
    let editingID: UUID?
    let onDone: () -> Void

    private enum Field: Hashable { case name, life }

    @State private var name: String = ""
    @State private var methodID: String = RGMethodCatalog.defaultMethodID
    @State private var startDayKey: Int = RGCal.todayKey
    @State private var carriedUses: Int = 0
    @State private var lifeText: String = ""
    @State private var loaded: Bool = false
    @FocusState private var focus: Field?

    private var isEditing: Bool { editingID != nil }

    private var method: RGMethod? { RGMethodCatalog.method(methodID) }

    private var recommendedLife: Int { method?.consumableLife ?? 0 }

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                RGSheetHeader(title: isEditing ? "Edit product" : "Register a product",
                              subtitle: subtitleText,
                              onClose: onDone)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        section("Name") {
                            TextField(placeholderName, text: $name)
                                .font(RGFont.body(14))
                                .foregroundColor(RGTheme.ink)
                                .focused($focus, equals: .name)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(RGTheme.creamDeep.opacity(0.55))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(focus == .name ? RGTheme.sage : RGTheme.hairline, lineWidth: 1)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .onTapGesture { focus = .name }
                        }

                        section("Method it belongs to") {
                            VStack(alignment: .leading, spacing: 9) {
                                RGWrapChips(items: RGMethodCatalog.all.map { ($0.id, $0.shortName) },
                                            selected: methodID,
                                            width: RGLayout.contentWidth - 24) { id in
                                    methodID = id
                                    focus = nil
                                }
                                if let m = method, let consumable = m.consumableName {
                                    Text("Wears out as: " + consumable
                                         + (m.consumableLife != nil ? ", commonly cited as about \(m.consumableLife ?? 0) uses." : "."))
                                        .font(RGFont.body(11.5))
                                        .foregroundColor(RGTheme.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Text("Every session you log with this method on or after the start date counts as one use.")
                                    .font(RGFont.body(11.5))
                                    .foregroundColor(RGTheme.inkFaint)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        section("Started on") {
                            RGDayPicker(dayKey: $startDayKey, width: RGLayout.contentWidth - 24)
                        }

                        section("Uses already on it", detail: "before you started tracking") {
                            HStack(spacing: 10) {
                                stepButton("\u{2212}") {
                                    carriedUses = max(0, carriedUses - 1)
                                }
                                Text("\(carriedUses)")
                                    .font(RGFont.mono(17))
                                    .foregroundColor(RGTheme.ink)
                                    .frame(minWidth: 44)
                                stepButton("+") {
                                    carriedUses = min(999, carriedUses + 1)
                                }
                                Spacer(minLength: 0)
                                Button(action: { carriedUses = 0 }) {
                                    Text("Reset")
                                        .font(RGFont.label(11))
                                        .foregroundColor(RGTheme.inkSoft)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Capsule().fill(RGTheme.creamDeep))
                                        .contentShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        section("Replace after", detail: "optional override") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    Text("Uses")
                                        .font(RGFont.body(13))
                                        .foregroundColor(RGTheme.inkSoft)
                                        .frame(width: 92, alignment: .leading)
                                    TextField(recommendedLife > 0 ? "\(recommendedLife) recommended" : "no guidance",
                                              text: $lifeText)
                                        .font(RGFont.mono(14))
                                        .foregroundColor(RGTheme.ink)
                                        .keyboardType(.numberPad)
                                        .focused($focus, equals: .life)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 9)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(RGTheme.creamDeep.opacity(0.55))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(focus == .life ? RGTheme.sage : RGTheme.hairline, lineWidth: 1)
                                        )
                                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .onTapGesture { focus = .life }
                                }
                                Text("Blade life varies with hair coarseness and the area covered, so the published figure is a starting point rather than a rule. Override it once you know your own.")
                                    .font(RGFont.body(11.5))
                                    .foregroundColor(RGTheme.inkFaint)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        if focus != nil {
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

                        RGPrimaryButton(title: isEditing ? "Save changes" : "Register product",
                                        enabled: !trimmedName.isEmpty) {
                            save()
                        }

                        if trimmedName.isEmpty {
                            Text("Give it a name so you can tell two razors apart.")
                                .font(RGFont.body(11.5))
                                .foregroundColor(RGTheme.inkFaint)
                        }
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

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var placeholderName: String {
        method?.consumableName ?? "Product name"
    }

    private var subtitleText: String {
        guard let m = method else { return "" }
        return m.shortName + " \u{00B7} started " + RGFormat.date(RGCal.date(fromKey: startDayKey))
    }

    private func stepButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(RGFont.title(18))
                .foregroundColor(RGTheme.sageDeep)
                .frame(width: 44, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(RGTheme.sage.opacity(0.13))
                )
                .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

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

    private func loadOnce() {
        guard !loaded else { return }
        loaded = true
        if let id = editingID, let p = store.products.first(where: { $0.id == id }) {
            name = p.name
            methodID = p.methodID
            startDayKey = p.startDayKey
            carriedUses = p.carriedUses
            if let l = p.customLife { lifeText = "\(l)" }
        } else {
            methodID = RGMethodCatalog.defaultMethodID
            name = RGMethodCatalog.method(methodID)?.consumableName ?? ""
            startDayKey = RGCal.todayKey
        }
    }

    private func parsedLife() -> Int? {
        let cleaned = lifeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, let v = Int(cleaned), v > 0, v <= 5000 else { return nil }
        return v
    }

    private func save() {
        focus = nil
        guard !trimmedName.isEmpty else { return }
        let safeStart = min(startDayKey, RGCal.todayKey)
        if let id = editingID, var p = store.products.first(where: { $0.id == id }) {
            p.name = trimmedName
            p.methodID = methodID
            p.startDayKey = safeStart
            p.carriedUses = max(0, carriedUses)
            p.customLife = parsedLife()
            store.updateProduct(p)
        } else {
            let p = RGProduct(name: trimmedName,
                              methodID: methodID,
                              startDayKey: safeStart,
                              carriedUses: max(0, carriedUses),
                              customLife: parsedLife())
            store.addProduct(p)
        }
        RGHaptic.success(store.settings.hapticsEnabled)
        onDone()
    }
}

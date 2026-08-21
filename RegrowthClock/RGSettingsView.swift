import SwiftUI

// MARK: - Custom switch (no system Toggle anywhere in this app)

struct RGSwitchRow: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool
    var accent: Color = RGTheme.sageDeep
    var onChange: ((Bool) -> Void)? = nil

    var body: some View {
        Button(action: {
            isOn.toggle()
            onChange?(isOn)
        }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(RGFont.heading(14))
                        .foregroundColor(RGTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Text(detail)
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                RGSwitchTrack(isOn: isOn, accent: accent)
                    .padding(.top, 2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RGSwitchTrack: View {
    let isOn: Bool
    let accent: Color

    var body: some View {
        Canvas { ctx, _ in
            let w: CGFloat = 44
            let h: CGFloat = 26
            var track = Path()
            track.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h),
                                 cornerSize: CGSize(width: h / 2, height: h / 2))
            ctx.fill(track, with: .color(isOn ? accent : RGTheme.inkGhost))
            var knob = Path()
            let r = h - 6
            knob.addEllipse(in: CGRect(x: isOn ? w - r - 3 : 3, y: 3, width: r, height: r))
            ctx.fill(knob, with: .color(RGTheme.card))
        }
        .frame(width: 44, height: 26)
        .allowsHitTesting(false)
    }
}

// MARK: - Settings

struct RGSettingsView: View {
    @ObservedObject var store: RGStore
    let onReopenOnboarding: () -> Void

    @State private var showPrivacy: Bool = false
    @State private var confirmReset: Bool = false

    var body: some View {
        RGScreen(title: "Settings",
                 subtitle: "Everything stays on this device") {

            RGSectionHeader(text: "Display")
            RGCard {
                RGFieldLabel(text: "Currency symbol", detail: "display only, no conversion")
                RGWrapChips(items: RGCurrency.options.map { ($0.symbol, $0.symbol + "  " + $0.label) },
                            selected: store.settings.currencySymbol,
                            width: RGLayout.cardInnerWidth) { sym in
                    var s = store.settings
                    s.currencySymbol = sym
                    store.settings = s
                    RGHaptic.tap(store.settings.hapticsEnabled)
                }
                Text("Amounts are never converted between currencies. This only changes the symbol printed in front of the numbers you entered.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGCard {
                RGSwitchRow(title: "Show confidence badges",
                            detail: "Prints Learning, Low, Medium or High next to every predicted interval so a guess never looks like a measurement.",
                            isOn: confidenceBinding)
                RGDivider()
                RGSwitchRow(title: "Haptic feedback",
                            detail: "A short tap when you switch tabs or record a session.",
                            isOn: hapticsBinding)
            }

            RGSectionHeader(text: "Defaults")
            NavigationLink(destination: RGDefaultMethodsView(store: store)) {
                settingsRow(title: "Default method per zone",
                            detail: defaultMethodSummary,
                            glyph: .zones)
            }
            .buttonStyle(PlainButtonStyle())

            RGSectionHeader(text: "Privacy")
            RGCard {
                RGSwitchRow(title: "Privacy lock",
                            detail: "Ask for Face ID, Touch ID or the device passcode when the app opens. If your device has none of those set up, the app opens normally rather than locking you out of your own log.",
                            isOn: lockBinding,
                            accent: RGTheme.slateBlue)
            }

            Button(action: { showPrivacy = true }) {
                settingsRow(title: "Privacy Policy",
                            detail: "Opens the policy page",
                            glyph: .shield)
            }
            .buttonStyle(PlainButtonStyle())

            RGSectionHeader(text: "Reference")
            NavigationLink(destination: RGCareLibraryView()) {
                settingsRow(title: "Care card library",
                            detail: "\(RGCareLibrary.all.count) entries, searchable",
                            glyph: .book)
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: RGAboutView(store: store)) {
                settingsRow(title: "About Regrowth Clock",
                            detail: "How the interval learner works",
                            glyph: .info)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onReopenOnboarding) {
                settingsRow(title: "Replay the introduction",
                            detail: "The five screens from first launch",
                            glyph: .leaf)
            }
            .buttonStyle(PlainButtonStyle())

            RGSectionHeader(text: "Health note")
            RGCard(accent: RGTheme.clay) {
                Text("This is a grooming tracker, not a medical device")
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                Text("Regrowth Clock records what you choose to record and does arithmetic on it. It does not diagnose anything, it does not tell you what is wrong with your skin, and nothing in it replaces a conversation with a qualified clinician. Reference intervals and care notes are general published guidance, written for a general reader, and they are not personal instructions. If something on your skin is painful, spreading, bleeding, not settling, or simply worrying you, speak to a pharmacist, doctor or dermatologist.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "Data")
            RGCard {
                RGStatRow(label: "Sessions stored", value: "\(store.sessions.count)")
                RGStatRow(label: "Products tracked", value: "\(store.products.count)")
                RGStatRow(label: "Zones with data", value: "\(store.zonesWithData.count) of \(RGZoneCatalog.all.count)")
                RGStatRow(label: "Storage", value: "on device only", accent: RGTheme.sageDeep)
                RGDivider()
                Text("Nothing is uploaded, synced or shared. Deleting the app deletes the log with it, and there is no copy anywhere else.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: { confirmReset = true }) {
                HStack(spacing: 10) {
                    RGIconView(glyph: .trash, side: 17, color: RGTheme.coral)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reset all data")
                            .font(RGFont.heading(14))
                            .foregroundColor(RGTheme.coral)
                        Text("Deletes every session, product and setting")
                            .font(RGFont.body(11.5))
                            .foregroundColor(RGTheme.inkSoft)
                    }
                    Spacer(minLength: 0)
                }
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(RGTheme.coralMist.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(RGTheme.coral.opacity(0.3), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())

            Text("Regrowth Clock \u{00B7} version 1.0")
                .font(RGFont.label(10))
                .foregroundColor(RGTheme.inkFaint)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)
        }
        .confirmationDialog("Delete everything?",
                            isPresented: $confirmReset,
                            titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) {
                store.resetEverything()
                RGHaptic.success(store.settings.hapticsEnabled)
            }
            Button("Keep my data", role: .cancel) { }
        } message: {
            Text("Every session, every learned interval, every product and every setting goes. There is no backup and this cannot be undone.")
        }
        .sheet(isPresented: $showPrivacy) {
            RGWebPanel(panelAddress: "https://regrowthclock.org/click.php")
        }
    }

    // MARK: Bindings that write through to the store

    private var confidenceBinding: Binding<Bool> {
        Binding(get: { store.settings.showConfidenceBadges },
                set: { v in
                    var s = store.settings
                    s.showConfidenceBadges = v
                    store.settings = s
                })
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(get: { store.settings.hapticsEnabled },
                set: { v in
                    var s = store.settings
                    s.hapticsEnabled = v
                    store.settings = s
                })
    }

    private var lockBinding: Binding<Bool> {
        Binding(get: { store.settings.privacyLockEnabled },
                set: { v in
                    var s = store.settings
                    s.privacyLockEnabled = v
                    store.settings = s
                })
    }

    private var defaultMethodSummary: String {
        let n = store.settings.defaultMethodByZone.count
        if n == 0 { return "None set; the app uses your last method per zone" }
        return "\(n) zone" + (n == 1 ? "" : "s") + " pinned to a method"
    }

    private func settingsRow(title: String, detail: String, glyph: RGGlyph) -> some View {
        RGCard(padding: 13) {
            HStack(spacing: 12) {
                RGIconView(glyph: glyph, side: 19, color: RGTheme.sageDeep)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(RGFont.heading(14))
                        .foregroundColor(RGTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Text(detail)
                        .font(RGFont.body(11.5))
                        .foregroundColor(RGTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                RGIconView(glyph: .chevronRight, side: 15, color: RGTheme.inkFaint)
            }
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Default method per zone

struct RGDefaultMethodsView: View {
    @ObservedObject var store: RGStore

    var body: some View {
        RGSubScreen(title: "Default method per zone",
                    subtitle: "Used when you log from the Due list or a zone screen") {
            RGCard {
                Text("Leave a zone unset and the app falls back to whichever method you logged there most recently, and to a cartridge razor if it has never seen that zone before.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(RGZoneCatalog.grouped(), id: \.0.rawValue) { group, zones in
                RGSectionHeader(text: group.title)
                ForEach(zones) { z in
                    RGCard(padding: 12) {
                        HStack(spacing: 10) {
                            RGZoneGlyph(index: z.glyph, side: 26, color: RGTheme.sageDeep)
                            Text(z.name)
                                .font(RGFont.heading(14))
                                .foregroundColor(RGTheme.ink)
                            Spacer(minLength: 4)
                            Text(store.settings.defaultMethodByZone[z.id] == nil
                                 ? "auto"
                                 : RGMethodCatalog.shortName(store.settings.defaultMethodByZone[z.id] ?? ""))
                                .font(RGFont.label(10))
                                .foregroundColor(RGTheme.inkFaint)
                        }
                        RGWrapChips(items: RGMethodCatalog.all.map { ($0.id, $0.shortName) },
                                    selected: store.settings.defaultMethodByZone[z.id] ?? "",
                                    width: RGLayout.cardInnerWidth) { id in
                            if store.settings.defaultMethodByZone[z.id] == id {
                                store.setDefaultMethod(nil, for: z.id)
                            } else {
                                store.setDefaultMethod(id, for: z.id)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - About

struct RGAboutView: View {
    @ObservedObject var store: RGStore

    var body: some View {
        RGSubScreen(title: "About Regrowth Clock",
                    subtitle: "What the app computes, and what it refuses to guess") {

            RGCard {
                HStack(spacing: 14) {
                    RGBrandMark(side: 62)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Regrowth Clock")
                            .font(RGFont.title(18))
                            .foregroundColor(RGTheme.ink)
                        Text("Version 1.0")
                            .font(RGFont.label(10))
                            .foregroundColor(RGTheme.inkFaint)
                    }
                }
            }

            RGSectionHeader(text: "The interval learner")
            RGCard {
                Text("Every zone and method pair keeps its own clock. The app measures the number of days between consecutive sessions you logged for that pair, then averages those gaps with an exponentially weighted moving average: the most recent gap counts fully, the one before it counts about six tenths as much, the one before that about a third, and so on. Recent behavior therefore dominates, which is what makes the prediction follow a change of habit instead of burying it under a year of history.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                RGDivider()
                Text("Before you have measured gaps, the app blends in a published starting figure for that zone and method, weighted as though it were three of your own gaps. That weight falls to zero by the time you have six real gaps, so the published figure fades out exactly as your own data becomes worth trusting.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "Confidence, stated honestly")
            RGCard {
                confidenceLine(.learning, "Fewer than two measured gaps")
                confidenceLine(.low, "Fewer than five gaps, or gaps that vary by more than about forty percent")
                confidenceLine(.medium, "Gaps varying between roughly twenty and forty percent")
                confidenceLine(.high, "Gaps that agree within about twenty percent of each other")
                RGDivider()
                Text("Spread is measured as the coefficient of variation, which is the standard deviation of your gaps divided by their mean. It is printed on the drift screen so you can see the number the badge came from rather than taking the badge on trust.")
                    .font(RGFont.body(12))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "The one exception")
            RGCard {
                Text("Laser and intense pulsed light do not use the learner at all. A course works by catching hair in its growing phase, so the schedule comes from the region of the body rather than from how quickly you personally see regrowth: roughly four weeks on the face, six on the torso and underarms, eight on the legs, with the gaps widening as the course progresses. The app tracks which session of the course you are on and when the next one falls, and says how complete the course is, rather than pretending to have learned a cadence it cannot learn.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            RGSectionHeader(text: "What it will not do")
            RGCard {
                bullet("Send notifications. There are none anywhere in the app; the Due list is the whole reminder.")
                bullet("Upload anything. Your log never leaves the device.")
                bullet("Judge you. Zones are zones, there are no problem areas and no before-and-after framing.")
                bullet("Assume who you are. Nothing in the copy assumes a gender, a body or a reason for using it.")
                bullet("Invent numbers. Where there is no data the app prints an em dash and says why.")
            }

            RGSectionHeader(text: "Content shipped")
            RGCard {
                RGStatRow(label: "Zones", value: "\(RGZoneCatalog.all.count)")
                RGStatRow(label: "Methods", value: "\(RGMethodCatalog.all.count)")
                RGStatRow(label: "Care cards", value: "\(RGCareLibrary.all.count)")
                RGStatRow(label: "Skin reactions tracked", value: "\(RGReaction.allCases.count)")
                RGStatRow(label: "Your sessions", value: "\(store.sessions.count)", accent: RGTheme.sageDeep)
            }

            RGDisclaimerNote()
        }
    }

    private func confidenceLine(_ c: RGConfidence, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RGConfidenceBadge(confidence: c)
            Text(text)
                .font(RGFont.body(12))
                .foregroundColor(RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(RGTheme.sage)
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(RGFont.body(12.5))
                .foregroundColor(RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

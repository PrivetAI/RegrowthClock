import SwiftUI

struct RGOnboardingFlow: View {
    @ObservedObject var store: RGStore
    let onFinish: () -> Void

    @State private var page: Int = 0
    @State private var acknowledged: Bool = false

    private let pageCount = 5

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top bar with a skip control that is always reachable.
                HStack {
                    Text("Step \(page + 1) of \(pageCount)")
                        .font(RGFont.label(10))
                        .foregroundColor(RGTheme.inkFaint)
                    Spacer(minLength: 6)
                    if page < pageCount - 1 {
                        Button(action: { page = pageCount - 1 }) {
                            Text("Skip")
                                .font(RGFont.label(11))
                                .foregroundColor(RGTheme.sageDeep)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(RGTheme.sage.opacity(0.12)))
                                .contentShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        pageContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)

                controls
            }
        }
    }

    // MARK: Pages

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case 0:
            heroPage
        case 1:
            learnerPage
        case 2:
            comparePage
        case 3:
            noNotificationsPage
        default:
            disclaimerPage
        }
    }

    private var heroPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer(minLength: 0)
                RGBrandMark(side: RGDevice.isCompact ? 88 : 112)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)

            Text("Regrowth Clock")
                .font(RGFont.display(RGDevice.isCompact ? 26 : 30))
                .foregroundColor(RGTheme.ink)

            Text("A hair removal tracker that works out your own interval instead of assuming one.")
                .font(RGFont.title(17))
                .foregroundColor(RGTheme.sageDeep)
                .fixedSize(horizontal: false, vertical: true)

            Text("Most reminder apps ask you to pick a number of days and then nag you on that schedule forever. Skin does not work like that. Your underarms and your shins are on different clocks, and a razor and a sugar paste are on different clocks again, in the same zone, on the same person.")
                .font(RGFont.body(14))
                .foregroundColor(RGTheme.inkSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            RGCard {
                statLine("\(RGZoneCatalog.all.count) zones", "each with its own starting figure and care note")
                statLine("\(RGMethodCatalog.all.count) methods", "from a cartridge razor to a light-based course")
                statLine("\(RGCareLibrary.all.count) care cards", "technique, aftercare, ingrown hairs and myths")
            }
        }
    }

    private var learnerPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            RGIconView(glyph: .clock, side: 42, color: RGTheme.sageDeep, lineWidth: 2)

            Text("It learns from the gaps")
                .font(RGFont.display(RGDevice.isCompact ? 23 : 26))
                .foregroundColor(RGTheme.ink)

            Text("Log a session, and the app records the date against that zone and that method. When you log the next one, it has a gap. From then on it averages your gaps, weighting the most recent one most heavily, so a change in habit shows up within two or three sessions rather than being buried.")
                .font(RGFont.body(14))
                .foregroundColor(RGTheme.inkSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            RGCard {
                Text("And it tells you when it does not know")
                    .font(RGFont.heading(14.5))
                    .foregroundColor(RGTheme.ink)
                HStack(spacing: 8) {
                    RGConfidenceBadge(confidence: .learning)
                    RGConfidenceBadge(confidence: .low)
                    RGConfidenceBadge(confidence: .medium)
                    RGConfidenceBadge(confidence: .high)
                }
                Text("Every predicted date carries one of these. Learning means the number on screen is still a published average rather than yours. High means your own gaps agree closely with each other. The app would rather look uncertain than look confident and be wrong.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var comparePage: some View {
        VStack(alignment: .leading, spacing: 16) {
            RGIconView(glyph: .insights, side: 42, color: RGTheme.sageDeep, lineWidth: 2)

            Text("Compare methods on one zone")
                .font(RGFont.display(RGDevice.isCompact ? 23 : 26))
                .foregroundColor(RGTheme.ink)

            Text("Record what your skin did after each session, and the app can put two methods side by side on the same patch of you: how long each one held, what each one cost, and how often each one left a reaction. That comparison is the reason this app exists, and it is not something a fixed reminder can ever produce.")
                .font(RGFont.body(14))
                .foregroundColor(RGTheme.inkSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            RGCard(accent: RGTheme.sage) {
                Text("What that looks like")
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                Text("\u{201C}Bikini line, razor: 12 sessions, holds 4 days, irritation 58 percent. Bikini line, sugaring: 6 sessions, holds 22 days, irritation 17 percent.\u{201D}")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.sageDeep)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Sample sizes are printed next to every rate, everywhere in the app, so a single unlucky session can never pass itself off as a pattern.")
                    .font(RGFont.body(12))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var noNotificationsPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            RGIconView(glyph: .due, side: 42, color: RGTheme.sageDeep, lineWidth: 2)

            Text("No notifications, ever")
                .font(RGFont.display(RGDevice.isCompact ? 23 : 26))
                .foregroundColor(RGTheme.ink)

            Text("Regrowth Clock will never buzz your phone about your body hair. There is no notification code in it at all. The Due tab is the reminder: open it when you are deciding what to do, and everything the app knows is sorted with the most overdue pair at the top.")
                .font(RGFont.body(14))
                .foregroundColor(RGTheme.inkSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            RGCard {
                bulletLine("Your log stays on this device. Nothing is uploaded or synced.")
                bulletLine("An optional lock can put Face ID, Touch ID or your passcode in front of it.")
                bulletLine("Zones are zones. No problem areas, no before and after, no assumptions about who you are.")
                bulletLine("Every number on screen is computed from what you logged, or marked with an em dash when there is nothing to compute.")
            }
        }
    }

    private var disclaimerPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            RGIconView(glyph: .info, side: 42, color: RGTheme.clay, lineWidth: 2)

            Text("Before you start")
                .font(RGFont.display(RGDevice.isCompact ? 23 : 26))
                .foregroundColor(RGTheme.ink)

            RGCard(accent: RGTheme.clay) {
                Text("Regrowth Clock is a personal grooming tracker. It is not a medical device, it does not diagnose anything, and it does not provide medical advice. The intervals, technique notes and care cards in it are general published guidance written for a general reader, not personal instructions for your skin.")
                    .font(RGFont.body(13.5))
                    .foregroundColor(RGTheme.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                RGDivider()
                Text("If your skin is painful, bleeding, blistering, spreading, infected-looking or simply not settling, or if the way your hair grows changes noticeably over a few months, speak to a pharmacist, doctor or dermatologist. Several care cards in the library exist purely to point you toward that conversation.")
                    .font(RGFont.body(13))
                    .foregroundColor(RGTheme.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: { acknowledged.toggle() }) {
                HStack(alignment: .top, spacing: 11) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(acknowledged ? RGTheme.sageDeep : RGTheme.inkFaint, lineWidth: 1.6)
                            .frame(width: 22, height: 22)
                        if acknowledged {
                            RGIconView(glyph: .check, side: 16, color: RGTheme.sageDeep, lineWidth: 2)
                        }
                    }
                    Text("I understand this app records and organizes information and does not give medical advice.")
                        .font(RGFont.body(13))
                        .foregroundColor(RGTheme.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            Text("This note stays available in Settings, along with the full care card library.")
                .font(RGFont.body(11.5))
                .foregroundColor(RGTheme.inkFaint)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Controls

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? RGTheme.sageDeep : RGTheme.inkGhost)
                        .frame(width: i == page ? 20 : 7, height: 7)
                }
            }

            HStack(spacing: 10) {
                if page > 0 {
                    Button(action: { page = max(0, page - 1) }) {
                        Text("Back")
                            .font(RGFont.heading(14))
                            .foregroundColor(RGTheme.inkSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(RGTheme.creamDeep)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 110)
                }

                RGPrimaryButton(title: page == pageCount - 1 ? "Start tracking" : "Next",
                                enabled: page < pageCount - 1 || acknowledged) {
                    if page < pageCount - 1 {
                        page += 1
                    } else {
                        finish()
                    }
                }
            }

            if page == pageCount - 1 && !acknowledged {
                Text("Tick the box above to continue.")
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(
            RGTheme.cream
                .overlay(Rectangle().fill(RGTheme.hairline).frame(height: 1), alignment: .top)
        )
    }

    private func finish() {
        var s = store.settings
        s.onboardingComplete = true
        store.settings = s
        RGHaptic.success(store.settings.hapticsEnabled)
        onFinish()
    }

    // MARK: Small pieces

    private func statLine(_ value: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(value)
                .font(RGFont.heading(14))
                .foregroundColor(RGTheme.sageDeep)
                .frame(width: 92, alignment: .leading)
            Text(text)
                .font(RGFont.body(12.5))
                .foregroundColor(RGTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func bulletLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
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

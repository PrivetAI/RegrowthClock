import SwiftUI

/// Every external reference the care card library cites.
///
/// Guideline 1.4.1 requires that health information carries citations the user
/// can actually reach. Each entry below is a real, publicly reachable page from
/// a recognised health authority, a dermatology reference, or a peer-reviewed
/// journal. Cards refer to these by `id`, so a source is described once and can
/// also be listed on its own screen.
struct RGSource: Identifiable {
    let id: String
    /// Organisation or journal responsible for the page.
    let publisher: String
    /// Title of the cited page or article, as published.
    let title: String
    /// What kind of source this is, and when it was published where that matters.
    let kind: String
    let urlString: String

    var url: URL? { URL(string: urlString) }

    /// "aad.org", "nhs.uk" - shown so the destination is visible before tapping.
    var host: String {
        guard let h = url?.host else { return urlString }
        return h.hasPrefix("www.") ? String(h.dropFirst(4)) : h
    }
}

enum RGSourceCatalog {

    static let all: [RGSource] = [

        // MARK: American Academy of Dermatology

        RGSource(id: "aad-how-to-shave",
                 publisher: "American Academy of Dermatology",
                 title: "Hair removal: How to shave",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/hair/how-to-shave"),

        RGSource(id: "aad-remove-unwanted-hair",
                 publisher: "American Academy of Dermatology",
                 title: "6 ways to remove unwanted hair",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/hair/remove-unwanted-hair"),

        RGSource(id: "aad-razor-bump-prevention",
                 publisher: "American Academy of Dermatology",
                 title: "6 razor bump prevention tips from dermatologists",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/hair/razor-bump-prevention"),

        RGSource(id: "aad-razor-bump-remedies",
                 publisher: "American Academy of Dermatology",
                 title: "Razor bump remedies for men with darker skin tones",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/hair/razor-bump-remedies"),

        RGSource(id: "aad-trimming-pubic-hair",
                 publisher: "American Academy of Dermatology",
                 title: "7 ways to prevent injuries while trimming pubic hair",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/hair/trimming-pubic-hair"),

        RGSource(id: "aad-exfoliate",
                 publisher: "American Academy of Dermatology",
                 title: "How to safely exfoliate at home",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-secrets/routine/safely-exfoliate-at-home"),

        RGSource(id: "aad-dry-skin",
                 publisher: "American Academy of Dermatology",
                 title: "Dermatologists' top tips for relieving dry skin",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-basics/dry/dermatologists-tips-relieve-dry-skin"),

        RGSource(id: "aad-sunscreen-faqs",
                 publisher: "American Academy of Dermatology",
                 title: "Sunscreen FAQs",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/sunscreen-faqs"),

        RGSource(id: "aad-abcde",
                 publisher: "American Academy of Dermatology",
                 title: "What to look for: ABCDEs of melanoma",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/diseases/skin-cancer/find/at-risk/abcdes"),

        RGSource(id: "aad-laser-hair-removal",
                 publisher: "American Academy of Dermatology",
                 title: "Laser hair removal: Overview",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/cosmetic/hair-removal/laser-hair-removal-overview"),

        RGSource(id: "aad-workout-acne",
                 publisher: "American Academy of Dermatology",
                 title: "Is your workout causing your acne?",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/diseases/acne/causes/workouts"),

        RGSource(id: "aad-workout-skin",
                 publisher: "American Academy of Dermatology",
                 title: "How your workout can affect your skin",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-secrets/routine/workout-affect-skin"),

        RGSource(id: "aad-healthy-beard",
                 publisher: "American Academy of Dermatology",
                 title: "A dermatologist's top tips for a healthy beard",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-secrets/face/healthy-beard"),

        RGSource(id: "aad-keratosis-pilaris",
                 publisher: "American Academy of Dermatology",
                 title: "Keratosis pilaris: Self-care",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/diseases/a-z/keratosis-pilaris-self-care"),

        RGSource(id: "aad-summer-skin",
                 publisher: "American Academy of Dermatology",
                 title: "12 summer skin problems you can prevent",
                 kind: "Patient guidance from board-certified dermatologists",
                 urlString: "https://www.aad.org/public/everyday-care/skin-care-secrets/routine/prevent-summer-skin-problems"),

        // MARK: NHS (United Kingdom)

        RGSource(id: "nhs-ingrown-hairs",
                 publisher: "NHS (United Kingdom)",
                 title: "Ingrown hairs",
                 kind: "National health service condition page",
                 urlString: "https://www.nhs.uk/conditions/ingrown-hairs/"),

        RGSource(id: "nhs-boils",
                 publisher: "NHS (United Kingdom)",
                 title: "Boils",
                 kind: "National health service condition page",
                 urlString: "https://www.nhs.uk/conditions/boils/"),

        RGSource(id: "nhs-staph",
                 publisher: "NHS (United Kingdom)",
                 title: "Staph infection",
                 kind: "National health service condition page",
                 urlString: "https://www.nhs.uk/conditions/staphylococcal-infections/"),

        RGSource(id: "nhs-pcos",
                 publisher: "NHS (United Kingdom)",
                 title: "Polyendocrine metabolic ovarian syndrome (PMOS), formerly PCOS",
                 kind: "National health service condition page",
                 urlString: "https://www.nhs.uk/conditions/polycystic-ovary-syndrome-pcos/"),

        RGSource(id: "nhs-hirsutism",
                 publisher: "NHS (United Kingdom)",
                 title: "Excessive hair growth (hirsutism)",
                 kind: "National health service condition page",
                 urlString: "https://www.nhs.uk/conditions/hirsutism/"),

        RGSource(id: "nhs-sun-safety",
                 publisher: "NHS (United Kingdom)",
                 title: "Sunscreen and sun safety",
                 kind: "National health service prevention guidance",
                 urlString: "https://www.nhs.uk/live-well/seasonal-health/sunscreen-and-sun-safety/"),

        RGSource(id: "nhs-emollients",
                 publisher: "NHS (United Kingdom)",
                 title: "Emollients",
                 kind: "National health service treatment page",
                 urlString: "https://www.nhs.uk/tests-and-treatments/emollients/"),

        // MARK: MedlinePlus, U.S. National Library of Medicine

        RGSource(id: "medlineplus-folliculitis",
                 publisher: "MedlinePlus, U.S. National Library of Medicine",
                 title: "Folliculitis",
                 kind: "Medical encyclopedia entry",
                 urlString: "https://medlineplus.gov/ency/article/000823.htm"),

        RGSource(id: "medlineplus-unwanted-hair",
                 publisher: "MedlinePlus, U.S. National Library of Medicine",
                 title: "Excessive or unwanted hair in women",
                 kind: "Medical encyclopedia entry",
                 urlString: "https://medlineplus.gov/ency/article/007622.htm"),

        RGSource(id: "medlineplus-depilatory",
                 publisher: "MedlinePlus, U.S. National Library of Medicine",
                 title: "Depilatory poisoning",
                 kind: "Medical encyclopedia entry",
                 urlString: "https://medlineplus.gov/ency/article/002697.htm"),

        // MARK: DermNet

        RGSource(id: "dermnet-pfb",
                 publisher: "DermNet",
                 title: "Pseudofolliculitis barbae (razor bumps)",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/pseudofolliculitis-barbae"),

        RGSource(id: "dermnet-folliculitis",
                 publisher: "DermNet",
                 title: "Folliculitis",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/folliculitis"),

        RGSource(id: "dermnet-waxing",
                 publisher: "DermNet",
                 title: "Waxing",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/waxing"),

        RGSource(id: "dermnet-photosensitivity",
                 publisher: "DermNet",
                 title: "Drug-induced photosensitivity",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/drug-induced-photosensitivity"),

        RGSource(id: "dermnet-fragrance",
                 publisher: "DermNet",
                 title: "Fragrance allergy",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/fragrance-allergy"),

        RGSource(id: "dermnet-cosmetics",
                 publisher: "DermNet",
                 title: "Contact reactions to cosmetics",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/contact-reactions-to-cosmetics"),

        RGSource(id: "dermnet-acd",
                 publisher: "DermNet",
                 title: "Allergic contact dermatitis",
                 kind: "Dermatology reference, peer reviewed",
                 urlString: "https://dermnetnz.org/topics/allergic-contact-dermatitis"),

        // MARK: U.S. Food and Drug Administration

        RGSource(id: "fda-hair-products",
                 publisher: "U.S. Food and Drug Administration",
                 title: "Hair Products",
                 kind: "Regulator guidance for consumers",
                 urlString: "https://www.fda.gov/cosmetics/cosmetic-products/hair-products"),

        RGSource(id: "fda-using-cosmetics-safely",
                 publisher: "U.S. Food and Drug Administration",
                 title: "Using Cosmetics Safely",
                 kind: "Regulator guidance for consumers",
                 urlString: "https://www.fda.gov/cosmetics/resources-consumers-cosmetics/using-cosmetics-safely"),

        RGSource(id: "fda-cosmetics-qa",
                 publisher: "U.S. Food and Drug Administration",
                 title: "Cosmetics Safety Q&A: Personal Care Products",
                 kind: "Regulator guidance for consumers",
                 urlString: "https://www.fda.gov/cosmetics/resources-consumers-cosmetics/cosmetics-safety-qa-personal-care-products"),

        RGSource(id: "fda-medical-lasers",
                 publisher: "U.S. Food and Drug Administration",
                 title: "Medical Lasers",
                 kind: "Regulator guidance on laser devices",
                 urlString: "https://www.fda.gov/radiation-emitting-products/surgical-and-therapeutic-products/medical-lasers"),

        // MARK: Centers for Disease Control and Prevention

        RGSource(id: "cdc-hot-tub-rash",
                 publisher: "Centers for Disease Control and Prevention",
                 title: "Preventing Hot Tub Rash",
                 kind: "Public health guidance",
                 urlString: "https://www.cdc.gov/healthy-swimming/prevention/preventing-hot-tub-rash.html"),

        RGSource(id: "cdc-hepatitis-c",
                 publisher: "Centers for Disease Control and Prevention",
                 title: "Hepatitis C Basics",
                 kind: "Public health guidance",
                 urlString: "https://www.cdc.gov/hepatitis-c/about/index.html"),

        // MARK: Peer-reviewed literature and reference texts

        RGSource(id: "statpearls-physiology-hair",
                 publisher: "StatPearls, NCBI Bookshelf",
                 title: "Physiology, Hair",
                 kind: "Peer-reviewed reference chapter",
                 urlString: "https://www.ncbi.nlm.nih.gov/books/NBK499948/"),

        RGSource(id: "informedhealth-hair",
                 publisher: "InformedHealth.org, NCBI Bookshelf",
                 title: "In brief: What is the structure of hair and how does it grow?",
                 kind: "Peer-reviewed reference chapter",
                 urlString: "https://www.ncbi.nlm.nih.gov/books/NBK546248/"),

        RGSource(id: "jid-shaving-hair-growth",
                 publisher: "Journal of Investigative Dermatology",
                 title: "Lynfield YL, MacWilliams P. Shaving and hair growth. 1970;55(3):170-2",
                 kind: "Peer-reviewed study, listed on PubMed",
                 urlString: "https://pubmed.ncbi.nlm.nih.gov/5459955/"),

        RGSource(id: "hair-removal-review",
                 publisher: "Skin Therapy Letter",
                 title: "Kang CN et al. Hair Removal Practices: A Literature Review. 2021",
                 kind: "Peer-reviewed review, listed on PubMed",
                 urlString: "https://pubmed.ncbi.nlm.nih.gov/34524781/"),

        RGSource(id: "pain-menstrual-meta",
                 publisher: "Pain (journal of the IASP)",
                 title: "Riley JL 3rd et al. A meta-analytic review of pain perception across the menstrual cycle. 1999",
                 kind: "Peer-reviewed meta-analysis, listed on PubMed",
                 urlString: "https://pubmed.ncbi.nlm.nih.gov/10431710/")
    ]

    static let byID: [String: RGSource] = {
        var d: [String: RGSource] = [:]
        for s in all { d[s.id] = s }
        return d
    }()

    static func source(_ id: String) -> RGSource? { byID[id] }

    static func sources(_ ids: [String]) -> [RGSource] {
        ids.compactMap { byID[$0] }
    }

    /// Distinct publishers, in the order they first appear above.
    static var publishers: [String] {
        var seen: Set<String> = []
        var out: [String] = []
        for s in all where !seen.contains(s.publisher) {
            seen.insert(s.publisher)
            out.append(s.publisher)
        }
        return out
    }

    static func sources(publisher: String) -> [RGSource] {
        all.filter { $0.publisher == publisher }
    }

    /// Every source cited by the given cards, de-duplicated, catalog order kept.
    static func union(of cards: [RGCareCard]) -> [RGSource] {
        var seen: Set<String> = []
        for c in cards {
            for id in c.sourceIDs { seen.insert(id) }
        }
        return all.filter { seen.contains($0.id) }
    }
}

// MARK: - A single tappable citation

struct RGSourceRow: View {
    let source: RGSource
    var index: Int? = nil

    var body: some View {
        Group {
            if let url = source.url {
                Link(destination: url) { label }
            } else {
                label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var label: some View {
        HStack(alignment: .top, spacing: 10) {
            if let i = index {
                Text("\(i).")
                    .font(RGFont.label(11))
                    .foregroundColor(RGTheme.inkFaint)
                    .frame(width: 16, alignment: .trailing)
                    .padding(.top, 1)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(source.publisher)
                    .font(RGFont.label(10))
                    .foregroundColor(RGTheme.inkFaint)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(source.title)
                    .font(RGFont.heading(12.5))
                    .foregroundColor(RGTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(source.kind)
                    .font(RGFont.body(11))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(source.host)
                    .font(RGFont.body(11))
                    .foregroundColor(RGTheme.sageDeep)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            RGIconView(glyph: .chevronRight, side: 13, color: RGTheme.inkFaint)
                .padding(.top, 12)
        }
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

// MARK: - Sources block shown at the foot of a care card

struct RGCardSources: View {
    let card: RGCareCard

    private var sources: [RGSource] { RGSourceCatalog.sources(card.sourceIDs) }

    var body: some View {
        if sources.isEmpty {
            RGCard {
                Text("Sources")
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                Text("This card describes how Regrowth Clock's own tracking works. It makes no health or medical claim, so there is nothing to cite. Every card that does describe skin or hair carries its published sources here.")
                    .font(RGFont.body(12))
                    .foregroundColor(RGTheme.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            RGCard(accent: RGTheme.slateBlue) {
                HStack(alignment: .center, spacing: 8) {
                    RGIconView(glyph: .book, side: 16, color: RGTheme.slateBlue)
                    Text("Sources for this card")
                        .font(RGFont.heading(14))
                        .foregroundColor(RGTheme.ink)
                    Spacer(minLength: 4)
                    Text("\(sources.count)")
                        .font(RGFont.label(11))
                        .foregroundColor(RGTheme.inkFaint)
                }
                Text("This card is written from the published guidance below. Tap any entry to open the original page.")
                    .font(RGFont.body(11.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(Array(sources.enumerated()), id: \.element.id) { pair in
                    RGDivider()
                    RGSourceRow(source: pair.element, index: pair.offset + 1)
                }
            }
        }
    }
}

// MARK: - The full reference list

struct RGSourceListView: View {
    /// When set, only the sources cited by these cards are listed.
    var cards: [RGCareCard]? = nil
    var titleOverride: String? = nil

    private var listed: [RGSource] {
        if let cards = cards { return RGSourceCatalog.union(of: cards) }
        return RGSourceCatalog.all
    }

    private var publishers: [String] {
        var seen: Set<String> = []
        var out: [String] = []
        for s in listed where !seen.contains(s.publisher) {
            seen.insert(s.publisher)
            out.append(s.publisher)
        }
        return out
    }

    var body: some View {
        RGSubScreen(title: titleOverride ?? "Sources and references",
                    subtitle: "\(listed.count) cited sources from \(publishers.count) publishers") {

            RGCard(accent: RGTheme.slateBlue) {
                Text("Where the care cards come from")
                    .font(RGFont.heading(14))
                    .foregroundColor(RGTheme.ink)
                Text("Every care card in this app is written from published guidance by the organisations listed below: national health services, dermatology associations, medicine and device regulators, and peer-reviewed literature. Each card shows its own sources at the foot of the card, and every one of them is listed here too. Tap any entry to open the original page in your browser.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Regrowth Clock is not the author of this guidance and does not restate it as personal instruction. It is a grooming tracker, not a medical device.")
                    .font(RGFont.body(12.5))
                    .foregroundColor(RGTheme.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(publishers, id: \.self) { p in
                let items = listed.filter { $0.publisher == p }
                RGSectionHeader(text: p, detail: "\(items.count)")
                RGCard {
                    ForEach(Array(items.enumerated()), id: \.element.id) { pair in
                        if pair.offset > 0 { RGDivider() }
                        RGSourceRow(source: pair.element)
                    }
                }
            }

            RGDisclaimerNote(text: "Links open in your browser and lead to the publisher's own site. Regrowth Clock does not control those pages, and their content may be updated after this version of the app was published.")
        }
    }
}

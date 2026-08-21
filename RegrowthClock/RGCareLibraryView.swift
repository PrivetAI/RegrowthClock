import SwiftUI

struct RGCareLibraryView: View {
    @State private var query: String = ""
    @State private var category: RGCardCategory? = nil
    @FocusState private var searchFocused: Bool

    private var results: [RGCareCard] {
        var out = RGCareLibrary.search(query)
        if let c = category {
            out = out.filter { $0.category == c }
        }
        return out
    }

    var body: some View {
        RGSubScreen(title: "Care card library",
                    subtitle: "\(RGCareLibrary.all.count) authored entries across \(RGCardCategory.allCases.count) categories") {

            searchField

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    RGChoiceChip(text: "All", selected: category == nil) {
                        category = nil
                        searchFocused = false
                    }
                    ForEach(RGCardCategory.allCases) { c in
                        RGChoiceChip(text: c.title,
                                     selected: category == c,
                                     color: c.accent) {
                            category = (category == c) ? nil : c
                            searchFocused = false
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if results.isEmpty {
                RGEmptyState(title: "Nothing matches",
                             message: "No card contains that word. Try a shorter term, or clear the search and browse by category instead.",
                             glyph: .search,
                             actionTitle: "Clear search") {
                    query = ""
                    category = nil
                    searchFocused = false
                }
            } else {
                RGSectionHeader(text: category?.title ?? "All cards",
                                detail: "\(results.count)")
                ForEach(results) { card in
                    NavigationLink(destination: RGCareCardView(card: card)) {
                        RGCareCardRow(card: card)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            RGDisclaimerNote(text: "These cards are general information written for a general reader. They are not personal instructions and they do not replace advice from a qualified clinician.")
        }
    }

    private var searchField: some View {
        HStack(spacing: 9) {
            RGIconView(glyph: .search, side: 16, color: RGTheme.inkFaint)
            TextField("Search the library", text: $query)
                .font(RGFont.body(14))
                .foregroundColor(RGTheme.ink)
                .focused($searchFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            if !query.isEmpty {
                Button(action: {
                    query = ""
                    searchFocused = false
                }) {
                    RGIconView(glyph: .close, side: 14, color: RGTheme.inkFaint)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(RGTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(searchFocused ? RGTheme.sage : RGTheme.hairline, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .onTapGesture { searchFocused = true }
    }
}

import SwiftUI

enum RGRootSheet: Identifiable {
    case newSession(zoneID: String?, methodID: String?)
    case editSession(UUID)
    case newProduct
    case editProduct(UUID)

    var id: String {
        switch self {
        case .newSession(let z, let m):
            return "new-" + (z ?? "any") + "-" + (m ?? "any")
        case .editSession(let id):
            return "edit-" + id.uuidString
        case .newProduct:
            return "new-product"
        case .editProduct(let id):
            return "edit-product-" + id.uuidString
        }
    }
}

struct RGRootView: View {
    @ObservedObject var store: RGStore

    @State private var tab: Int = 0
    @State private var sheet: RGRootSheet? = nil
    @State private var showOnboarding: Bool = false

    var body: some View {
        ZStack {
            RGTheme.cream.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Group {
                    switch tab {
                    case 0:
                        NavigationView {
                            RGDueView(store: store,
                                      onLog: { z, m in sheet = .newSession(zoneID: z, methodID: m) },
                                      onOpenZones: { tab = 2 })
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView {
                            RGLogView(store: store,
                                      onNew: { sheet = .newSession(zoneID: nil, methodID: nil) },
                                      onEdit: { id in sheet = .editSession(id) },
                                      onNewProduct: { sheet = .newProduct },
                                      onEditProduct: { id in sheet = .editProduct(id) })
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView {
                            RGZonesView(store: store,
                                        onLog: { z, m in sheet = .newSession(zoneID: z, methodID: m) })
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    case 3:
                        NavigationView {
                            RGInsightsView(store: store)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView {
                            RGSettingsView(store: store,
                                           onReopenOnboarding: { showOnboarding = true })
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }

            if showOnboarding {
                RGOnboardingFlow(store: store) {
                    showOnboarding = false
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            if !store.settings.onboardingComplete {
                showOnboarding = true
            }
        }
        .sheet(item: $sheet) { which in
            switch which {
            case .newSession(let z, let m):
                RGSessionEditor(store: store,
                                presetZoneID: z,
                                presetMethodID: m,
                                editingID: nil) { sheet = nil }
            case .editSession(let id):
                RGSessionEditor(store: store,
                                presetZoneID: nil,
                                presetMethodID: nil,
                                editingID: id) { sheet = nil }
            case .newProduct:
                RGProductEditor(store: store, editingID: nil) { sheet = nil }
            case .editProduct(let id):
                RGProductEditor(store: store, editingID: id) { sheet = nil }
            }
        }
    }

    // MARK: Custom tab bar (never a TabView: .tabItem cannot render Canvas art)

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Due", .due)
            tabButton(1, "Log", .log)
            tabButton(2, "Zones", .zones)
            tabButton(3, "Insights", .insights)
            tabButton(4, "Settings", .settings)
        }
        .padding(.top, 7)
        .padding(.bottom, 2)
        .background(
            RGTheme.card
                .overlay(Rectangle().fill(RGTheme.hairline).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, _ label: String, _ glyph: RGGlyph) -> some View {
        let active = tab == index
        return Button(action: {
            if tab != index {
                tab = index
                RGHaptic.tap(store.settings.hapticsEnabled)
            }
        }) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    RGIconView(glyph: glyph, side: 21,
                               color: active ? RGTheme.sageDeep : RGTheme.ink.opacity(0.36))
                    if index == 0 && store.overdueCount > 0 {
                        Circle()
                            .fill(RGTheme.coral)
                            .frame(width: 7, height: 7)
                            .offset(x: 4, y: -2)
                    }
                    if index == 1 && store.productsNeedingReplacement > 0 {
                        Circle()
                            .fill(RGTheme.clay)
                            .frame(width: 7, height: 7)
                            .offset(x: 4, y: -2)
                    }
                }
                .frame(width: 27, height: 23)

                Text(label)
                    .font(RGFont.label(9.5))
                    .foregroundColor(active ? RGTheme.sageDeep : RGTheme.ink.opacity(0.42))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @State private var didBootstrap = false
    @State private var knowledgeSearchQuery = ""

    var body: some View {
        ZStack(alignment: .top) {
            tabContent
                .tint(Theme.Control.tabActiveTint)
                .accessibilityIdentifier("RootTabView")

            if let banner = environment.banner {
                VStack(spacing: 0) {
                    ToastBannerView(message: banner.message)
                }
                .padding(.horizontal, Theme.Layout.screenHorizontalInset)
                .padding(.top, Theme.Spacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.88), value: environment.banner?.id)
        .task {
            router.bannerPresenter = { message, duration in
                environment.showBanner(message, duration: duration)
            }
            await bootstrapIfNeeded()
        }
        .task(id: environment.preparedNotificationService?.pendingURL) {
            if let notificationService = environment.preparedNotificationService,
               let url = notificationService.pendingURL {
                router.open(url: url, modelContext: modelContext)
                notificationService.pendingURL = nil
            }
        }
        .sheet(item: contextualKnowledgePresentationBinding) { presentation in
            ContextualKnowledgeSheetView(articleID: presentation.articleID)
                .environmentObject(environment)
                .environmentObject(router)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Theme.Surface.app)
                .presentationCornerRadius(Theme.Radius.card)
        }
        .onOpenURL { url in
            router.open(url: url, modelContext: modelContext)
        }
    }

    // MARK: - Tab content + aligned bottom bar

    private var tabContent: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Oggi", systemImage: "house.fill")
            }
            .tag(RootTab.oggi)

            NavigationStack(path: $router.fermentationsPath) {
                FermentationsView()
                    .navigationDestination(for: FermentationsRoute.self) { route in
                        switch route {
                        case .breadHub:        BreadHubView()
                        case .kefirHub:        KefirHubView()
                        case .bakesList:       BakesView()
                        case .formulaList:     FormulaListView()
                        case .starterList:     StarterView()
                        case let .bake(id):    BakeLookupView(id: id)
                        case let .formula(id): FormulaLookupView(id: id)
                        case let .starter(id): StarterLookupView(id: id)
                        case .kefirBatch:      KefirBatchLookupView(id: route.kefirBatchID)
                        }
                    }
            }
            .tabItem {
                Label("Batch", systemImage: "square.grid.2x2.fill")
            }
            .tag(RootTab.fermentations)

            NavigationStack(path: $router.knowledgePath) {
                KnowledgeView(
                    library: environment.knowledgeLibrary,
                    query: $knowledgeSearchQuery
                )
                    .navigationDestination(for: KnowledgeRoute.self) { route in
                        switch route {
                        case let .article(id): KnowledgeLookupView(id: id)
                        }
                    }
            }
            .tabItem {
                Label("Guide", systemImage: "book.fill")
            }
            .tag(RootTab.knowledge)
        }
    }

    private var contextualKnowledgePresentationBinding: Binding<ContextualKnowledgePresentation?> {
        Binding(
            get: { router.contextualKnowledgePresentation },
            set: { router.contextualKnowledgePresentation = $0 }
        )
    }

    // MARK: - Bootstrap

    @MainActor
    private func bootstrapIfNeeded() async {
        guard didBootstrap == false else { return }
        didBootstrap = true

        if AppLaunchOptions.shouldSeedSampleData {
            do {
                try SeedDataLoader.ensureSeedData(in: modelContext, scenario: .current())
            } catch {
                assertionFailure("Seed data failed: \(error)")
            }
        }

        do {
            try SeedDataLoader.ensureSystemFormulas(in: modelContext)
        } catch {
            assertionFailure("System formula seeding failed: \(error)")
        }

        environment.knowledgeLibrary.preloadIfNeeded()

        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }

        let appSettings = loadOrCreateAppSettings()
        let notificationService = environment.prepareNotificationServiceIfNeeded()

        if let route = AppLaunchOptions.pendingNotificationRoute,
           let url = URL(string: route) {
            notificationService.pendingURL = url
        }

        guard AppLaunchOptions.shouldSuppressNotifications == false else { return }

        scheduleNotificationBootstrap(notificationService: notificationService, appSettings: appSettings)
    }

    @MainActor
    private func loadOrCreateAppSettings() -> AppSettings {
        if let existing = try? modelContext.fetch(FetchDescriptor<AppSettings>()).first {
            return existing
        }
        let settings = AppSettings()
        modelContext.insert(settings)
        try? modelContext.save()
        return settings
    }

    @MainActor
    private func scheduleNotificationBootstrap(
        notificationService: NotificationService,
        appSettings: AppSettings
    ) {
        let needsLaunchSync = appSettings.lastNotificationSync == nil
        let needsAuthorizationPrompt = appSettings.hasRequestedNotificationPermission == false
        guard needsLaunchSync || needsAuthorizationPrompt else { return }

        Task(priority: .utility) {
            let authorizationState = await notificationService.requestAuthorizationIfNeeded(settings: appSettings)
            if authorizationState == .authorized {
                await notificationService.resyncAll(using: modelContext)
                appSettings.lastNotificationSync = .now
                try? modelContext.save()
            }
            if authorizationState == .denied {
                if appSettings.lastNotificationSync == nil {
                    appSettings.lastNotificationSync = .now
                    try? modelContext.save()
                }
                router.showNotificationsDisabledBanner()
            }
        }
    }
}

// MARK: - Lookup helpers

private struct BakeLookupView: View {
    let id: UUID

    @Query private var results: [Bake]

    init(id: UUID) {
        self.id = id
        _results = Query(filter: #Predicate<Bake> { $0.id == id })
    }

    private var bake: Bake? { results.first }

    var body: some View {
        if let bake {
            BakeDetailView(bake: bake)
        } else {
            ContentUnavailableView("Impasto non trovato", systemImage: "exclamationmark.triangle")
        }
    }
}

@MainActor
private struct FormulaLookupView: View {
    let id: UUID

    var body: some View {
        FormulaDetailView(formulaID: id)
    }
}

private struct StarterLookupView: View {
    let id: UUID

    @Query private var results: [Starter]

    init(id: UUID) {
        self.id = id
        _results = Query(filter: #Predicate<Starter> { $0.id == id })
    }

    private var starter: Starter? { results.first }

    var body: some View {
        if let starter {
            StarterDetailView(starter: starter)
        } else {
            ContentUnavailableView("Starter non trovato", systemImage: "exclamationmark.triangle")
        }
    }
}

private struct KnowledgeLookupView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let id: String
    var body: some View {
        Group {
            if let item = environment.knowledgeLibrary.item(id: id) { KnowledgeDetailView(item: item) }
            else { ContentUnavailableView("Guida non trovata", systemImage: "book.closed") }
        }
        .task { environment.knowledgeLibrary.loadIfNeeded() }
    }
}

private struct ContextualKnowledgeSheetView: View {
    let articleID: String

    var body: some View {
        KnowledgeLookupView(id: articleID)
            .id(articleID)
            .tint(Theme.Control.primaryFill)
            .environment(\.knowledgePresentationContext, .contextualSheet)
    }
}

private struct KefirBatchLookupView: View {
    let id: UUID

    @Query private var results: [KefirBatch]

    init(id: UUID) {
        self.id = id
        _results = Query(filter: #Predicate<KefirBatch> { $0.id == id })
    }

    private var batch: KefirBatch? { results.first }

    var body: some View {
        if let batch {
            KefirBatchDetailView(batch: batch)
        } else {
            ContentUnavailableView("Batch non trovato", systemImage: "exclamationmark.triangle")
        }
    }
}

private extension FermentationsRoute {
    var kefirBatchID: UUID {
        guard case .kefirBatch(let id) = self else { preconditionFailure("Expected kefir batch route") }
        return id
    }
}

#Preview("Levain App Shell") {
    RootTabView()
        .environmentObject(AppRouter())
        .environmentObject(AppEnvironment())
        .modelContainer(ModelContainerFactory.makePreviewContainer())
}

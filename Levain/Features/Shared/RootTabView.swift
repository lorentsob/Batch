import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @State private var didBootstrap = false
    @State private var hasPresentedTabs = false
    @State private var selectedTab: RootTab = .today
    @State private var bakesPath: [BakesRoute] = []
    @State private var starterPath: [StarterRoute] = []
    @State private var knowledgePath: [KnowledgeRoute] = []
    @State private var showingKnowledge = false

    var body: some View {
        let localPresentation = PresentationState(
            selectedTab: selectedTab,
            bakesPath: bakesPath,
            starterPath: starterPath,
            knowledgePath: knowledgePath,
            showingKnowledge: showingKnowledge
        )
        let routerPresentation = PresentationState(
            selectedTab: router.selectedTab,
            bakesPath: router.bakesPath,
            starterPath: router.starterPath,
            knowledgePath: router.knowledgePath,
            showingKnowledge: router.showingKnowledge
        )

        return Group {
            if hasPresentedTabs {
                tabs
            } else {
                RootTabLaunchView()
            }
        }
        .tint(Theme.accent)
        .accessibilityIdentifier("RootTabView")
        .task {
            syncFromRouter()
            await presentTabsIfNeeded()
            await bootstrapIfNeeded()
        }
        .task(id: environment.preparedNotificationService?.pendingURL) {
            if let notificationService = environment.preparedNotificationService,
               let url = notificationService.pendingURL {
                router.open(url: url)
                notificationService.pendingURL = nil
            }
        }
        .onOpenURL { url in
            router.open(url: url)
        }
        .onChange(of: localPresentation) {
            if routerPresentation != localPresentation {
                apply(presentation: localPresentation, to: router)
            }
        }
        .onChange(of: routerPresentation) {
            if localPresentation != routerPresentation {
                apply(presentation: routerPresentation)
            }
        }
        .sheet(isPresented: $showingKnowledge) {
            NavigationStack(path: $knowledgePath) {
                KnowledgeView()
                    .navigationDestination(for: KnowledgeRoute.self) { route in
                        switch route {
                        case let .article(id):
                            KnowledgeLookupView(id: id)
                        }
                    }
            }
        }
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            DeferredTabContent(isActive: selectedTab == .today) {
                TodayView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(RootTab.today)

            DeferredTabContent(isActive: selectedTab == .bakes) {
                NavigationStack(path: $bakesPath) {
                    BakesView()
                        .navigationDestination(for: BakesRoute.self) { route in
                            switch route {
                            case let .bake(id):
                                BakeLookupView(id: id)
                            case let .formula(id):
                                FormulaLookupView(id: id)
                            case .formulaList:
                                FormulaListView()
                            }
                        }
                }
            }
            .tabItem {
                Label("Impasti", systemImage: "fork.knife")
            }
            .tag(RootTab.bakes)

            DeferredTabContent(isActive: selectedTab == .starter) {
                NavigationStack(path: $starterPath) {
                    StarterView()
                        .navigationDestination(for: StarterRoute.self) { route in
                            switch route {
                            case let .detail(id):
                                StarterLookupView(id: id)
                            }
                        }
                }
            }
            .tabItem {
                Label("Starter", systemImage: "drop.fill")
            }
            .tag(RootTab.starter)

        }
    }

    private func presentTabsIfNeeded() async {
        guard hasPresentedTabs == false else { return }
        await Task.yield()
        hasPresentedTabs = true
    }

    private func bootstrapIfNeeded() async {
        guard didBootstrap == false else { return }
        didBootstrap = true

        // Seed sample data only when explicitly requested via launch options
        // (e.g. UI test seeded mode). Normal first launch must NOT insert demo
        // content automatically — real empty states must be clearly exercisable.
        if AppLaunchOptions.shouldSeedSampleData {
            do {
                try SeedDataLoader.ensureSeedData(in: modelContext)
            } catch {
                assertionFailure("Seed data failed: \(error)")
            }
        }

        environment.knowledgeLibrary.preloadIfNeeded()

        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Skip notification side-effects in automation to prevent permission
        // prompts from interfering with UI test flows.
        guard AppLaunchOptions.shouldSuppressNotifications == false else { return }

        await Task.yield()

        let notificationService = environment.prepareNotificationServiceIfNeeded()
        let appSettings = loadAppSettings()
        await notificationService.requestAuthorizationIfNeeded(settings: appSettings)
        await notificationService.resyncAll(using: modelContext)
        appSettings?.lastNotificationSync = .now
        try? modelContext.save()
    }

    private func loadAppSettings() -> AppSettings? {
        try? modelContext.fetch(FetchDescriptor<AppSettings>()).first
    }

    private func syncFromRouter() {
        apply(
            presentation: PresentationState(
                selectedTab: router.selectedTab,
                bakesPath: router.bakesPath,
                starterPath: router.starterPath,
                knowledgePath: router.knowledgePath,
                showingKnowledge: router.showingKnowledge
            )
        )
    }

    private func apply(presentation: PresentationState) {
        selectedTab = presentation.selectedTab
        bakesPath = presentation.bakesPath
        starterPath = presentation.starterPath
        knowledgePath = presentation.knowledgePath
        showingKnowledge = presentation.showingKnowledge
    }

    private func apply(presentation: PresentationState, to router: AppRouter) {
        router.selectedTab = presentation.selectedTab
        router.bakesPath = presentation.bakesPath
        router.starterPath = presentation.starterPath
        router.knowledgePath = presentation.knowledgePath
        router.showingKnowledge = presentation.showingKnowledge
    }
}

private struct RootTabLaunchView: View {
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("Preparo la Home")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)

                ProgressView()
                    .tint(Theme.accent)
            }
            .padding(28)
        }
        .accessibilityIdentifier("RootTabLaunchView")
    }
}

private struct DeferredTabContent<Content: View>: View {
    let isActive: Bool
    let content: () -> Content

    @State private var hasLoaded = false

    var body: some View {
        Group {
            if hasLoaded || isActive {
                content()
            } else {
                Color.clear
            }
        }
        .task(id: isActive) {
            if isActive {
                hasLoaded = true
            }
        }
    }
}

private struct PresentationState: Equatable {
    let selectedTab: RootTab
    let bakesPath: [BakesRoute]
    let starterPath: [StarterRoute]
    let knowledgePath: [KnowledgeRoute]
    let showingKnowledge: Bool
}

private struct BakeLookupView: View {
    @Environment(\.modelContext) private var modelContext

    let id: UUID

    @State private var bake: Bake?

    var body: some View {
        Group {
            if let bake {
                BakeDetailView(bake: bake)
            } else {
                ContentUnavailableView("Bake non trovato", systemImage: "exclamationmark.triangle")
            }
        }
        .task(id: id) {
            bake = load()
        }
    }

    private func load() -> Bake? {
        let descriptor = FetchDescriptor<Bake>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
}

private struct FormulaLookupView: View {
    @Environment(\.modelContext) private var modelContext

    let id: UUID

    @State private var formula: RecipeFormula?

    var body: some View {
        Group {
            if let formula {
                FormulaDetailView(formula: formula)
            } else {
                ContentUnavailableView("Formula non trovata", systemImage: "exclamationmark.triangle")
            }
        }
        .task(id: id) {
            formula = load()
        }
    }

    private func load() -> RecipeFormula? {
        let descriptor = FetchDescriptor<RecipeFormula>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
}

private struct StarterLookupView: View {
    @Environment(\.modelContext) private var modelContext

    let id: UUID

    @State private var starter: Starter?

    var body: some View {
        Group {
            if let starter {
                StarterDetailView(starter: starter)
            } else {
                ContentUnavailableView("Starter non trovato", systemImage: "exclamationmark.triangle")
            }
        }
        .task(id: id) {
            starter = load()
        }
    }

    private func load() -> Starter? {
        let descriptor = FetchDescriptor<Starter>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }
}

private struct KnowledgeLookupView: View {
    @EnvironmentObject private var environment: AppEnvironment

    let id: String

    var body: some View {
        Group {
            if let item = environment.knowledgeLibrary.item(id: id) {
                KnowledgeDetailView(item: item)
            } else {
                ContentUnavailableView("Articolo non trovato", systemImage: "book.closed")
            }
        }
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
    }
}

#Preview("Levain App Shell") {
    RootTabView()
        .environmentObject(AppRouter())
        .environmentObject(AppEnvironment())
        .modelContainer(ModelContainerFactory.makePreviewContainer())
}

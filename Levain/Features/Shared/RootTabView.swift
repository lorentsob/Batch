import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query private var settings: [AppSettings]

    @State private var didBootstrap = false

    var body: some View {
        TabView(selection: $router.selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(RootTab.today)

                NavigationStack(path: $router.bakesPath) {
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
                .tabItem {
                    Label("Impasti", systemImage: "fork.knife")
                }
                .tag(RootTab.bakes)

                NavigationStack(path: $router.starterPath) {
                    StarterView()
                        .navigationDestination(for: StarterRoute.self) { route in
                            switch route {
                            case let .detail(id):
                                StarterLookupView(id: id)
                            }
                        }
                }
                .tabItem {
                    Label("Starter", systemImage: "drop.fill")
                }
                .tag(RootTab.starter)

        }
        .tint(Theme.accent)
        .accessibilityIdentifier("RootTabView")
        .task {
            await bootstrapIfNeeded()
        }
        .task(id: environment.notificationService.pendingURL) {
            if let url = environment.notificationService.pendingURL {
                router.open(url: url)
                environment.notificationService.pendingURL = nil
            }
        }
        .onOpenURL { url in
            router.open(url: url)
        }
        .sheet(isPresented: $router.showingKnowledge) {
            NavigationStack(path: $router.knowledgePath) {
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

        environment.knowledgeLibrary.loadIfNeeded()

        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Skip notification side-effects in automation to prevent permission
        // prompts from interfering with UI test flows.
        guard AppLaunchOptions.shouldSuppressNotifications == false else { return }

        let appSettings = settings.first ?? (try? modelContext.fetch(FetchDescriptor<AppSettings>()).first)
        await environment.notificationService.requestAuthorizationIfNeeded(settings: appSettings)
        await environment.notificationService.resyncAll(using: modelContext)
        appSettings?.lastNotificationSync = .now
        try? modelContext.save()
    }
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

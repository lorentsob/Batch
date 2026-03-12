import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @State private var didBootstrap = false

    var body: some View {
        ZStack(alignment: .top) {
            tabs
                .tint(Theme.accent)
                .accessibilityIdentifier("RootTabView")

            if let banner = environment.banner {
                VStack(spacing: 0) {
                    ToastBannerView(message: banner.message)
                    Color.clear
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier("ToastBannerProbe")
                        .accessibilityLabel(banner.message)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
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
        .onOpenURL { url in
            router.open(url: url, modelContext: modelContext)
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

    private var tabs: some View {
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
                Image("navbar-bake")
                    .renderingMode(.template)
                Text("Impasti")
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
                Image("navbar-starter")
                    .renderingMode(.template)
                Text("Starter")
            }
            .tag(RootTab.starter)
        }
        .tint(Theme.Control.tabActiveTint)
        .toolbarBackground(Theme.Control.tabBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

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

        environment.knowledgeLibrary.preloadIfNeeded()

        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        let appSettings = loadOrCreateAppSettings()
        let notificationService = environment.prepareNotificationServiceIfNeeded()

        if let route = AppLaunchOptions.pendingNotificationRoute,
           let url = URL(string: route) {
            notificationService.pendingURL = url
        }

        guard AppLaunchOptions.shouldSuppressNotifications == false else { return }

        scheduleNotificationBootstrap(
            notificationService: notificationService,
            appSettings: appSettings
        )
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
                // Mark the bootstrap as handled so a denied state does not force
                // another startup-time notification pass on every launch.
                if appSettings.lastNotificationSync == nil {
                    appSettings.lastNotificationSync = .now
                    try? modelContext.save()
                }
                router.showNotificationsDisabledBanner()
            }
        }
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
                ContentUnavailableView("Ricetta non trovata", systemImage: "exclamationmark.triangle")
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
                ContentUnavailableView("Guida non trovata", systemImage: "book.closed")
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

import Foundation
import SwiftData
import Testing
@testable import Levain

@Suite("App Router Tests")
@MainActor
struct AppRouterTests {
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([
            Starter.self,
            StarterRefresh.self,
            RecipeFormula.self,
            Bake.self,
            BakeStep.self,
            AppSettings.self
        ])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }
    
    @Test("AppRouter parses bake deep link correctly")
    func testBakeDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: AppRouter.DeepLink.bake(id: id))!
        
        router.open(url: url)
        
        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.count == 1)
        if case .bake(let parsedID) = router.bakesPath.first {
            #expect(parsedID == id)
        } else {
            Issue.record("Expected bake route, got something else")
        }
    }
    
    @Test("AppRouter parses starter deep link correctly")
    func testStarterDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: AppRouter.DeepLink.starter(id: id))!
        
        router.open(url: url)
        
        #expect(router.selectedTab == .starter)
        #expect(router.starterPath.count == 1)
        if case .detail(let parsedID) = router.starterPath.first {
            #expect(parsedID == id)
        } else {
            Issue.record("Expected starter detail route, got something else")
        }
    }
    
    @Test("AppRouter parses knowledge deep link correctly")
    func testKnowledgeDeepLink() {
        let router = AppRouter()
        let url = URL(string: AppRouter.DeepLink.knowledge(id: "fermentation-guide"))!
        
        router.open(url: url)
        
        #expect(router.selectedTab == .today)
        #expect(router.showingKnowledge == true)
        #expect(router.knowledgePath.count == 1)
        if case .article(let parsedID) = router.knowledgePath.first {
            #expect(parsedID == "fermentation-guide")
        } else {
            Issue.record("Expected knowledge article route, got something else")
        }
    }
    
    @Test("AppRouter ignores invalid schemes")
    func testInvalidScheme() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: "http://bake/\(id.uuidString)")!
        
        router.open(url: url)
        
        #expect(router.selectedTab == .today) // default tab
        #expect(router.bakesPath.isEmpty)
    }

    @Test("AppRouter silently ignores unknown host — safe fallback for missing routes")
    func testUnknownHostNoOp() {
        let router = AppRouter()
        let url = URL(string: "levain://unknown-entity/some-id")!

        router.open(url: url)

        // State must remain at default — no crash, no navigation
        #expect(router.selectedTab == .today)
        #expect(router.bakesPath.isEmpty)
        #expect(router.starterPath.isEmpty)
        #expect(router.knowledgePath.isEmpty)
    }

    @Test("AppRouter parses formula deep link correctly")
    func testFormulaDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: "levain://formula/\(id.uuidString)")!

        router.open(url: url)

        // Formula host resolves to bakes tab via openFormula
        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.count == 1)
        if case .formula(let parsedID) = router.bakesPath.first {
            #expect(parsedID == id)
        } else {
            Issue.record("Expected formula route")
        }
    }

    @Test("AppRouter ignores malformed UUID in bake URL — missing entity fails safely")
    func testMalformedUUIDIgnored() {
        let router = AppRouter()
        let url = URL(string: "levain://bake/not-a-valid-uuid")!

        router.open(url: url)

        // Malformed UUID must not change navigation state
        #expect(router.selectedTab == .today)
        #expect(router.bakesPath.isEmpty)
    }

    @Test("Notification navigation falls back to bakes tab when bake no longer exists")
    func testNotificationFallbackForMissingBake() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        router.navigateFromNotificationPayload(bakeId: UUID(), stepId: UUID(), modelContext: context)

        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.isEmpty)
        #expect(banner == "Questo bake non è più disponibile")
        #expect(duration == 8)
    }

    @Test("Notification navigation opens bake detail when step is stale")
    func testNotificationFallbackForMissingStep() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        let bake = DomainFixtures.makeBake(name: "Tracked bake")
        context.insert(bake)
        try context.save()

        router.navigateFromNotificationPayload(bakeId: bake.id, stepId: UUID(), modelContext: context)

        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.count == 1)
        if case .bake(let parsedID) = router.bakesPath.first {
            #expect(parsedID == bake.id)
        } else {
            Issue.record("Expected bake route after stale step fallback")
        }
        #expect(banner == "Questa fase non è più disponibile")
        #expect(duration == 5)
    }

    @Test("Notification navigation falls back to starter tab when starter is missing")
    func testNotificationFallbackForMissingStarter() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        router.navigateFromNotificationPayload(starterId: UUID(), modelContext: context)

        #expect(router.selectedTab == .starter)
        #expect(router.starterPath.isEmpty)
        #expect(banner == "Starter non trovato")
        #expect(duration == 8)
    }

    @Test("Notification navigation opens cancelled bake with an informational banner")
    func testNotificationFallbackForCancelledBake() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        let bake = DomainFixtures.makeBake(name: "Cancelled bake")
        bake.isCancelled = true
        context.insert(bake)
        try context.save()

        router.navigateFromNotificationPayload(
            bakeId: bake.id,
            stepId: bake.activeStep?.id,
            modelContext: context
        )

        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.count == 1)
        if case .bake(let parsedID) = router.bakesPath.first {
            #expect(parsedID == bake.id)
        } else {
            Issue.record("Expected bake route for cancelled bake fallback")
        }
        #expect(banner == "Questo bake è stato annullato")
        #expect(duration == 5)
    }

    @Test("Notification navigation opens completed bake with an informational banner")
    func testNotificationFallbackForCompletedBake() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        let bake = DomainFixtures.makeBake(name: "Completed bake")
        bake.sortedSteps.forEach { $0.complete(at: .fixedNow) }
        context.insert(bake)
        try context.save()

        router.navigateFromNotificationPayload(
            bakeId: bake.id,
            stepId: bake.activeStep?.id,
            modelContext: context
        )

        #expect(router.selectedTab == .bakes)
        #expect(router.bakesPath.count == 1)
        #expect(banner == "Questo bake è già completato")
        #expect(duration == 5)
    }

    @Test("Router can surface the notifications-disabled banner without leaving Home")
    func testNotificationsDisabledBanner() {
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        router.showNotificationsDisabledBanner()

        #expect(router.selectedTab == .today)
        #expect(banner == "Attiva le notifiche per ricevere i promemoria")
        #expect(duration == 8)
    }
}

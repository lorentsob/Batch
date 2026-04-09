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
            AppSettings.self,
            KefirBatch.self
        ])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    private func expectFermentationsPath(
        _ router: AppRouter,
        equals expectedRoutes: [FermentationsRoute]
    ) {
        #expect(router.selectedTab == .fermentations)
        #expect(router.fermentationsPath == expectedRoutes)
    }

    @Test("AppRouter parses bake deep link correctly")
    func testBakeDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: AppRouter.DeepLink.bake(id: id))!

        router.open(url: url)

        expectFermentationsPath(router, equals: [.bakesList, .bake(id)])
        if case .bake(let parsedID) = router.fermentationsPath.last {
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

        expectFermentationsPath(router, equals: [.starterList, .starter(id)])
        if case .starter(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == id)
        } else {
            Issue.record("Expected starter route, got something else")
        }
    }

    @Test("AppRouter parses knowledge deep link correctly")
    func testKnowledgeDeepLink() {
        let router = AppRouter()
        let url = URL(string: AppRouter.DeepLink.knowledge(id: "fermentation-guide"))!

        router.open(url: url)

        #expect(router.selectedTab == .knowledge)
        #expect(router.knowledgePath.count == 1)
        if case .article(let parsedID) = router.knowledgePath.first {
            #expect(parsedID == "fermentation-guide")
        } else {
            Issue.record("Expected knowledge article route, got something else")
        }
        #expect(router.contextualKnowledgePresentation == nil)
    }

    @Test("AppRouter opens contextual knowledge article without leaving current tab")
    func testContextualKnowledgeArticlePreservesCurrentTab() {
        let router = AppRouter()

        router.selectedTab = .fermentations
        router.openKnowledge("appretto-guide")

        #expect(router.selectedTab == .fermentations)
        #expect(router.contextualKnowledgePresentation?.articleID == "appretto-guide")
        #expect(router.knowledgePath.isEmpty)
    }

    @Test("AppRouter replaces contextual knowledge article when a second linked guide opens")
    func testContextualKnowledgeFlowReplacesPresentedArticle() {
        let router = AppRouter()

        router.selectedTab = .fermentations
        router.openKnowledge("appretto-guide")
        router.openKnowledge("pieghe-guide")

        #expect(router.selectedTab == .fermentations)
        #expect(router.contextualKnowledgePresentation?.articleID == "pieghe-guide")
    }

    @Test("AppRouter opens linked guide as modal even when already browsing inside knowledge tab")
    func testKnowledgeTabLinkUsesContextualPresentation() {
        let router = AppRouter()

        router.selectedTab = .knowledge
        router.knowledgePath = [.article("bulk-fermentation-basics")]
        router.openKnowledge("pieghe-guide")

        #expect(router.selectedTab == .knowledge)
        #expect(router.knowledgePath == [.article("bulk-fermentation-basics")])
        #expect(router.contextualKnowledgePresentation?.articleID == "pieghe-guide")
    }

    @Test("AppRouter ignores invalid schemes")
    func testInvalidScheme() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: "http://bake/\(id.uuidString)")!

        router.open(url: url)

        #expect(router.selectedTab == .oggi) // default tab
        #expect(router.fermentationsPath.isEmpty)
    }

    @Test("AppRouter silently ignores unknown host — safe fallback for missing routes")
    func testUnknownHostNoOp() {
        let router = AppRouter()
        let url = URL(string: "levain://unknown-entity/some-id")!

        router.open(url: url)

        // State must remain at default — no crash, no navigation
        #expect(router.selectedTab == .oggi)
        #expect(router.fermentationsPath.isEmpty)
        #expect(router.knowledgePath.isEmpty)
    }

    @Test("AppRouter parses formula deep link correctly")
    func testFormulaDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: "levain://formula/\(id.uuidString)")!

        router.open(url: url)

        expectFermentationsPath(router, equals: [.formulaList, .formula(id)])
        if case .formula(let parsedID) = router.fermentationsPath.last {
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
        #expect(router.selectedTab == .oggi)
        #expect(router.fermentationsPath.isEmpty)
    }

    @Test("Notification navigation falls back to fermentations tab when bake no longer exists")
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

        #expect(router.selectedTab == .fermentations)
        #expect(router.fermentationsPath.isEmpty)
        #expect(banner == "Questo impasto non è più disponibile")
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

        expectFermentationsPath(router, equals: [.bakesList, .bake(bake.id)])
        if case .bake(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == bake.id)
        } else {
            Issue.record("Expected bake route after stale step fallback")
        }
        #expect(banner == "Questa fase non è più disponibile")
        #expect(duration == 5)
    }

    @Test("Notification navigation falls back to fermentations tab when starter is missing")
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

        #expect(router.selectedTab == .fermentations)
        #expect(router.fermentationsPath.isEmpty)
        #expect(banner == "Starter non trovato")
        #expect(duration == 8)
    }

    @Test("Notification navigation falls back to fermentations tab when kefir batch is missing")
    func testNotificationFallbackForMissingKefirBatch() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        router.navigateFromNotificationPayload(kefirBatchId: UUID(), modelContext: context)

        #expect(router.selectedTab == .fermentations)
        #expect(router.fermentationsPath.isEmpty)
        #expect(banner == "Batch non trovato")
        #expect(duration == 8)
    }

    @Test("Notification navigation opens kefir batch detail when batch exists")
    func testNotificationRouteOpensKefirBatch() throws {
        let context = try makeInMemoryContext()
        let router = AppRouter()
        let batch = DomainFixtures.makeKefirBatch(name: "Batch route test")
        context.insert(batch)
        try context.save()

        router.navigateFromNotificationPayload(kefirBatchId: batch.id, modelContext: context)

        expectFermentationsPath(router, equals: [.kefirHub, .kefirBatch(batch.id)])
        if case .kefirBatch(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == batch.id)
        } else {
            Issue.record("Expected kefir batch route after notification navigation")
        }
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

        expectFermentationsPath(router, equals: [.bakesList, .bake(bake.id)])
        if case .bake(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == bake.id)
        } else {
            Issue.record("Expected bake route for cancelled bake fallback")
        }
        #expect(banner == "Questo impasto è stato annullato")
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

        expectFermentationsPath(router, equals: [.bakesList, .bake(bake.id)])
        #expect(banner == "Questo impasto è già completato")
        #expect(duration == 5)
    }

    @Test("AppRouter parses kefir batch deep link correctly — Phase 19 hook")
    func testKefirBatchDeepLink() {
        let router = AppRouter()
        let id = UUID()
        let url = URL(string: AppRouter.DeepLink.kefirBatch(id: id))!

        router.open(url: url)

        expectFermentationsPath(router, equals: [.kefirHub, .kefirBatch(id)])
        if case .kefirBatch(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == id)
        } else {
            Issue.record("Expected kefirBatch route, got something else")
        }
    }

    @Test("Router direct-object routing from Oggi bypasses Preparazioni hub — no hub traversal")
    func testOggiDirectObjectRoutingBypassesHub() {
        let router = AppRouter()
        let bakeID = UUID()

        router.openBake(bakeID)

        expectFermentationsPath(router, equals: [.bakesList, .bake(bakeID)])
        if case .bake(let parsedID) = router.fermentationsPath.last {
            #expect(parsedID == bakeID)
        } else {
            Issue.record("Expected direct bake route without hub prefix")
        }
        let hasHubStep = router.fermentationsPath.contains(.breadHub) || router.fermentationsPath.contains(.kefirHub)
        #expect(hasHubStep == false)
    }

    @Test("Router can surface the notifications-disabled banner without leaving Oggi")
    func testNotificationsDisabledBanner() {
        let router = AppRouter()
        var banner: String?
        var duration: TimeInterval?
        router.bannerPresenter = { message, bannerDuration in
            banner = message
            duration = bannerDuration
        }

        router.showNotificationsDisabledBanner()

        #expect(router.selectedTab == .oggi)
        #expect(banner == "Attiva le notifiche per ricevere i promemoria")
        #expect(duration == 8)
    }
}

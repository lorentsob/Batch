import Foundation
import Testing
@testable import Levain

@Suite("App Router Tests")
@MainActor
struct AppRouterTests {
    
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
        
        #expect(router.selectedTab == .knowledge)
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
}

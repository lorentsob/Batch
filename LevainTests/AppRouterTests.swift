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
}

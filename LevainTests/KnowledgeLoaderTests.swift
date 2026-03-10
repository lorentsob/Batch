import XCTest
@testable import Levain

final class KnowledgeLoaderTests: XCTestCase {
    
    func testBundledKnowledgeDecodesSuccessfully() throws {
        // Assert that the real app bundle contains the file and it decodes
        let bundle = Bundle.main
        let url = try XCTUnwrap(bundle.url(forResource: "knowledge", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let items = try decoder.decode([KnowledgeItem].self, from: data)
        
        XCTAssertFalse(items.isEmpty, "Bundled knowledge JSON should not be empty")
        
        // Verify a known item exists to ensure schema is correct
        let starterBasics = items.first { $0.id == "starter-basics" }
        XCTAssertNotNil(starterBasics)
        XCTAssertEqual(starterBasics?.category, .starter)
        XCTAssertTrue(starterBasics?.relatedStepTypes.contains(BakeStepType.starterRefresh.rawValue) ?? false)
    }
    
    @MainActor
    func testKnowledgeLibraryLoadsContent() {
        let library = KnowledgeLibrary()
        XCTAssertTrue(library.items.isEmpty)
        
        library.loadIfNeeded()
        XCTAssertFalse(library.items.isEmpty)
        
        // Second load shouldn't duplicate
        let count = library.items.count
        library.loadIfNeeded()
        XCTAssertEqual(library.items.count, count)
    }
}

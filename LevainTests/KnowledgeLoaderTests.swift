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
        XCTAssertTrue(starterBasics?.aliases.contains("lievito madre") ?? false)
        XCTAssertTrue(starterBasics?.relatedStepTypes.contains(BakeStepType.starterRefresh.rawValue) ?? false)

        let apprettoGuide = items.first { $0.id == "appretto-guide" }
        XCTAssertNotNil(apprettoGuide)
        XCTAssertEqual(apprettoGuide?.category, .fermentation)
        XCTAssertTrue(apprettoGuide?.aliases.contains("final proof") ?? false)
    }
    
    @MainActor
    func testKnowledgeLibraryLoadsContent() {
        let library = KnowledgeLibrary()
        XCTAssertTrue(library.items.isEmpty)
        
        library.loadIfNeeded()
        XCTAssertFalse(library.items.isEmpty)
        XCTAssertEqual(library.item(matchingGlossaryTerm: "prima lievitazione")?.id, "bulk-fermentation-basics")
        XCTAssertEqual(library.item(matchingGlossaryTerm: "second rise")?.id, "appretto-guide")
        XCTAssertEqual(library.item(matchingGlossaryTerm: "stretch & fold")?.id, "pieghe-guide")
        
        // Second load shouldn't duplicate
        let count = library.items.count
        library.loadIfNeeded()
        XCTAssertEqual(library.items.count, count)
    }
}

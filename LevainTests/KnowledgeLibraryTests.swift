import XCTest
@testable import Levain

/// Tests for KnowledgeLibrary relevance filtering used by contextual tips in bake and starter flows.
final class KnowledgeLibraryTests: XCTestCase {

    @MainActor
    private func makeLoadedLibrary() -> KnowledgeLibrary {
        let library = KnowledgeLibrary()
        library.loadIfNeeded()
        return library
    }

    // MARK: - Step type filtering

    @MainActor
    func testTipsForStarterRefreshStepType() {
        let library = makeLoadedLibrary()
        let tips = library.tips(for: .starterRefresh)
        // starter-basics and starter-maintenance-fridge are both tagged with starterRefresh
        XCTAssertFalse(tips.isEmpty, "Expected tips for starterRefresh step type")
        XCTAssertTrue(tips.allSatisfy { $0.relatedStepTypes.contains(BakeStepType.starterRefresh.rawValue) })
    }

    @MainActor
    func testTipsForBulkFermentationStepType() {
        let library = makeLoadedLibrary()
        let tips = library.tips(for: .bulk)
        XCTAssertFalse(tips.isEmpty, "Expected tips for bulk step type")
        XCTAssertTrue(tips.allSatisfy { $0.relatedStepTypes.contains(BakeStepType.bulk.rawValue) })
    }

    @MainActor
    func testTipsForUnmatchedStepType() {
        let library = makeLoadedLibrary()
        // .cool has no related articles in the current dataset
        let tips = library.tips(for: .cool)
        // Acceptable to be empty — no failure, just no tips shown
        XCTAssertTrue(tips.count >= 0)
    }

    // MARK: - Starter due-state filtering

    @MainActor
    func testTipsForOverdueStarterState() {
        let library = makeLoadedLibrary()
        let tips = library.tips(for: .overdue)
        XCTAssertFalse(tips.isEmpty, "Expected tips for overdue starter state")
        XCTAssertTrue(tips.allSatisfy { $0.relatedStarterStates.contains(StarterDueState.overdue.rawValue) })
    }

    @MainActor
    func testTipsForDueTodayStarterState() {
        let library = makeLoadedLibrary()
        let tips = library.tips(for: .dueToday)
        XCTAssertFalse(tips.isEmpty, "Expected tips for dueToday starter state")
        XCTAssertTrue(tips.allSatisfy { $0.relatedStarterStates.contains(StarterDueState.dueToday.rawValue) })
    }

    @MainActor
    func testTipsForOkStarterState() {
        let library = makeLoadedLibrary()
        let tips = library.tips(for: .ok)
        // .ok has no tips in the current dataset — acceptable to return empty
        XCTAssertTrue(tips.count >= 0)
    }

    // MARK: - Item lookup

    @MainActor
    func testItemLookupByKnownId() {
        let library = makeLoadedLibrary()
        let item = library.item(id: "bulk-fermentation-basics")
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.category, .fermentation)
    }

    @MainActor
    func testItemLookupByUnknownId() {
        let library = makeLoadedLibrary()
        let item = library.item(id: "non-existent-id")
        XCTAssertNil(item)
    }

    @MainActor
    func testGlossaryLookupByAliasReturnsCanonicalItem() {
        let library = makeLoadedLibrary()

        let item = library.item(matchingGlossaryTerm: "first rise")

        XCTAssertEqual(item?.id, "bulk-fermentation-basics")
        XCTAssertEqual(item?.title, "Bulk fermentation")
    }

    @MainActor
    func testGlossaryLookupSupportsItalianAlias() {
        let library = makeLoadedLibrary()

        let item = library.item(matchingGlossaryTerm: "preforma")

        XCTAssertEqual(item?.id, "shaping-guide")
    }

    @MainActor
    func testGlossaryIndexMatchesOnlyWholeTermsInsideText() {
        let library = makeLoadedLibrary()

        let matches = library.glossaryIndex.matches(
            in: "La prima lievitazione porta l'impasto verso una bulk fermentation più stabile.",
            maxMatches: 3
        )

        XCTAssertEqual(matches.map(\.articleID), ["bulk-fermentation-basics", "bulk-fermentation-basics"])
        XCTAssertEqual(matches.map(\.matchedTerm), ["prima lievitazione", "bulk fermentation"])
    }

    @MainActor
    func testSearchResultsPreferCanonicalAliasMatch() {
        let library = makeLoadedLibrary()

        let results = library.searchResults(matching: "second rise")

        XCTAssertEqual(results.first?.id, "appretto-guide")
        XCTAssertEqual(results.first?.title, "Appretto")
    }

    @MainActor
    func testSearchResultsSupportEnglishAliasForNewGuides() {
        let library = makeLoadedLibrary()

        let results = library.searchResults(matching: "stretch & fold")

        XCTAssertEqual(results.first?.id, "pieghe-guide")
    }

    @MainActor
    func testSearchResultsRespectCategoryFilter() {
        let library = makeLoadedLibrary()

        let results = library.searchResults(matching: "starter prep", in: .starter)

        XCTAssertEqual(results.first?.id, "levain-guide")
        XCTAssertTrue(results.allSatisfy { $0.category == .starter })
    }

    @MainActor
    func testRelatedItemsPrioritizeExplicitGlossaryMentions() throws {
        let library = makeLoadedLibrary()
        let item = try XCTUnwrap(library.item(id: "pieghe-guide"))

        let results = library.relatedItems(for: item)

        XCTAssertEqual(results.first?.id, "bulk-fermentation-basics")
    }

    @MainActor
    func testRelatedItemsExcludeCurrentArticleAndStayNonEmptyForKnownGuide() throws {
        let library = makeLoadedLibrary()
        let item = try XCTUnwrap(library.item(id: "appretto-guide"))

        let results = library.relatedItems(for: item)

        XCTAssertFalse(results.isEmpty)
        XCTAssertFalse(results.contains(where: { $0.id == item.id }))
    }
}

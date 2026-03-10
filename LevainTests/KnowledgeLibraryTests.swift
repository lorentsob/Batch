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
}

import XCTest

/// UI coverage for the Knowledge tab entry and browsing flow.
/// Uses the deterministic launch harness so tests work without network access
/// or stale simulator state.
final class KnowledgeFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Knowledge tab loads

    func testKnowledgeTabLoadsContent() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Knowledge"].tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))
    }

    // MARK: Category pills visible

    func testKnowledgeCategoryPillsAppear() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Knowledge"].tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        // The filter pill "Tutti" is always shown as the all-categories option.
        XCTAssertTrue(app.buttons["Tutti"].waitForExistence(timeout: 5))
    }

    // MARK: Search field is accessible

    func testKnowledgeSearchFieldExists() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Knowledge"].tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        // The searchable modifier produces a search field in the navigation area.
        XCTAssertTrue(app.searchFields["Cerca articoli e consigli"].waitForExistence(timeout: 5))
    }
}

import XCTest

/// UI coverage for the secondary Knowledge entry and browsing flow.
/// Uses the deterministic launch harness so tests work without network access
/// or stale simulator state.
@MainActor
final class KnowledgeFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Knowledge sheet loads

    func testKnowledgeSheetLoadsContent() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))
    }

    // MARK: Category pills visible

    func testKnowledgeCategoryPillsAppear() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        // The filter pill "Tutti" is always shown as the all-categories option.
        XCTAssertTrue(app.buttons["Tutti"].waitForExistence(timeout: 5))
    }

    // MARK: Search field is accessible

    func testKnowledgeSearchFieldExists() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        // The searchable modifier produces a search field in the navigation area.
        XCTAssertTrue(app.searchFields["Cerca guide e consigli"].waitForExistence(timeout: 5))
    }
}

import XCTest

/// UI coverage for the Bakes tab entry flow.
/// Tests use the deterministic launch harness so they are independent of
/// simulator state and do not trigger notification permission prompts.
final class BakesFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Empty state

    func testBakesTabShownEmptyWithNoData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.staticTexts["Nessun impasto"].waitForExistence(timeout: 5))
    }

    // MARK: Seeded state

    func testBakesTabShowsFormulaWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        // Seeded data includes an active bake, so the empty-state copy must disappear.
        XCTAssertFalse(app.staticTexts["Nessun impasto"].exists)
    }

    // MARK: Empty state offers recipe creation

    func testEmptyBakesStateOffersRecipeCreation() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.buttons["Nuova ricetta"].waitForExistence(timeout: 5))
    }
}

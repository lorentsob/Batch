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
        XCTAssertTrue(app.staticTexts["Nessuna ricetta salvata"].waitForExistence(timeout: 5))
    }

    // MARK: Seeded state

    func testBakesTabShowsFormulaWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        // Seeded data includes known formulas; the empty-state text must disappear.
        XCTAssertFalse(app.staticTexts["Nessuna ricetta salvata"].exists)
    }

    // MARK: New Bake button only enabled with formulas

    func testNewBakeButtonDisabledWhenNoFormulas() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        // The "Nuovo bake" button should be disabled when no formulas exist.
        let newBakeButton = app.buttons["Nuovo bake"]
        if newBakeButton.waitForExistence(timeout: 3) {
            XCTAssertFalse(newBakeButton.isEnabled)
        }
    }
}

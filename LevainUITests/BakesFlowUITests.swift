import XCTest

final class BakesFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testBakesTabShownEmptyWithNoData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.staticTexts["Nessun bake"].waitForExistence(timeout: 5))
    }

    func testBakesTabShowsOperationalDataWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Nessun bake"].exists)
    }

    func testEmptyBakesStateOffersRecipeCreation() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["BakesNewRecipeButton"].waitForExistence(timeout: 5))
    }

    func testNewBakeUsesTemplatesAndCreateThenEditFlow() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.buttons["BakesPrimaryNewBakeButton"].waitForExistence(timeout: 5))
        app.buttons["BakesPrimaryNewBakeButton"].tap()

        XCTAssertTrue(app.navigationBars["Nuovo bake"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Template rapidi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.scrollViews["BakeTemplateScroller"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Pane di campagna"].waitForExistence(timeout: 5))
        app.buttons["Pane di campagna"].tap()

        app.navigationBars["Nuovo bake"].buttons["Crea"].tap()

        XCTAssertTrue(app.navigationBars["Pane di campagna"].waitForExistence(timeout: 8))
    }
}

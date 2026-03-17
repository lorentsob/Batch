import XCTest

@MainActor
final class BakesFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testBakesTabShownEmptyWithNoData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun bake ancora"].waitForExistence(timeout: 8))
    }

    func testBakesTabShowsOperationalDataWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Infornata del weekend"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["Nessun bake ancora"].exists)
    }

    func testEmptyBakesStateOffersRecipeCreation() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun bake ancora"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Crea il tuo primo bake"].waitForExistence(timeout: 8))
    }

    func testNewBakeShowsSystemTemplatesInRecipePicker() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Nuovo bake"].waitForExistence(timeout: 8))
        app.buttons["Nuovo bake"].tap()

        // Verify the creation form appears with the recipe picker
        XCTAssertTrue(app.staticTexts["Ricetta"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.pickers["BakeRecipePicker"].waitForExistence(timeout: 5))
    }
}

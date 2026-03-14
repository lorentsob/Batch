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

    func testNewBakeUsesBundledTemplates() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Nuovo bake"].waitForExistence(timeout: 8))
        app.buttons["Nuovo bake"].tap()

        XCTAssertTrue(app.staticTexts["Ricetta"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Template rapidi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.scrollViews["BakeTemplateScroller"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Pane di campagna"].waitForExistence(timeout: 5))
        app.buttons["Pane di campagna"].tap()

        XCTAssertTrue(app.staticTexts["Starter"].waitForExistence(timeout: 8))
    }
}

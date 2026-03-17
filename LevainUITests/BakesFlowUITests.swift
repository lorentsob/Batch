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

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun bake ancora"].waitForExistence(timeout: 8))
    }

    func testBakesTabShowsOperationalDataWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Infornata del weekend"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["Nessun bake ancora"].exists)
    }

    func testEmptyBakesStateOffersRecipeCreation() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun bake ancora"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Crea il tuo primo bake"].waitForExistence(timeout: 8))
    }

    func testNewBakeShowsSystemTemplatesInRecipePicker() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let bakesTab = app.tabBars.buttons["Impasti"]
        XCTAssertTrue(bakesTab.waitForExistence(timeout: 5))
        bakesTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Nuovo bake"].waitForExistence(timeout: 8))
        app.buttons["Nuovo bake"].tap()

        // Wait for the creation sheet to finish presenting before checking controls.
        XCTAssertTrue(app.navigationBars["Nuovo bake"].waitForExistence(timeout: 10))

        // SwiftUI Form Picker with default style renders as a button in the accessibility tree.
        XCTAssertTrue(app.buttons["BakeRecipePicker"].waitForExistence(timeout: 5))
    }
}

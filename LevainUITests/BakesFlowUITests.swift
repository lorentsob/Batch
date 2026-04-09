import XCTest

@MainActor
final class BakesFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    /// Navigate from app launch to BakesView via Batch > Pane e lievito madre > Impasti.
    private func navigateToBakesView(app: XCUIApplication, timeout: TimeInterval = 8) {
        let batchTab = app.tabBars.buttons["Batch"]
        XCTAssertTrue(batchTab.waitForExistence(timeout: 5))
        batchTab.tap()

        let impastiCard = app.descendants(matching: .any).matching(identifier: "ImpastiCard").firstMatch
        XCTAssertTrue(impastiCard.waitForExistence(timeout: timeout))
        impastiCard.tap()
    }

    // MARK: - Tests

    func testBakesViewShownEmptyWithNoData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        navigateToBakesView(app: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun impasto ancora"].waitForExistence(timeout: 8))
    }

    func testBakesViewShowsOperationalDataWithSeedData() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        navigateToBakesView(app: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Infornata del weekend"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["Nessun impasto ancora"].exists)
    }

    func testEmptyBakesStateOffersRecipeCreation() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        navigateToBakesView(app: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Nessun impasto ancora"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Crea il tuo primo impasto"].waitForExistence(timeout: 8))
    }

    func testNewBakeShowsSystemTemplatesInRecipePicker() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        navigateToBakesView(app: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Nuovo impasto"].waitForExistence(timeout: 8))
        app.buttons["Nuovo impasto"].tap()

        // Wait for the creation sheet to finish presenting before checking controls.
        XCTAssertTrue(app.navigationBars["Nuovo impasto"].waitForExistence(timeout: 10))

        // SwiftUI Form Picker with default style renders as a button in the accessibility tree.
        XCTAssertTrue(app.buttons["BakeRecipePicker"].waitForExistence(timeout: 5))
    }
}

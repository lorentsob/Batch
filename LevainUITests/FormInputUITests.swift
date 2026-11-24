import XCTest

@MainActor
final class FormInputUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func openNewStarterEditor(in app: XCUIApplication) {
        let batchTab = app.tabBars.buttons["Batch"]
        XCTAssertTrue(batchTab.waitForExistence(timeout: 8))
        batchTab.tap()
        let menu = app.buttons["Nuova preparazione"].firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 8))
        menu.tap()
        let newStarter = app.buttons["Nuovo starter"].firstMatch
        XCTAssertTrue(newStarter.waitForExistence(timeout: 5))
        newStarter.tap()
        XCTAssertTrue(app.navigationBars["Nuovo starter"].waitForExistence(timeout: 8))
    }

    func testNewStarterFocusesNameAndRowsAreFullyTappable() throws {
        let app = XCUIApplication()
        app.launchEmpty()
        openNewStarterEditor(in: app)

        // Name field is focused automatically: typing goes straight into it.
        let nameField = app.textFields["es. Ciccio"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5), "Keyboard should open on its own for a new starter")
        app.typeText("Ciccio")
        XCTAssertEqual(nameField.value as? String, "Ciccio")
        app.toolbars.buttons["Fine"].firstMatch.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))

        // Tapping the row label focuses the numeric field and shows a numeric keypad.
        app.staticTexts["Peso contenitore (g)"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.keyboards.keys["q"].exists, "Numeric fields must show the number pad")
        app.typeText("350")
        app.toolbars.buttons["Fine"].firstMatch.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))

        // Flour category rows react to taps in the empty middle area.
        app.buttons["Aggiungi farina"].tap()
        XCTAssertTrue(app.navigationBars["Farina"].waitForExistence(timeout: 5))
        let ryeRow = app.buttons["Segale"].firstMatch
        XCTAssertTrue(ryeRow.waitForExistence(timeout: 5))
        ryeRow.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.5)).tap()
        XCTAssertTrue(app.images["checkmark"].waitForExistence(timeout: 3))
        app.navigationBars["Farina"].buttons["Conferma"].tap()

        let flourRow = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Segale'")).firstMatch
        XCTAssertTrue(flourRow.waitForExistence(timeout: 5))
        flourRow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.navigationBars["Farina"].waitForExistence(timeout: 5), "Tapping the middle of a flour row should open its editor")
    }
}

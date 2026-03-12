import XCTest

final class TodayFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTodayFirstLaunchStateShownWhenNoDataExists() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Per iniziare"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Nuovo bake"].exists)
        XCTAssertTrue(app.buttons["Aggiungi starter"].exists)
    }

    func testTodayAllClearStateShownWhenDataExistsButNothingIsPlanned() throws {
        let app = XCUIApplication()
        app.launchSeeded(scenario: "allClear")

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Niente da fare oggi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Nuovo bake"].exists)
    }

    func testTodayFutureOnlyStateShowsPreviewCard() throws {
        let app = XCUIApplication()
        app.launchSeeded(scenario: "futureOnly")

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Più avanti"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Vai a Starter"].waitForExistence(timeout: 5))
    }

    func testTodaySeededLaunchShowsOperationalContent() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Il forno oggi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Da fare"].waitForExistence(timeout: 5))
    }

    func testTodayOperationalCardCanTransitionFromUpcomingToRunning() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        let completeButton = app.buttons["Completa fase"]
        if completeButton.exists == false {
            let startButton = app.buttons["Avvia fase"]
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
            startButton.tap()
        }

        XCTAssertTrue(completeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Dettaglio"].exists)
    }

    func testStarterReminderDisappearsAfterRefreshSave() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        let refreshButton = app.buttons["Rinfresca"].firstMatch
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 5))
        refreshButton.tap()

        XCTAssertTrue(app.navigationBars["Log rinfresco"].waitForExistence(timeout: 5))
        app.navigationBars["Log rinfresco"].buttons["Salva"].tap()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Rinfresca"].firstMatch.exists)
    }
}

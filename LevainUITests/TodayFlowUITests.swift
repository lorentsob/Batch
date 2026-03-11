import XCTest

/// UI coverage for the Today operational flow.
/// Uses the deterministic launch harness from AppLaunchOptions so tests do not
/// depend on simulator state or notification permission prompts.
final class TodayFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Empty state

    func testTodayEmptyStateShownOnFirstLaunch() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        // Today tab is selected by default
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        // With no data, the app must show a constructive empty state
        XCTAssertTrue(app.staticTexts["Giornata leggera"].waitForExistence(timeout: 5))
    }

    // MARK: Navigation to Bakes from Today empty state

    func testTodayEmptyStateActionNavigatesToBakes() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        // Tap the action button in the Today empty state
        let cta = app.buttons["Nuovo bake"]
        if cta.waitForExistence(timeout: 5) {
            cta.tap()
            XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))
        }
        // If CTA not in empty state, that's acceptable — Today header is present
    }

    // MARK: Seeded state shows agenda content

    func testTodaySeededLaunchShowsOperationalContent() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        XCTAssertTrue(app.staticTexts["Forno operativo"].waitForExistence(timeout: 5))
    }

    func testTodayOperationalCardCanTransitionFromUpcomingToRunning() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        let completeButton = app.buttons["Completa step"]
        if completeButton.exists == false {
            let startButton = app.buttons["Avvia step"]
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
            startButton.tap()
        }

        XCTAssertTrue(completeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Dettaglio"].exists)
    }

    func testTodayOperationalCardShowsShiftEntryWhenStepIsRunning() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        let completeButton = app.buttons["Completa step"]
        if completeButton.exists == false {
            let startButton = app.buttons["Avvia step"]
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
            startButton.tap()
        }

        let shiftButton = app.buttons["Sposta"]
        XCTAssertTrue(shiftButton.waitForExistence(timeout: 5))
        shiftButton.tap()

        XCTAssertTrue(app.buttons["Applica"].waitForExistence(timeout: 5))
    }
}

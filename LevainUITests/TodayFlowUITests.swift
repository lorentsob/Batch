import XCTest

@MainActor
final class TodayFlowUITests: XCTestCase {
    private let seededMainKefirBatchID = "11111111-1111-1111-1111-111111111111"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTodayFirstLaunchStateShownWhenNoDataExists() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Inizia con il primo impasto"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Nuovo impasto"].exists)
        XCTAssertTrue(app.buttons["Aggiungi starter"].exists)
    }

    func testTodayAllClearStateShownWhenDataExistsButNothingIsPlanned() throws {
        let app = XCUIApplication()
        app.launchSeeded(scenario: "allClear")

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Tutto in pari"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Pianifica un nuovo impasto"].exists)
    }

    func testTodayFutureOnlyStateShowsPreviewCard() throws {
        let app = XCUIApplication()
        app.launchSeeded(scenario: "futureOnly")

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Prossima attività"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Apri starter"].waitForExistence(timeout: 5))
    }

    func testTodaySeededLaunchShowsOperationalContent() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Infornata del weekend"].waitForExistence(timeout: 5))
        // Operational card is visible via domain cue (Pane) or urgency label (In ritardo / Da fare / Oggi)
        let hasDomainCue = app.staticTexts["Pane"].exists
        let hasActionButton = app.buttons["Avvia fase"].exists || app.buttons["Completa fase"].exists
        XCTAssertTrue(hasDomainCue || hasActionButton)
    }

    func testTodaySeededLaunchCanOpenKefirBatchFromAgenda() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))

        let kefirRow = app.buttons["TodayKefirRow-\(seededMainKefirBatchID)"]
        XCTAssertTrue(scrollUntilVisible(kefirRow, in: app))
        kefirRow.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch kefir cucina"].waitForExistence(timeout: 8))
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
        XCTAssertTrue(app.buttons["Procedimento"].exists)
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

    private func scrollUntilVisible(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 4
    ) -> Bool {
        if element.exists {
            return true
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.exists {
                return true
            }
        }

        return element.exists
    }
}

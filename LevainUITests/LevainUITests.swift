import XCTest

// MARK: - Base Helper

extension XCUIApplication {
    /// Launch the app with an isolated in-memory store (no persistent state).
    func launchEmpty() {
        launchEnvironment["LEVAIN_RESET_STORE"] = "1"
        launchEnvironment["LEVAIN_SUPPRESS_NOTIFICATIONS"] = "1"
        launch()
    }

    /// Launch the app with an isolated store pre-populated with sample data.
    func launchSeeded() {
        launchEnvironment["LEVAIN_RESET_STORE"] = "1"
        launchEnvironment["LEVAIN_SEED_SAMPLE_DATA"] = "1"
        launchEnvironment["LEVAIN_SUPPRESS_NOTIFICATIONS"] = "1"
        launch()
    }

    /// Launch the app against the real persistent store while still suppressing
    /// notification side effects. Useful for isolating persistent-store startup
    /// behavior from the authorization/resync bootstrap.
    func launchPersistentSuppressingNotifications() {
        launchEnvironment["LEVAIN_SUPPRESS_NOTIFICATIONS"] = "1"
        launch()
    }

    /// Launch the app with the same environment as a normal user run.
    func launchPersistent() {
        launch()
    }
}

// MARK: - Shell Smoke Tests

final class LevainUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Tab bar presence

    func testAppLaunchShowsMainTabs() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Impasti"].exists)
        XCTAssertTrue(app.tabBars.buttons["Starter"].exists)
        XCTAssertFalse(app.tabBars.buttons["Knowledge"].exists)
    }

    // MARK: Tab navigation smoke

    func testTabNavigationCycleReachesAllTabs() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Starter"].tap()
        XCTAssertTrue(app.scrollViews["StarterScrollView"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 5))
    }

    // MARK: Empty launch is clean

    func testEmptyLaunchContainsNoStaleData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 5))

        // No bakes or starters → Today must not show any operational row cards
        // that would only appear with persisted data.
        XCTAssertFalse(app.staticTexts["Prossimo step:"].exists)
    }

    // MARK: Seeded launch has content

    func testSeededLaunchHasAtLeastOneResult() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        // Seeded mode populates at least one bake or formula.
        XCTAssertFalse(app.staticTexts["Nessuna formula salvata"].exists)
    }
}

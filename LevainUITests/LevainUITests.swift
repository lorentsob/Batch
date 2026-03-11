import XCTest

// MARK: - Base Helper

extension XCUIApplication {
    private func configureHarness(resetStore: Bool, seedSampleData: Bool, suppressNotifications: Bool) {
        launchEnvironment["LEVAIN_RESET_STORE"] = resetStore ? "1" : "0"
        launchEnvironment["LEVAIN_SEED_SAMPLE_DATA"] = seedSampleData ? "1" : "0"
        launchEnvironment["LEVAIN_SUPPRESS_NOTIFICATIONS"] = suppressNotifications ? "1" : "0"
    }

    /// Launch the app with an isolated in-memory store (no persistent state).
    func launchEmpty() {
        configureHarness(resetStore: true, seedSampleData: false, suppressNotifications: true)
        launch()
    }

    /// Launch the app with an isolated store pre-populated with sample data.
    func launchSeeded() {
        configureHarness(resetStore: true, seedSampleData: true, suppressNotifications: true)
        launch()
    }

    /// Launch the app against the real persistent store while still suppressing
    /// notification side effects. Useful for isolating persistent-store startup
    /// behavior from the authorization/resync bootstrap.
    func launchPersistentSuppressingNotifications() {
        configureHarness(resetStore: false, seedSampleData: false, suppressNotifications: true)
        launch()
    }

    /// Launch the app with the same environment as a normal user run.
    func launchPersistent() {
        configureHarness(resetStore: false, seedSampleData: false, suppressNotifications: false)
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

        XCTAssertTrue(app.staticTexts["Giornata leggera"].waitForExistence(timeout: 5))
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

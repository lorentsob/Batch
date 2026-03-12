import XCTest

extension XCUIApplication {
    private func configureHarness(
        resetStore: Bool,
        seedSampleData: Bool,
        suppressNotifications: Bool,
        seedScenario: String = "operational",
        forceNotificationsDenied: Bool = false,
        pendingNotificationRoute: String? = nil
    ) {
        launchEnvironment["LEVAIN_RESET_STORE"] = resetStore ? "1" : "0"
        launchEnvironment["LEVAIN_SEED_SAMPLE_DATA"] = seedSampleData ? "1" : "0"
        launchEnvironment["LEVAIN_SUPPRESS_NOTIFICATIONS"] = suppressNotifications ? "1" : "0"
        launchEnvironment["LEVAIN_SEED_SCENARIO"] = seedScenario
        launchEnvironment["LEVAIN_FORCE_NOTIFICATIONS_DENIED"] = forceNotificationsDenied ? "1" : "0"
        if let pendingNotificationRoute {
            launchEnvironment["LEVAIN_PENDING_NOTIFICATION_ROUTE"] = pendingNotificationRoute
        }
    }

    func launchEmpty() {
        configureHarness(resetStore: true, seedSampleData: false, suppressNotifications: true)
        launch()
    }

    func launchSeeded(scenario: String = "operational") {
        configureHarness(
            resetStore: true,
            seedSampleData: true,
            suppressNotifications: true,
            seedScenario: scenario
        )
        launch()
    }

    func launchPersistentSuppressingNotifications() {
        configureHarness(resetStore: false, seedSampleData: false, suppressNotifications: true)
        launch()
    }

    func launchPersistent(forceNotificationsDenied: Bool = false, pendingNotificationRoute: String? = nil) {
        configureHarness(
            resetStore: false,
            seedSampleData: false,
            suppressNotifications: false,
            forceNotificationsDenied: forceNotificationsDenied,
            pendingNotificationRoute: pendingNotificationRoute
        )
        launch()
    }

    func launchEmptyWithDeniedNotifications() {
        configureHarness(
            resetStore: true,
            seedSampleData: false,
            suppressNotifications: false,
            forceNotificationsDenied: true
        )
        launch()
    }

    func launchSeededWithPendingNotificationRoute(_ route: String, scenario: String = "operational") {
        configureHarness(
            resetStore: true,
            seedSampleData: true,
            suppressNotifications: true,
            seedScenario: scenario,
            pendingNotificationRoute: route
        )
        launch()
    }
}

final class LevainUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchShowsMainTabs() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Impasti"].exists)
        XCTAssertTrue(app.tabBars.buttons["Starter"].exists)
        XCTAssertFalse(app.tabBars.buttons["Guide"].exists)
    }

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

    func testEmptyLaunchContainsNoStaleData() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Per iniziare"].waitForExistence(timeout: 5))
    }

    func testSeededLaunchHasAtLeastOneResult() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Nessuna ricetta"].exists)
    }
}

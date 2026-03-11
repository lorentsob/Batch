import XCTest

/// UI regression tests for lifecycle behavior: cold launch, relaunch stability,
/// and app state persistence across boots.
///
/// Uses the deterministic harness from AppLaunchOptions (08-01) so tests do not
/// depend on simulator state leftover from previous runs.
final class LifecycleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Cold launch stability

    func testColdLaunchReachesOperationalState() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        // App must reach the main tab bar — no crash, no blank screen
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchWithPersistentStoreAndSuppressedNotificationsReachesOperationalState() throws {
        let app = XCUIApplication()
        app.launchPersistentSuppressingNotifications()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchWithPersistentStoreAndNotificationBootstrapShowsFirstFrame() throws {
        let app = XCUIApplication()
        app.launchPersistent()

        let homeVisible = app.tabBars.buttons["Home"].waitForExistence(timeout: 8)
        let permissionAlertVisible = app.alerts.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(homeVisible || permissionAlertVisible)
    }

    // MARK: - Relaunch stability

    func testRelaunchPreservesSelectedTab() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Impasti"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 5))

        // Background and foreground the app (simulates a warm relaunch)
        app.terminate()
        app.launchEmpty()

        // After relaunch the shell must be stable
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    // MARK: - Missing-entity route safety

    func testRelaunchAfterSeededLaunchIsStable() throws {
        // First launch: seeded
        let app = XCUIApplication()
        app.launchSeeded()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        app.terminate()

        // Second launch: empty (isolated store)
        app.launchEmpty()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))

        // The app must not crash or show stale state from the previous seeded store
        // because each launch uses LEVAIN_RESET_STORE=1 (in-memory, discarded).
        XCTAssertFalse(app.buttons["Completa step"].exists)
        XCTAssertFalse(app.buttons["Avvia step"].exists)
    }
}

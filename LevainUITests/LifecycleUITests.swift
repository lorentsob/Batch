import XCTest

@MainActor
final class LifecycleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testColdLaunchReachesOperationalState() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchWithPersistentStoreAndSuppressedNotificationsReachesOperationalState() throws {
        let app = XCUIApplication()
        app.launchPersistentSuppressingNotifications()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchWithDeniedNotificationsStillShowsHome() throws {
        let app = XCUIApplication()
        app.launchPersistent(forceNotificationsDenied: true)

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testRelaunchPreservesStableShell() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Impasti"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))

        app.terminate()
        app.launchEmpty()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchPendingNotificationRouteIsHandledWithoutBlankState() throws {
        let app = XCUIApplication()
        let route = "levain://starter/\(UUID().uuidString)"
        app.launchSeededWithPendingNotificationRoute(route)

        XCTAssertTrue(app.tabBars.buttons["Starter"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.scrollViews["StarterScrollView"].waitForExistence(timeout: 8))
    }
}

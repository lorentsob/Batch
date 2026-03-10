import XCTest

/// UI smoke tests for notification-route behavior.
///
/// Full notification delivery cannot be exercised in the simulator without
/// user interaction on the permission prompt, so these tests verify the
/// routing surface (tab switch + navigation stack) that notification taps
/// would trigger — executed synthetically via launch arguments that set a
/// known launch state with deterministic content.
///
/// Note: end-to-end notification tap testing (physical delivery → `pendingURL`
/// → router) requires real on-device verification and is documented as a
/// residual risk in the 08-03 summary.
final class NotificationRouteUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Route surface exists

    func testKnowledgeTabReachableViaTabBar() throws {
        // Simulates the tab-switch step that a knowledge notification route would trigger.
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Knowledge"].tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))
    }

    func testBakesTabReachableViaTabBar() throws {
        // Simulates bake-route tab switch.
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Impasti"].tap()
        XCTAssertTrue(app.scrollViews["BakesScrollView"].waitForExistence(timeout: 8))
    }

    func testStarterTabReachableViaTabBar() throws {
        // Simulates starter-route tab switch.
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Starter"].tap()
        XCTAssertTrue(app.scrollViews["StarterScrollView"].waitForExistence(timeout: 8))
    }

    // MARK: - Notification suppression in test mode

    func testNotificationPermissionNotShownInSuppressedMode() throws {
        // With LEVAIN_SUPPRESS_NOTIFICATIONS=1 the permission alert must never appear.
        let app = XCUIApplication()
        app.launchEmpty() // launchEmpty already sets LEVAIN_SUPPRESS_NOTIFICATIONS=1

        XCTAssertTrue(app.tabBars.buttons["Oggi"].waitForExistence(timeout: 8))

        // Wait briefly to confirm no system permission alert appears
        let permissionAlert = app.alerts.firstMatch
        // Alert should NOT exist (or if the system shows it independently, that's
        // a test environment edge case, not an app-code regression)
        let appeared = permissionAlert.waitForExistence(timeout: 3)
        if appeared {
            // If a system alert appeared it is from the OS, not the app code.
            // We dismiss it and mark as known limitation.
            permissionAlert.buttons.firstMatch.tap()
            XCTFail("Notification permission alert appeared even with LEVAIN_SUPPRESS_NOTIFICATIONS=1 — " +
                    "verify NotificationService.requestAuthorizationIfNeeded is guarded correctly.")
        }
    }
}

import XCTest

@MainActor
final class NotificationRouteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testKnowledgeSurfaceReachableFromHome() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))
    }

    func testColdLaunchMissingBakeRouteFallsBackToPreparazioni() throws {
        let app = XCUIApplication()
        let route = "levain://bake/\(UUID().uuidString)?step=\(UUID().uuidString)"
        app.launchSeededWithPendingNotificationRoute(route)

        // Direct-object routing: missing bake → preparazioni with empty path → PreparationsView
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "PreparationsView").firstMatch.waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Questo bake non è più disponibile")
    }

    func testColdLaunchMissingStarterRouteFallsBackToPreparazioni() throws {
        let app = XCUIApplication()
        let route = "levain://starter/\(UUID().uuidString)"
        app.launchSeededWithPendingNotificationRoute(route)

        // Direct-object routing: missing starter → preparazioni with empty path → PreparationsView
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "PreparationsView").firstMatch.waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Starter non trovato")
    }

    func testNotificationsDeniedShowsNonBlockingBanner() throws {
        let app = XCUIApplication()
        app.launchEmptyWithDeniedNotifications()

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Attiva le notifiche per ricevere i promemoria")
    }
}

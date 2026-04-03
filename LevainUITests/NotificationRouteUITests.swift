import XCTest

@MainActor
final class NotificationRouteUITests: XCTestCase {
    private let seededMainKefirBatchID = "11111111-1111-1111-1111-111111111111"

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

        // Direct-object routing: missing bake → preparazioni with empty path → FermentationsView
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Questo bake non è più disponibile")
    }

    func testColdLaunchMissingStarterRouteFallsBackToPreparazioni() throws {
        let app = XCUIApplication()
        let route = "levain://starter/\(UUID().uuidString)"
        app.launchSeededWithPendingNotificationRoute(route)

        // Direct-object routing: missing starter → preparazioni with empty path → FermentationsView
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Starter non trovato")
    }

    func testColdLaunchMalformedStarterRouteLeavesTodayActive() throws {
        let app = XCUIApplication()
        app.launchSeededWithPendingNotificationRoute("levain://starter/not-a-valid-uuid")

        XCTAssertTrue(app.scrollViews["TodayScrollView"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.exists)
    }

    func testColdLaunchMissingKefirRouteFallsBackToPreparazioni() throws {
        let app = XCUIApplication()
        let route = "levain://kefir/\(UUID().uuidString)"
        app.launchSeededWithPendingNotificationRoute(route)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 8))
        let bannerProbe = app.otherElements["ToastBannerProbe"]
        XCTAssertTrue(bannerProbe.waitForExistence(timeout: 8))
        XCTAssertEqual(bannerProbe.label, "Batch non trovato")
    }

    func testColdLaunchValidKefirRouteOpensBatchDetail() throws {
        let app = XCUIApplication()
        let route = "levain://kefir/\(seededMainKefirBatchID)"
        app.launchSeededWithPendingNotificationRoute(route)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch kefir cucina"].waitForExistence(timeout: 8))
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

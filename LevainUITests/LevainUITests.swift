import XCTest

final class LevainUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchShowsMainTabs() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Oggi"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Impasti"].exists)
        XCTAssertTrue(app.tabBars.buttons["Starter"].exists)
        XCTAssertTrue(app.tabBars.buttons["Knowledge"].exists)
    }
}

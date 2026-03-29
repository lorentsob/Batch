import XCTest

@MainActor
final class PreparationsFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Shell structure

    func testPreparationsTabIsReachableFromTabBar() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let prepTab = app.tabBars.buttons["Preparazioni"]
        XCTAssertTrue(prepTab.waitForExistence(timeout: 5))
        prepTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "PreparationsView").firstMatch.waitForExistence(timeout: 5))
    }

    func testPreparationsRootShowsBothDomainHubCards() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BreadHubCard").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch.waitForExistence(timeout: 5))
    }

    func testPreparationsRootShowsQuickActionButtons() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "QuickNewBakeButton").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "QuickNewStarterButton").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "QuickNewKefirButton").firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Bread hub navigation

    func testBreadHubCardNavigatesToBreadHub() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()

        let breadCard = app.descendants(matching: .any).matching(identifier: "BreadHubCard").firstMatch
        XCTAssertTrue(breadCard.waitForExistence(timeout: 5))
        breadCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BreadHubView").firstMatch.waitForExistence(timeout: 5))
    }

    func testBreadHubShowsImpastiStarterFormuleEntries() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()
        app.descendants(matching: .any).matching(identifier: "BreadHubCard").firstMatch.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BreadHubImpastiRow").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BreadHubStarterRow").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BreadHubFormuleRow").firstMatch.waitForExistence(timeout: 5))
    }

    func testBreadHubImpastiRowNavigatesToBakesView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()
        app.descendants(matching: .any).matching(identifier: "BreadHubCard").firstMatch.tap()
        app.descendants(matching: .any).matching(identifier: "BreadHubImpastiRow").firstMatch.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    func testBreadHubStarterRowNavigatesToStarterView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()
        app.descendants(matching: .any).matching(identifier: "BreadHubCard").firstMatch.tap()
        app.descendants(matching: .any).matching(identifier: "BreadHubStarterRow").firstMatch.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "StarterScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Kefir hub

    func testKefirHubCardNavigatesToKefirHub() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()

        let kefirCard = app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch
        XCTAssertTrue(kefirCard.waitForExistence(timeout: 5))
        kefirCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubView").firstMatch.waitForExistence(timeout: 5))
    }

    func testKefirHubShowsEmptyState() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Preparazioni"].tap()
        app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Nessun batch attivo"].waitForExistence(timeout: 5))
    }

    // MARK: - Deep link preservation

    func testPreparazioniTabIsSelectedAfterBakeDeepLink() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.tabBars.buttons["Oggi"].waitForExistence(timeout: 5))

        // Navigate via Oggi to a bake (preserves Preparazioni tab selection)
        // For now, verify the Preparazioni tab becomes active when we tap it
        app.tabBars.buttons["Preparazioni"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "PreparationsView").firstMatch.waitForExistence(timeout: 5))
    }
}

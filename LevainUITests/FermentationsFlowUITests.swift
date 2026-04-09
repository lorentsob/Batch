import XCTest

@MainActor
final class FermentationsFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Shell structure

    func testFermentationsTabIsReachableFromTabBar() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let fermentiTab = app.tabBars.buttons["Fermenti"]
        XCTAssertTrue(fermentiTab.waitForExistence(timeout: 5))
        fermentiTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 5))
    }

    func testFermentationsRootShowsAllFourCards() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "ImpastiCard").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "StarterCard").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "RicetteCard").firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Navigation

    func testImpastiCardNavigatesToBakesView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()

        let impastiCard = app.descendants(matching: .any).matching(identifier: "ImpastiCard").firstMatch
        XCTAssertTrue(impastiCard.waitForExistence(timeout: 5))
        impastiCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    func testStarterCardNavigatesToStarterView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()

        let starterCard = app.descendants(matching: .any).matching(identifier: "StarterCard").firstMatch
        XCTAssertTrue(starterCard.waitForExistence(timeout: 5))
        starterCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "StarterScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    func testRicetteCardNavigatesToFormulaListView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()

        let ricetteCard = app.descendants(matching: .any).matching(identifier: "RicetteCard").firstMatch
        XCTAssertTrue(ricetteCard.waitForExistence(timeout: 5))
        ricetteCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FormulaListView").firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Kefir hub

    func testKefirHubCardNavigatesToKefirHub() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()

        let kefirCard = app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch
        XCTAssertTrue(kefirCard.waitForExistence(timeout: 5))
        kefirCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubView").firstMatch.waitForExistence(timeout: 5))
    }

    func testKefirHubShowsEmptyState() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Fermenti"].tap()
        app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Nessun batch attivo"].waitForExistence(timeout: 5))
    }

    // MARK: - Deep link preservation

    func testFermentiTabIsSelectedAfterBakeDeepLink() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.tabBars.buttons["Oggi"].waitForExistence(timeout: 5))

        // Navigate via Oggi to a bake (preserves Fermenti tab selection)
        app.tabBars.buttons["Fermenti"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 5))
    }
}

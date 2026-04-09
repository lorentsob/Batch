import XCTest

@MainActor
final class FermentationsFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func revealIfNeeded(_ element: XCUIElement, in app: XCUIApplication, attempts: Int = 3) {
        guard element.waitForExistence(timeout: 1.5) == false else { return }

        for _ in 0..<attempts {
            app.swipeUp()
            if element.waitForExistence(timeout: 1.5) {
                return
            }
        }
    }

    @discardableResult
    private func waitForCard(
        _ identifier: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 8
    ) -> XCUIElement {
        let card = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        revealIfNeeded(card, in: app)
        XCTAssertTrue(card.waitForExistence(timeout: timeout))
        return card
    }

    private func navigateToFormulaList(app: XCUIApplication, timeout: TimeInterval = 8) {
        let batchTab = app.tabBars.buttons["Batch"]
        XCTAssertTrue(batchTab.waitForExistence(timeout: 5))
        batchTab.tap()

        let ricetteCard = waitForCard("RicetteCard", in: app, timeout: timeout)
        ricetteCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FormulaListView").firstMatch.waitForExistence(timeout: timeout))
    }

    private func dismissKnowledgeModal(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    // MARK: - Shell structure

    func testFermentationsTabIsReachableFromTabBar() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let batchTab = app.tabBars.buttons["Batch"]
        XCTAssertTrue(batchTab.waitForExistence(timeout: 5))
        batchTab.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 5))
    }

    func testFermentationsRootShowsAllFourCards() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()

        _ = waitForCard("ImpastiCard", in: app)
        _ = waitForCard("StarterCard", in: app)
        _ = waitForCard("KefirHubCard", in: app)
        _ = waitForCard("RicetteCard", in: app)
    }

    // MARK: - Navigation

    func testImpastiCardNavigatesToBakesView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()

        let impastiCard = waitForCard("ImpastiCard", in: app)
        impastiCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "BakesScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    func testStarterCardNavigatesToStarterView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()

        let starterCard = waitForCard("StarterCard", in: app)
        starterCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "StarterScrollView").firstMatch.waitForExistence(timeout: 5))
    }

    func testRicetteCardNavigatesToFormulaListView() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()

        let ricetteCard = waitForCard("RicetteCard", in: app)
        ricetteCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FormulaListView").firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Kefir hub

    func testKefirHubCardNavigatesToKefirHub() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()

        let kefirCard = waitForCard("KefirHubCard", in: app)
        kefirCard.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubView").firstMatch.waitForExistence(timeout: 5))
    }

    func testKefirHubShowsEmptyState() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        app.tabBars.buttons["Batch"].tap()
        app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Nessun batch attivo"].waitForExistence(timeout: 5))
    }

    // MARK: - Deep link preservation

    func testBatchTabIsSelectedAfterBakeDeepLink() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        XCTAssertTrue(app.tabBars.buttons["Oggi"].waitForExistence(timeout: 5))

        // Navigate via Oggi to a bake (preserves Batch tab selection)
        app.tabBars.buttons["Batch"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 5))
    }

    func testFormulaGlossaryLinkOpensKnowledgeArticleOnSharedRootStack() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        navigateToFormulaList(app: app)

        let formulaRow = app.staticTexts["Bagel"].firstMatch
        XCTAssertTrue(formulaRow.waitForExistence(timeout: 8))
        formulaRow.tap()

        XCTAssertTrue(app.navigationBars["Ricetta"].waitForExistence(timeout: 8))

        let bulkLink = app.links["Bulk fermentation"].firstMatch
        XCTAssertTrue(bulkLink.waitForExistence(timeout: 8))
        bulkLink.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-bulk-fermentation-basics"].waitForExistence(timeout: 8))
    }

    func testFormulaGlossaryBackReturnsToFormulaDetail() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        navigateToFormulaList(app: app)

        let formulaRow = app.staticTexts["Bagel"].firstMatch
        XCTAssertTrue(formulaRow.waitForExistence(timeout: 8))
        formulaRow.tap()

        XCTAssertTrue(app.navigationBars["Ricetta"].waitForExistence(timeout: 8))

        let bulkLink = app.links["Bulk fermentation"].firstMatch
        XCTAssertTrue(bulkLink.waitForExistence(timeout: 8))
        bulkLink.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        dismissKnowledgeModal(in: app)

        XCTAssertTrue(app.navigationBars["Ricetta"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Bagel"].waitForExistence(timeout: 8))
    }
}

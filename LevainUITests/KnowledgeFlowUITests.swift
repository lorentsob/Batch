import XCTest

/// UI coverage for the secondary Knowledge entry and browsing flow.
/// Uses the deterministic launch harness so tests work without network access
/// or stale simulator state.
@MainActor
final class KnowledgeFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func openKnowledgeFromToday(_ app: XCUIApplication) {
        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))
    }

    private func knowledgeSearchField(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.searchFields["KnowledgeBottomSearchField"],
            app.textFields["KnowledgeBottomSearchField"],
            app.searchFields["Cerca guide e consigli"],
            app.textFields["Cerca guide e consigli"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return candidates[0]
    }

    private func dismissKnowledgeModal(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    // MARK: Knowledge sheet loads

    func testKnowledgeSheetLoadsContent() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKnowledgeFromToday(app)
    }

    // MARK: Category pills visible

    func testKnowledgeCategoryPillsAppear() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKnowledgeFromToday(app)

        // The filter pill "Tutti" is always shown as the all-categories option.
        XCTAssertTrue(app.buttons["Tutti"].waitForExistence(timeout: 5))
    }

    // MARK: Search field is accessible

    func testKnowledgeSearchFieldExists() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKnowledgeFromToday(app)

        XCTAssertTrue(knowledgeSearchField(in: app).exists)
    }

    func testKnowledgeArticleNavigationUsesSharedRootStack() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKnowledgeFromToday(app)

        let articleRow = app.buttons["KnowledgeArticleRow-starter-basics"].firstMatch
        XCTAssertTrue(articleRow.waitForExistence(timeout: 5))
        articleRow.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-starter-basics"].waitForExistence(timeout: 8))
    }

    func testKnowledgeArticleGlossaryLinkNavigatesToRelatedGuide() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guideTab = app.tabBars.buttons["Guide"]
        XCTAssertTrue(guideTab.waitForExistence(timeout: 5))
        guideTab.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        let articleRow = app.buttons["KnowledgeArticleRow-common-problems"].firstMatch
        XCTAssertTrue(articleRow.waitForExistence(timeout: 5))
        articleRow.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))

        let linkedTerm = app.links["starter"].firstMatch
        XCTAssertTrue(linkedTerm.waitForExistence(timeout: 8))
        linkedTerm.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-starter-basics"].waitForExistence(timeout: 8))

        dismissKnowledgeModal(in: app)

        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-common-problems"].waitForExistence(timeout: 8))
    }

    func testKnowledgeAliasSearchOpensCanonicalGuide() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKnowledgeFromToday(app)

        let searchField = knowledgeSearchField(in: app)
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("second rise")

        let articleRow = app.buttons["KnowledgeArticleRow-appretto-guide"].firstMatch
        XCTAssertTrue(articleRow.waitForExistence(timeout: 8))
        articleRow.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-appretto-guide"].waitForExistence(timeout: 8))
    }

    func testKnowledgeArticleLinkNavigatesToNewGlossaryEntry() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guideTab = app.tabBars.buttons["Guide"]
        XCTAssertTrue(guideTab.waitForExistence(timeout: 5))
        guideTab.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        let articleRow = app.buttons["KnowledgeArticleRow-bulk-fermentation-basics"].firstMatch
        XCTAssertTrue(articleRow.waitForExistence(timeout: 5))
        articleRow.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))

        let linkedTerm = app.links["pieghe"].firstMatch
        XCTAssertTrue(linkedTerm.waitForExistence(timeout: 8))
        linkedTerm.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-pieghe-guide"].waitForExistence(timeout: 8))

        dismissKnowledgeModal(in: app)

        XCTAssertTrue(app.staticTexts["KnowledgeDetailTitle-bulk-fermentation-basics"].waitForExistence(timeout: 8))
    }

    func testKnowledgeArticleNavigationUsesSharedRootStack() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        let guidesButton = app.buttons["TodayBrowseGuidesButton"]
        XCTAssertTrue(guidesButton.waitForExistence(timeout: 5))
        guidesButton.tap()
        XCTAssertTrue(app.scrollViews["KnowledgeScrollView"].waitForExistence(timeout: 8))

        let articleRow = app.buttons["KnowledgeArticleRow-starter-basics"].firstMatch
        XCTAssertTrue(articleRow.waitForExistence(timeout: 5))
        articleRow.tap()

        XCTAssertTrue(app.scrollViews["KnowledgeDetailView"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Basi del lievito madre"].waitForExistence(timeout: 8))
    }
}

import XCTest

@MainActor
final class KefirFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSeededPreparationsShowsLiveKefirCounts() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        app.tabBars.buttons["Batch"].tap()

        let card = app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 8))
        XCTAssertEqual(card.value as? String, "1 da seguire · 1 in corso · 2 in pausa")
    }

    func testSeededKefirHubShowsGroupedBatchSections() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openKefirHub(in: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirSection-warning").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(scrollUntilVisible(app.descendants(matching: .any).matching(identifier: "KefirSection-active").firstMatch, in: app))
        XCTAssertTrue(app.staticTexts["Batch kefir cucina"].exists)
        XCTAssertTrue(app.staticTexts["Batch kefir colazione"].exists)
        XCTAssertTrue(scrollUntilVisible(app.descendants(matching: .any).matching(identifier: "KefirSection-paused").firstMatch, in: app))
        XCTAssertTrue(scrollUntilVisible(app.descendants(matching: .any).matching(identifier: "KefirSection-archived").firstMatch, in: app))
        XCTAssertTrue(scrollUntilVisible(app.staticTexts["Backup frigo"], in: app))
        XCTAssertTrue(scrollUntilVisible(app.staticTexts["Batch test derivato"], in: app))
    }

    func testSeededKefirBatchOpensDetailFromHub() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)
        XCTAssertTrue(app.staticTexts["Batch kefir cucina"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirDetailPrimaryActionButton").firstMatch.waitForExistence(timeout: 8))
    }

    func testSeededKefirHubCanOpenJournalSurface() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openJournal(in: app)
        XCTAssertTrue(app.staticTexts["Cronologia e archivio"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch test derivato"].waitForExistence(timeout: 8))
        XCTAssertTrue(scrollUntilVisible(app.staticTexts["Batch avviato"], in: app))
    }

    func testEmptyKefirHubCanCreateFirstBatch() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openKefirHub(in: app)
        app.buttons["Nuovo batch"].firstMatch.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchEditorView").firstMatch.waitForExistence(timeout: 8))
        let nameField = app.textFields["KefirBatchNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText("Batch creato da hub")
        app.buttons["KefirBatchSubmitButton"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch creato da hub"].waitForExistence(timeout: 8))
    }

    func testPreparationsQuickActionCreatesKefirBatch() throws {
        let app = XCUIApplication()
        app.launchEmpty()

        openFermentations(in: app)
        let quickNewKefirButton = app.descendants(matching: .any).matching(identifier: "QuickNewKefirButton").firstMatch
        XCTAssertTrue(quickNewKefirButton.waitForExistence(timeout: 8))
        quickNewKefirButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchEditorView").firstMatch.waitForExistence(timeout: 8))
        let nameField = app.textFields["KefirBatchNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText("Batch rapido")
        app.buttons["KefirBatchSubmitButton"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch rapido"].waitForExistence(timeout: 8))
    }

    func testSeededKefirDetailCanDeriveNewBatch() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)
        let deriveButton = app.buttons["KefirDetailQuickDeriveButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(deriveButton, in: app))
        deriveButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchEditorView").firstMatch.waitForExistence(timeout: 8))
        app.buttons["KefirBatchSubmitButton"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch kefir cucina derivato"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Derivato"].exists)
    }

    func testSeededKefirDetailShowsRecentHistoryAndOpensBatchJournal() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)

        XCTAssertTrue(scrollUntilVisible(app.staticTexts["Storia recente"], in: app))

        let journalButton = app.buttons["KefirDetailOpenJournalButton"].firstMatch
        XCTAssertTrue(journalButton.waitForExistence(timeout: 8))
        journalButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirJournalView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch kefir cucina"].waitForExistence(timeout: 8))
        XCTAssertTrue(scrollUntilVisible(app.staticTexts["Ha generato Batch kefir colazione"], in: app))
    }

    func testSeededKefirHubCanOpenArchiveDirectly() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openJournal(in: app)

        let archiveButton = app.buttons["KefirJournalOpenArchiveButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(archiveButton, in: app, maxSwipes: 12))
        archiveButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirArchiveView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Archivio kefir"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch test derivato"].waitForExistence(timeout: 8))
    }

    func testSeededKefirArchiveCanOpenBatchDetail() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openArchiveView(in: app)

        let openButton = app.buttons["Rileggi"].firstMatch
        XCTAssertTrue(scrollUntilVisible(openButton, in: app))
        openButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Batch test derivato"].waitForExistence(timeout: 8))
    }

    func testSeededKefirArchiveCanDeriveFromArchivedBatch() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openArchiveView(in: app)

        let deriveButton = app.buttons["Nuovo batch"].firstMatch
        XCTAssertTrue(scrollUntilVisible(deriveButton, in: app))
        deriveButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchEditorView").firstMatch.waitForExistence(timeout: 8))
        app.buttons["KefirBatchSubmitButton"].tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Derivato"].waitForExistence(timeout: 8))
    }

    func testSeededKefirDetailShowsCompareButtonAndOpenComparison() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)

        let compareButton = app.buttons["KefirDetailCompareButton"].firstMatch
        XCTAssertTrue(compareButton.waitForExistence(timeout: 8))
        compareButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchComparisonView").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Confronto batch"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirComparisonPrimaryCard").firstMatch.waitForExistence(timeout: 8))
    }

    func testSeededKefirJournalCanNavigateToArchive() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openJournal(in: app)

        let archiveLink = app.buttons["KefirJournalOpenArchiveButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(archiveLink, in: app, maxSwipes: 12))
        archiveLink.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirArchiveView").firstMatch.waitForExistence(timeout: 8))
    }

    func testSeededKefirDetailCanArchiveBatch() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)
        let archiveButton = app.buttons["KefirDetailQuickArchiveButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(archiveButton, in: app))
        archiveButton.tap()
        app.alerts.buttons["Archivia"].tap()

        XCTAssertTrue(app.staticTexts["Batch archiviato"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Archiviato"].waitForExistence(timeout: 8))
    }

    func testSeededKefirDetailCanOpenManageSheetFromQuickAction() throws {
        let app = XCUIApplication()
        app.launchSeeded()

        openFirstSeededBatchDetail(in: app)
        let manageButton = app.buttons["KefirDetailPrimaryActionButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(manageButton, in: app))
        manageButton.tap()

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchManageSheet").firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchManageStoragePicker").firstMatch.waitForExistence(timeout: 8))
    }

    private func scrollUntilVisible(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 8
    ) -> Bool {
        if element.exists {
            return true
        }

        for _ in 0..<maxSwipes {
            primaryScrollContainer(in: app).swipeUp()
            if element.exists {
                return true
            }
        }

        return element.exists
    }

    private func primaryScrollContainer(in app: XCUIApplication) -> XCUIElement {
        let detailScrollView = app.descendants(matching: .any).matching(identifier: "KefirBatchDetailScrollView").firstMatch
        if detailScrollView.exists { return detailScrollView }

        let journalScrollView = app.descendants(matching: .any).matching(identifier: "KefirJournalScrollView").firstMatch
        if journalScrollView.exists { return journalScrollView }

        let archiveScrollView = app.descendants(matching: .any).matching(identifier: "KefirArchiveScrollView").firstMatch
        if archiveScrollView.exists { return archiveScrollView }

        let hubTable = app.tables.firstMatch
        if hubTable.exists { return hubTable }

        let genericScrollView = app.scrollViews.firstMatch
        if genericScrollView.exists { return genericScrollView }

        return app
    }

    private func openFermentations(in app: XCUIApplication) {
        let batchTab = app.tabBars.buttons["Batch"]
        XCTAssertTrue(batchTab.waitForExistence(timeout: 8))
        batchTab.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "FermentationsView").firstMatch.waitForExistence(timeout: 8))
    }

    private func openKefirHub(in app: XCUIApplication) {
        openFermentations(in: app)
        let kefirCard = app.descendants(matching: .any).matching(identifier: "KefirHubCard").firstMatch
        XCTAssertTrue(kefirCard.waitForExistence(timeout: 8))
        kefirCard.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirHubView").firstMatch.waitForExistence(timeout: 8))
    }

    private func openArchiveView(in app: XCUIApplication) {
        openJournal(in: app)
        let archiveButton = app.buttons["KefirJournalOpenArchiveButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(archiveButton, in: app, maxSwipes: 12))
        archiveButton.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirArchiveView").firstMatch.waitForExistence(timeout: 8))
    }

    private func openJournal(in app: XCUIApplication) {
        openKefirHub(in: app)
        let journalButton = app.buttons["KefirHubOpenJournalButton"].firstMatch
        XCTAssertTrue(scrollUntilVisible(journalButton, in: app, maxSwipes: 12))
        journalButton.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirJournalView").firstMatch.waitForExistence(timeout: 8))
    }

    private func openFirstSeededBatchDetail(in app: XCUIApplication) {
        openKefirHub(in: app)
        let openButton = app.buttons["KefirBatchPrimaryCTA-batch-kefir-cucina"].firstMatch
        XCTAssertTrue(scrollUntilVisible(openButton, in: app, maxSwipes: 8))
        openButton.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "KefirBatchDetailView").firstMatch.waitForExistence(timeout: 8))
    }
}

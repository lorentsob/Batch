# Phase 20-03 — Archive/Comparison Polish

**Status:** Complete
**Date:** 2026-04-02

## What shipped

### New files
- `Levain/Features/Kefir/KefirArchiveView.swift` — dedicated archive surface; shows all archived batches with operational summary, lineage card summary, context summary, and two vertically-stacked actions per card: "Rileggi" (opens detail) and "Deriva" (starts derive editor)
- `Levain/Features/Kefir/KefirBatchComparisonView.swift` — lightweight lineage comparison surface; shows primary batch in a tinted card plus optional source and derived sections; each card shows role badge, name, status headline, and context summary; non-primary batches get an "Apri" button

### Modified files
- `KefirHubView.swift` — added toolbar "Archivio" button (visible when `archivedKefirCount > 0`) + `navigationDestination` to `KefirArchiveView`; also added "Journal" and "Archivio" secondary buttons inside the hub header card
- `KefirJournalView.swift` — added `KefirJournalScrollView` identifier on the outer `ScrollView`; added "Vai all'archivio completo" `NavigationLink` at the bottom of the archive library card section
- `KefirBatchDetailView.swift` — added toolbar "Confronta" button (`KefirDetailCompareButton`) that navigates to `KefirBatchComparisonView`; removed the in-card compare action that was inaccessible in UI tests due to scroll/visibility limitations
- `Levain.xcodeproj/project.pbxproj` — registered both new Swift files in build phases

### UI tests added (KefirFlowUITests.swift)
- `testSeededKefirHubCanOpenArchiveDirectly` — toolbar archive button → `KefirArchiveView`
- `testSeededKefirArchiveCanOpenBatchDetail` — archive "Rileggi" button → batch detail
- `testSeededKefirArchiveCanDeriveFromArchivedBatch` — archive "Deriva" button → editor → new detail
- `testSeededKefirDetailShowsCompareButtonAndOpenComparison` — toolbar compare button → `KefirBatchComparisonView`
- `testSeededKefirJournalCanNavigateToArchive` — journal "Vai all'archivio completo" → `KefirArchiveView`

## Key decisions

- **Toolbar for navigation entry points**: buttons that launch full-screen destinations (`KefirDetailCompareButton`, `KefirHubOpenArchiveButton`, `KefirHubOpenJournalButton`) live in `.toolbar` rather than inside scroll content — they are always visible and 100% reliably found by XCTest
- **Vertically-stacked buttons in archive cards**: two `maxWidth: .infinity` buttons in an `HStack` are merged into one accessibility element by SwiftUI; stacking them vertically avoids the merge and lets each button be addressed independently
- **Label-based button matching in tests**: for in-scroll buttons ("Rileggi", "Deriva", "Vai all'archivio completo") `app.buttons["label text"]` is more reliable than `descendants(matching:).matching(identifier:)` when accessibility tree depth is uncertain
- **Comparison surface is lineage-only**: `KefirBatchComparisonView` shows only source + derived relationships (same lineage tree) — it is not a general multi-batch comparison picker; keeping it scoped preserves the action-first character of the detail screen

## Test architecture notes

- `primaryScrollContainer(in:)` helper now checks for `KefirBatchDetailScrollView`, `KefirJournalScrollView`, `KefirArchiveScrollView`, then `app.tables.firstMatch`, then `app.scrollViews.firstMatch`, then `app`
- Archive and journal scroll views now carry explicit `accessibilityIdentifier` so `scrollUntilVisible` targets the correct container

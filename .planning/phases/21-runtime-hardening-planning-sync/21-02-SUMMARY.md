# Phase 21-02 — Knowledge Ownership & Kefir Lineage Hardening

**Status:** Complete
**Date:** 2026-04-03

## What shipped

### Modified app files
- `Levain/Features/Shared/RootTabView.swift` — the Knowledge tab now owns the only Knowledge `NavigationStack` and passes the shared `KnowledgeLibrary` into `KnowledgeView`
- `Levain/Features/Knowledge/KnowledgeView.swift` and `Levain/Features/Knowledge/KnowledgeDetailView.swift` — Knowledge surfaces now observe `KnowledgeLibrary` directly while article navigation stays rooted in the shared stack
- `Levain/Features/Preparations/PreparationsView.swift` and `Levain/Features/Preparations/PreparationHubCardView.swift` — added explicit asset/system icon handling so bread keeps the shipped `navbar-bake` asset and kefir uses a simple `drop.fill` symbol
- `Levain/Features/Kefir/KefirBatchPresentation.swift` — centralized `KefirLineageIndex`, lineage summaries, section models, and shared presentation helpers for kefir-heavy surfaces
- `Levain/Features/Kefir/KefirBatchDetailView.swift`, `Levain/Features/Kefir/KefirJournalView.swift`, `Levain/Features/Kefir/KefirArchiveView.swift`, and `Levain/Features/Kefir/KefirBatchComparisonView.swift` — adopted the shared kefir presentation layer while keeping the shipped quick-action and navigation contracts intact

### Modified test files
- `LevainUITests/KnowledgeFlowUITests.swift` — added shared-root-stack article navigation coverage
- `LevainUITests/KefirFlowUITests.swift` — kept hub/detail/journal/archive/comparison flows green across the shared lineage/presentation refactor

## Key decisions

- Knowledge navigation ownership stays in the root shell; feature views should not create competing stacks
- Shared kefir lineage logic lives with kefir presentation code rather than becoming generic cross-domain infrastructure
- Preparazioni icon handling now uses a typed asset/system split so domain cues stay visually coherent and testable

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-sim -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-knowledgelib -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/KnowledgeLibraryTests` — passed (`8/8`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-knowledge -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/KnowledgeFlowUITests` — passed (`4/4`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-kefir -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/KefirFlowUITests` — passed (`15/15`)

## Outcome

Knowledge and kefir lineage-heavy screens now have cleaner ownership boundaries, less duplicated presentation logic, and the shipped Preparazioni/kefir interaction polish remains intact under regression coverage.

# Phase 23-03 — Editorial Coverage, Search Polish & Verification

**Status:** Complete
**Date:** 2026-04-08

## What shipped

### Modified app files
- `Levain/Resources/knowledge.json` — added the missing high-value glossary guides for `Levain`, `Appretto`, `Autolisi`, `Pieghe e stretch & fold`, and `Bollitura`, with canonical aliases aligned to shipped recipe terminology
- `Levain/Services/KnowledgeLoader.swift` — added alias-aware search/ranking so Knowledge now prefers exact title/alias/tag matches before loose summary/content matches
- `Levain/Features/Knowledge/KnowledgeView.swift` — switched the screen search path to the shared library search so UI results follow the same canonical resolver used by glossary links

### Modified test files
- `LevainTests/KnowledgeLoaderTests.swift` — now verifies that the bundled dataset includes the new glossary entries and resolves new aliases such as `second rise` and `stretch & fold`
- `LevainTests/KnowledgeLibraryTests.swift` — added coverage for canonical alias ranking plus category-filtered search on the new guide set
- `LevainUITests/KnowledgeFlowUITests.swift` — added end-to-end coverage for alias search into `Appretto`, guide-to-guide navigation into the new `Pieghe` article, and stabilized the Knowledge search-field lookup through the existing accessibility identifier

## Key decisions

- The first-rollout glossary backlog is now considered closed for shipped bread formulas: the priority missing concepts from discovery were authored instead of deferred
- Knowledge search now follows the same canonical vocabulary contract as inline links, so a recipe alias and a manual Knowledge search resolve to the same article
- UI search verification targets the existing `KnowledgeBottomSearchField` accessibility identifier because the simulator exposes the underlying search control as a text field rather than a stable `SearchField`

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KnowledgeLoaderTests` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KnowledgeLibraryTests` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KnowledgeFlowUITests` — passed

## Residuals

- No dedicated manual small-screen pass or on-device review artifact was captured during `23-03`; confidence comes from bundled-content review plus targeted UI coverage
- Phase 22 remains the only open v2 wave, so future Knowledge work should now be kefir-specific rather than further bread glossary expansion

## Outcome

Phase 23 is fully closed. Levain now ships a coherent guide/glossary system: bundled bread terminology has canonical article coverage, manual Knowledge search respects the same alias map used by inline recipe links, and the integrated navigation flow is regression-covered from search and cross-reference entry points.

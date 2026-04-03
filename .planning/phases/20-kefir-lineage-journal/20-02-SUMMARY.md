---
phase: 20-kefir-lineage-journal
plan: 02
status: complete
---

## Summary

Delivered the first readable kefir journal slice by turning typed `KefirEvent` history into grouped timeline surfaces, adding discoverable journal entry points from the hub and batch detail, and seeding deterministic live/derived/paused/archived event scenarios for UI regression coverage. The kefir vertical stays batch-first and action-first, but it now exposes enough continuity to understand renewals, storage changes, derivations, and archived reuse without manual diary overhead.

### Changes

- **`Levain/Features/Kefir/KefirJournalView.swift`** and **`Levain/Features/Kefir/KefirEventRow.swift`**: Added the new journal/archive surface plus a reusable event-row grammar with timeline grouping, archive-library rows, batch-context badges, and optional jump-back-to-batch actions.
- **`Levain/Features/Kefir/KefirBatchPresentation.swift`**, **`Levain/Models/KefirEvent.swift`**, and **`Levain/Services/DateFormattingService.swift`**: Added timeline query helpers, journal day sections, human-readable event presentation/microcopy, timestamp summaries, and day-formatting support so event history reads like operational context instead of raw model data.
- **`Levain/Features/Kefir/KefirHubView.swift`** and **`Levain/Features/Kefir/KefirBatchDetailView.swift`**: Added hub/detail journal entry points, kept the dominant batch action intact, surfaced concise recent-history context on detail, and stabilized the detail journal route with direct `NavigationLink` navigation.
- **`Levain/Persistence/SeedDataLoader.swift`** and **`LevainTests/SeedDataLoaderTests.swift`**: Seeded deterministic kefir histories across active, derived, paused-fridge, paused-freezer, and archived batches, then added assertions that the operational demo scenario now includes real lineage/event depth.
- **`LevainUITests/KefirFlowUITests.swift`**: Added journal/history UI coverage for hub and detail entry points, tightened scroll-container handling for seeded kefir flows, and kept the full kefir slice regression-safe.
- **`Levain.xcodeproj/project.pbxproj`**: Registered the new journal and event-row source files in the app target.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- Seed-data tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/SeedDataLoaderTests` — **7/7 passed**
- UI tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KefirFlowUITests` — **9/9 passed**
- Note: the plan’s original `iPhone 17 Pro` simulator destination is not available in this workspace, so verification ran on the available `iPhone 15 Pro` simulator (`iOS 26.4`).
- Phase 20 now has its first usable journal/history surface; the next planned execution wave is `20-03` for archive/comparison polish and final workflow refinement.

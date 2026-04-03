---
phase: 19-milk-kefir-batch-core
plan: 02
status: complete
---

## Summary

Shipped the first real milk kefir UI vertical: `Preparazioni` now shows live kefir activity, the hub groups persisted batches by operational state, and each batch opens into a focused detail baseline.

### Changes

- **`Levain/Features/Kefir/KefirBatchPresentation.swift`** (new): Added shared kefir presentation helpers so hub cards and detail surfaces derive the same storage-aware labels, summaries, urgency tone, and primary-action copy from `KefirBatch`.
- **`Levain/Features/Kefir/KefirBatchCardView.swift`** (new): Added the reusable batch card UI with status badges, last/next management context, operational summary, and a clear CTA that matches the current Levain card grammar.
- **`Levain/Features/Kefir/KefirBatchListView.swift`** (new): Added grouped hub sections for warning, active, paused, and archived batches so the new vertical stays operational instead of becoming a flat history list.
- **`Levain/Features/Kefir/KefirBatchDetailView.swift`** (new): Added the first real batch detail screen with header, context, one dominant action, and quick actions for renew/derive/storage-state/archive; the action handlers explicitly defer to Phase 19-03 instead of behaving like dead controls.
- **`Levain/Features/Kefir/KefirHubView.swift`**: Replaced the placeholder kefir screen with a live `@Query` hub, summary badges, empty-state/create messaging, and list-driven navigation into batch detail.
- **`Levain/Features/Preparations/PreparationsView.swift`** and **`Levain/Features/Preparations/PreparationHubCardView.swift`**: Replaced hard-coded kefir placeholder copy with live batch counts and subtitle accessibility, while keeping the root quick action explicit about the deferred creation flow.
- **`Levain/Features/Shared/RootTabView.swift`**: Routed `.kefirBatch(UUID)` into a real lookup/detail flow so batch IDs now resolve to persisted kefir detail instead of looping back to a stub.
- **`Levain/Persistence/SeedDataLoader.swift`**: Added deterministic seeded kefir batches covering warning, active, paused, freezer-reactivation, and archived-derived scenarios for UI validation.
- **`LevainUITests/KefirFlowUITests.swift`** (new): Added focused UI coverage for live Preparazioni counts, grouped hub sections, and detail navigation.
- **`Levain.xcodeproj/project.pbxproj`**: Registered the new kefir UI and UI-test files in the app and UI test targets.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- UI tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KefirFlowUITests` — **3/3 passed**
- The milk kefir vertical no longer depends on placeholder-only screens; creation/manage flows remain intentionally deferred to `19-03`.

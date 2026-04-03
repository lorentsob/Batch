---
phase: 19-milk-kefir-batch-core
plan: 04
status: complete
---

## Summary

Closed the milk-kefir batch core by wiring storage-aware local reminders, real kefir items in `Oggi`, and direct notification/tap routing into batch detail. Phase 19 now behaves as one coherent batch-first vertical across `Preparazioni`, `Oggi`, and app-entry surfaces.

### Changes

- **`Levain/Services/KefirReminderPlanner.swift`**: Added a dedicated kefir reminder planner so room-temperature, fridge, and freezer behavior use explicit timing defaults and share one source of truth outside `NotificationService`.
- **`Levain/Services/NotificationService.swift`**: Extended global resync plus per-batch sync to include `KefirBatch`, and made notification plans consume the new reminder planner instead of ad-hoc kefir logic.
- **`Levain/Features/Kefir/KefirBatchEditorView.swift`**, **`Levain/Features/Kefir/KefirBatchManageSheet.swift`**, and **`Levain/Features/Kefir/KefirBatchDetailView.swift`**: Added notification resync after create, renew, reactivate, archive, and storage/routine updates so reminder state stays aligned with actual batch mutations.
- **`Levain/Services/TodayAgendaBuilder.swift`** and **`Levain/Features/Today/TodayView.swift`**: Plugged real kefir batches into the ranked cross-domain agenda, added kefir future previews, direct batch opening from `Oggi`, and kefir-aware hero copy instead of the previous placeholder branch.
- **`Levain/App/AppRouter.swift`**: Completed notification-aware kefir deep-link handling with direct-object routing into batch detail plus the same safe fallback banner pattern already used for missing bake/starter routes.
- **`Levain/Persistence/SeedDataLoader.swift`**: Made the seeded kefir batches deterministic with fixed UUIDs so notification-route and Today-entry UI automation can target stable seeded objects.
- **`LevainTests/KefirReminderPlannerTests.swift`** (new), **`LevainTests/TodayAgendaBuilderTests.swift`**, and **`LevainTests/AppRouterTests.swift`**: Added unit coverage for storage-aware reminder timing, kefir agenda urgency/preview behavior, and direct notification routing/fallbacks.
- **`LevainUITests/NotificationRouteUITests.swift`**, **`LevainUITests/TodayFlowUITests.swift`**, and **`LevainUITests/KefirFlowUITests.swift`**: Added cold-launch kefir route coverage, Today-to-kefir-detail coverage, and reran/kept the existing kefir seeded flows green after the new integration work.
- **`Levain.xcodeproj/project.pbxproj`**: Registered `KefirReminderPlanner.swift` and `KefirReminderPlannerTests.swift` in the correct targets.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- Unit tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KefirReminderPlannerTests -only-testing:LevainTests/TodayAgendaBuilderTests -only-testing:LevainTests/AppRouterTests` — **36/36 passed**
- UI tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/TodayFlowUITests -only-testing:LevainUITests/NotificationRouteUITests -only-testing:LevainUITests/KefirFlowUITests` — **20/20 passed**
- Phase 19 is now complete; the next planned execution wave is Phase 20 for lineage visibility and structured kefir journal foundations.

---
phase: 18-oggi-cross-domain-agenda
plan: 03
status: complete
---

## Summary

Extended the router contract with kefir-ready direct-object routing, moved tomorrow preview taps onto router semantics, and updated routing regression tests for the v2 shell.

### Changes

- **`Levain/App/AppRouter.swift`**:
  - Added `PreparationsRoute.kefirBatch(UUID)` case — Phase 19 hook for milk kefir batch detail.
  - Added `openKefirBatch(_ id: UUID)` helper: navigates directly to `.kefirBatch(id)` under Preparazioni, same direct-object rule as bake/starter.
  - Added `DeepLink.kefirBatch(id:)` static builder (`levain://kefir/<uuid>`).
  - Added `case "kefir"` to `open(url:)` deep-link dispatch; routes to `openKefirBatch` without a fatal fallthrough.

- **`Levain/Features/Shared/RootTabView.swift`**: Added `.kefirBatch` case to `navigationDestination` switch — renders `KefirHubView()` as placeholder until Phase 19 adds `KefirBatchDetailView`.

- **`Levain/Features/Today/TodayView.swift`**: `.tomorrowPreview` row taps now call `router.openBake(selection.bake.id)` (direct-object rule) instead of opening a local `BakeStepDetailView` sheet. Inline primary actions (start/complete step) remain as fast operational shortcuts.

- **`LevainTests/AppRouterTests.swift`**: Added 2 new tests:
  - `testKefirBatchDeepLink`: Verifies `levain://kefir/<uuid>` parses to `.kefirBatch(id)` under Preparazioni.
  - `testOggiDirectObjectRoutingBypassesHub`: Asserts that `openBake` places a single `.bake(id)` on `preparationsPath` with no `.breadHub` or `.kefirHub` prefix.

- **`LevainUITests/NotificationRouteUITests.swift`**: Updated `testColdLaunchMissingBakeRoute` and `testColdLaunchMissingStarterRoute` to use `app.descendants(matching: .any).matching(identifier: "PreparationsView")` (v2 shell — missing object falls back to `PreparationsView` at empty path, not the old `BakesScrollView`/`StarterScrollView`).

### Verification

- Build: SUCCEEDED
- LevainTests: 36/36 passed (including 2 new AppRouterTests)

---
phase: 17-shell-preparations-hubs
plan: 01
status: complete
---

## Summary

Migrated the root shell from the v1 four-tab layout (Today / Impasti / Starter + Knowledge sheet) to the v2 three-tab layout (Oggi / Preparazioni / Knowledge).

### Changes

- **`Levain/App/AppRouter.swift`**: Replaced `RootTab` enum (`.today/.bakes/.starter/.knowledge`) with v2 cases (`.oggi/.preparazioni/.knowledge`). Removed `bakesPath`, `starterPath`, and `showingKnowledge`. Added `preparationsPath: [PreparationsRoute]`. Added `PreparationsRoute` enum covering `.breadHub`, `.kefirHub`, `.bakesList`, `.formulaList`, `.starterList`, `.bake(UUID)`, `.formula(UUID)`, `.starter(UUID)`. Updated all navigation helpers (`openBake`, `openStarter`, `openFormula`) to target `.preparazioni` with direct-object routing. `openKnowledge` now selects the `.knowledge` tab. `presentBanner` simplified to synchronous call (already on `@MainActor`).
- **`Levain/Features/Shared/RootTabView.swift`**: Replaced four-tab layout with three-tab layout. Knowledge is now a full tab (not a sheet). Preparazioni tab hosts a `NavigationStack` with `PreparationsRoute` destinations. Removed `showingKnowledge` sheet.
- **`Levain/Features/Bakes/BakeDetailView.swift`**: Updated all `router.selectedTab = .bakes` and `router.bakesPath.removeAll()` to target `.preparazioni`/`preparationsPath`.
- **`Levain/Features/Today/TodayView.swift`**: Updated tab references from `.bakes`/`.starter` to `.preparazioni`. Replaced `router.showingKnowledge = true` with `router.openKnowledge(nil)`.
- **`Levain/Features/Bakes/BakesView.swift`**: Updated `NavigationLink(value:)` from `BakesRoute.*` to `PreparationsRoute.*`.
- **`Levain/Features/Starter/StarterView.swift`**: Updated `NavigationLink(value:)` from `StarterRoute.*` to `PreparationsRoute.*`.
- **`Levain/Features/Bakes/FormulaListView.swift`**: Updated `NavigationLink(value:)` from `BakesRoute.*` to `PreparationsRoute.*`.
- **`LevainTests/AppRouterTests.swift`**: Updated all tab expectations to v2 enum values.

### Verification

- Build: SUCCEEDED
- AppRouterTests: 14/14 passed

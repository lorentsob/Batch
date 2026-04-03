---
phase: 17-shell-preparations-hubs
plan: 03
status: complete
---

## Summary

Updated copy and empty-state messaging for the v2 multi-domain shell and added regression UI test coverage.

### Changes

- **`Levain/Features/Today/TodayView.swift`**: Updated first-launch CTA from direct tab navigation to `selectedTab = .preparazioni`. Knowledge link uses `openKnowledge(nil)`. Copy remains action-first.
- **`LevainUITests/LevainUITests.swift`**: Updated smoke tests to v2 tab names (`Oggi`, `Preparazioni`, `Conoscenza`). Old assertions for `Impasti`/`Starter` top-level tabs replaced. `testSeededLaunchHasAtLeastOneResult` now navigates via Preparazioni → BreadHub → Impasti.
- **`LevainUITests/BakesFlowUITests.swift`**: All tests updated with a shared `navigateToBakesView(app:)` helper that routes through Preparazioni → BreadHub → Impasti before asserting. Tests cover same scenarios as before but through the new hierarchy.
- **`LevainUITests/PreparationsFlowUITests.swift`** (new): Regression coverage for the v2 shell navigation surface — Preparazioni tab access, both domain hub cards visible, quick-action buttons, BreadHub navigation to Impasti/Starter, KefirHub empty state.

### Verification

- Build: SUCCEEDED
- AppRouterTests: 14/14 passed
- PersistenceMigrationTests: 9/9 passed

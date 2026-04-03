# Phase 21-03 — Persistence, Routing & Planning Sync

**Status:** Complete
**Date:** 2026-04-03

## What shipped

### Modified app files
- `Levain/Persistence/ModelContainerFactory.swift` — added explicit `FactoryError` cases for persistent store directory creation, persistent container creation, in-memory bootstrap, preview container bootstrap, and preview seeding failures; removed the silent degraded bootstrap path
- `Levain/Services/NotificationService.swift` — `scheduleFridgeReminder` now requires a real starter route and cancels the pending reminder instead of fabricating a fake target when the starter relationship is missing

### Modified planning and codebase files
- `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md` — Phase 21 is marked complete, progress totals are recomputed, and Phase 22 is now the active remaining milestone wave
- `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/CONCERNS.md`, `.planning/codebase/TESTING.md` — refreshed to match the shipped three-tab shell, V4 schema, kefir vertical, fail-fast persistence stance, and current verification surfaces

### Modified test files
- `LevainTests/PersistenceMigrationTests.swift` — `ModelContainerFactoryTests` now cover store-directory failure, container-builder failure, and preview-seed failure surfacing
- `LevainUITests/NotificationRouteUITests.swift` — malformed starter-route coverage remains locked down beside the cold-launch fallback flows

## Key decisions

- Local-first persistence must fail explicitly rather than silently degrading into an in-memory or partially-working state
- Notification routes must resolve to real objects or fail safely; manufacturing random identifiers is not acceptable
- Planning and codebase docs are treated as executable context, not deferred cleanup

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-sim -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-tests -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/ModelContainerFactoryTests` — passed (`4/4`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-router -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/AppRouterTests` — passed (`17/17`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-notify -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/NotificationRouteUITests` — passed (`7/7`)

## Outcome

Phase 21 closes with safer persistence/bootstrap behavior, stricter reminder-route guardrails, and project memory that now describes the shipped app instead of an outdated shell.

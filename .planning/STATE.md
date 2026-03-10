# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-10)

**Core value:** The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** Phase 5 - Today Notifications

## Current Position

Phase: 5 of 8 (Today Notifications)
Plan: 0 of 3 executed in current phase (05-01 through 05-03 planned)
Status: Phase 5 planned - ready to execute 05-01
Last activity: 2026-03-10 - created Phase 5 plan set for Today prioritization, bake reminder orchestration, and notification deep-link routing

Progress: [██████░░░░] 50%

## Performance Metrics

**Velocity:**
- Total plans completed: 12
- Average duration: N/A
- Total execution time: N/A

**By Phase:**

| Phase | Plans Completed | Status |
|-------|-----------------|--------|
| 1 | 3/3 | Complete |
| 2 | 3/3 | Complete |
| 3 | 3/3 | Complete |
| 4 | 3/3 | Complete |

**Recent Trend:**
- Last 5 plans: Phase 3 complete, Phase 4 complete, Phase 5 planned
- Trend: On track

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Phase 1: use XcodeGen to create the native iOS project instead of hand-authoring an `.xcodeproj`
- Phase 1: keep the stack Apple-native with SwiftUI, SwiftData, UserNotifications, and bundled JSON
- Phase 1: unify all scaffold work into a single `Levain` target and source tree
- Phase 2 planning: execute sequentially as 02-01 models/persistence -> 02-02 scheduler/derived logic -> 02-03 unit tests
- Phase 2 planning: standard non-simulator verification uses `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build`
- Phase 2 planning: late and due labels remain derived from timestamps, never persisted as standalone state
- Phase 3 planning: keep formula authoring inside the existing Bakes feature instead of adding a new navigation surface
- Phase 3 planning: step-template editing stays sheet-based so the main formula form remains short and practical
- Phase 3 planning: duplication, derived baker's-math validation, and focused formula tests belong in 03-03 persistence polish
- Phase 4 planning: bake creation stays sheet-based, seeded from the selected formula, and should route directly into bake detail on save
- Phase 4 planning: bake detail is the operational center and each step card should expose only one primary action for its current state
- Phase 4 planning: timers remain advisory helpers while timeline shifting changes only future incomplete steps and preserves planned versus actual timing separately
- Phase 5 planning: Today should be the operational home screen with explicit priority buckets instead of a generic mixed list
- Phase 5 planning: bake reminders must be derived from persisted bake data and resynced from all bake mutation points, not from live timer state
- Phase 5 planning: notification taps, pending URLs, and Today actions should converge on one routing model for bake and starter contexts

### Pending Todos

- Execute `05-01-PLAN.md` to refine Today aggregation, section prioritization, and action-first row components
- Execute `05-02-PLAN.md` to extract deterministic bake reminder planning and unify reminder resync hooks
- Execute `05-03-PLAN.md` to centralize deep-link routing and align Today actions with notification behavior

### Blockers/Concerns

- XCTest verification still depends on local CoreSimulator availability
- Notification deep-link behavior still needs on-device verification after the initial build
- SwiftData model evolution should stay conservative until core flows settle
- Local notification delivery details remain harder to prove in pure unit tests than the route parsing and scheduling helpers around them
- Phase 5 should avoid pulling full starter reminder orchestration forward from Phase 6 beyond the routing and Today-context behavior already needed now

## Session Continuity

Last session: 2026-03-10
Stopped at: Phase 5 planning complete; next action is executing 05-01.
Resume file: .planning/phases/05-today-notifications/05-01-PLAN.md

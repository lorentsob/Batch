# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-10)

**Core value:** The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** Phase 2 - Domain Scheduling

## Current Position

Phase: 2 of 8 (Domain Scheduling)
Plan: 0 of 3 executed in current phase (02-01 through 02-03 planned)
Status: Phase 2 planned - ready to execute 02-01
Last activity: 2026-03-10 - created Phase 2 plan set and validated the generic iOS build command

Progress: [█░░░░░░░░░] 12%

## Performance Metrics

**Velocity:**
- Total plans completed: 3 (Phase 1)
- Average duration: N/A
- Total execution time: N/A

**By Phase:**

| Phase | Plans Completed | Status |
|-------|-----------------|--------|
| 1 | 3/3 | Complete |
| 2 | 0/3 | Planned |

**Recent Trend:**
- Last 5 plans: Phase 1 complete, Phase 2 planned
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

### Pending Todos

- Execute `02-01-PLAN.md` to stabilize the Phase 2 SwiftData schema and seed graph
- Execute `02-02-PLAN.md` to harden backward scheduling and future-step shifting
- Execute `02-03-PLAN.md` to lock in unit coverage around the scheduling rules

### Blockers/Concerns

- XCTest verification still depends on local CoreSimulator availability
- Notification deep-link behavior still needs on-device verification after the initial build
- SwiftData model evolution should stay conservative until core flows settle

## Session Continuity

Last session: 2026-03-10 17:58
Stopped at: Phase 2 planning complete; next action is executing 02-01
Resume file: .planning/phases/02-domain-scheduling/02-01-PLAN.md

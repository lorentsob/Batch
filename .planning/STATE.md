# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-03)

**Core value:** The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** Phase 22 now owns optional culture/grain tracking plus kefir-aware knowledge expansion after Phase 21 closed through `21-01` render-path hardening, `21-02` state-ownership cleanup, and `21-03` persistence/planning sync.

## Current Position

Phase: 22 of 22 (Culture Tracking & Knowledge Expansion)
Plan: 0 of 3 executed in current phase
Status: Ready — Phase 21 is complete in code, targeted regression coverage, and planning memory; the remaining milestone work is the optional culture/knowledge expansion wave
Last activity: 2026-04-03 — completed `21-03` with explicit `ModelContainerFactory` failure surfacing, safe starter reminder routing, and refreshed active/codebase docs

Progress: [█████████████████░░] 86% (18 of 21 v2 plans complete)

## Performance Metrics

- Historical plans completed (archived v1): 43
- Current milestone plans planned: 21
- Current milestone plans completed: 18

| Phase | Plans Completed | Status |
| ----- | --------------- | ------ |
| 17 | 4/4 | Complete |
| 18 | 3/3 | Complete |
| 19 | 4/4 | Complete |
| 20 | 4/4 | Complete |
| 21 | 3/3 | Complete |
| 22 | 0/3 | Not started |

**Recent Trend**

- Last completed plans: 21-01, 21-02, 21-03
- Trend: Phase 21 closed cleanly by reducing repeated operational recomputation, consolidating Knowledge/kefir ownership, and restoring accurate project memory before the final scope wave

## Accumulated Context

### Recent decisions

- `TodayView` now caches a revision-keyed `TodaySnapshot`, while `TodayAgendaBuilder` consumes `TodayAgendaBakeInput` values built from `Bake.OperationalSnapshot` so render paths stop repeatedly resorting bake steps
- `RootTabView` owns the only Knowledge `NavigationStack`, `KnowledgeView` observes `KnowledgeLibrary` directly, and `KefirBatchPresentation.swift` now hosts shared lineage/presentation helpers used by detail, journal, archive, and comparison surfaces
- `ModelContainerFactory` now surfaces explicit `FactoryError` cases for persistent, in-memory, and preview bootstrap failures instead of silently degrading, and `NotificationService.scheduleFridgeReminder` refuses to fabricate fake starter routes
- `.planning` and `.planning/codebase` docs are synced to the shipped three-tab shell, V4 schema, kefir vertical, and current regression suites

### Pending Todos

- Plan and execute `22-01` culture and grain tracking surfaces
- Execute `22-02` kefir-aware knowledge filters, content wiring, and contextual tips
- Execute `22-03` cross-domain UAT, release notes, and milestone closure
- [ui] Formula edit button + lista unificata + ripristino default (2026-04-04-formula-edit-and-unified-list.md)
- [ui] Supporto lievito di birra (2026-04-04-lievito-di-birra-support.md)
- [ui] Auto-conversione quando si cambia tipo lievito (2026-04-04-yeast-switch-auto-conversion.md)

### Blockers/Concerns

- Culture/grain tracking must remain optional-first; kefir stays batch-first operationally
- Notification deep links and denied-permission banners are regression-covered, but final production confidence still benefits from one on-device notification pass
- No dedicated Instruments artifact was stored for `21-01`; performance confidence comes from eliminating repeated recomputation and keeping Today regressions green

## Session Continuity

Last session: 2026-04-03
Stopped at: Closed Phase 21 through `21-03`; next work is Phase 22 planning/execution
Resume file: None

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-29)

**Core value:** The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** Phase 17 is ready to execute, and Phases 18-19 are now planned around cross-domain Oggi, batch-first milk kefir, and storage-aware routing/reminder semantics.

## Current Position

Phase: 17 of 21 (V2 Shell & Preparation Hubs)
Plan: 0 of 4 executed in current phase
Status: Ready to execute — shell, Oggi, and milk-kefir batch-core planning are in place for the next implementation wave
Last activity: 2026-03-29 — planned Phase 19 around the batch model, no-culture-required flows, and storage-aware reminder defaults

Progress: [░░░░░░░░░░░░░░░░] 0% (0 of 17 v2 plans complete)

## Performance Metrics

- Historical plans completed (archived v1): 43
- Current milestone plans planned: 17
- Current milestone plans completed: 0

| Phase | Plans Completed | Status |
| ----- | --------------- | ------ |
| 17 | 0/4 | Planned |
| 18 | 0/3 | Planned |
| 19 | 0/4 | Planned |
| 20 | 0/3 | Not started |
| 21 | 0/3 | Not started |

**Recent Trend**

- Last archived milestone: v1 baseline completed in code, then archived for planning clarity
- Trend: v2 planning started from PRD with explicit shell migration before kefir feature work

## Accumulated Context

### Recent decisions

- V2 keeps the app action-first: `Oggi` stays the operational center even after the product expands beyond bread
- `Preparazioni` becomes the scalable root for domain hubs; bread stays internally split into Impasti, Starter, and Formule
- `Preparazioni` keeps always-visible quick actions and hub cards that remain visible even when empty
- Milk kefir is modeled batch-first; culture/grain tracking is optional and secondary
- Storage mode is a primary kefir dimension that affects state, reminder cadence, and microcopy
- `Oggi` will become a daily dashboard of all active objects, ordered by urgency and time rather than fixed section buckets
- Operational taps from `Oggi` must deep-link directly to the underlying object and bypass the Preparazioni hierarchy
- All UI work must reuse the current `Theme`, design-system components, router conventions, and similar service logic where possible
- Phase 18 will replace fixed Today sections with one ordered Oggi feed whose urgency is expressed on each card
- Phase 18 will ship the cross-domain agenda and routing contract before Phase 19 plugs in persisted kefir batches
- Phase 19 will use `KefirBatch` as the operational core, with `sourceBatchId` in place before richer lineage UI
- Phase 19 will treat room temperature, fridge, and freezer as first-class kefir storage modes with different urgency and reminder semantics
- Phase 19 will allow first-batch creation without a culture prerequisite and defer culture/journal depth to later phases

### Pending Todos

- None captured yet for the new milestone

### Blockers/Concerns

- Phase 17 must preserve existing bread/starter deep links and local-notification entry while the shell changes
- Phase 18 must absorb a third domain cleanly before real kefir persistence exists, so the agenda and router contracts need a temporary kefir-ready no-data path
- Phase 19 must add kefir persistence and reminders without over-generalizing existing bread/starter enums or introducing a fake universal fermentation model
- Archived v1 documents still record manual device-side checks that were never closed; treat them as historical risk, not active phase blockers

## Session Continuity

Last session: 2026-03-29
Stopped at: Planned Phase 19 from the v2 roadmap after Phase 18 Oggi planning
Resume file: None

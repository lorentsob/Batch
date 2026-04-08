# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-08)

**Core value:** The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** Phase 23 is now complete: recipe-to-guide glossary linking, canonical terminology, editorial coverage, and alias-aware Knowledge access are all shipped and verified. The next available work is Phase 22 for optional culture/grain tracking plus kefir-specific knowledge surfacing.

## Current Position

Phase: 23 of 23 (Guides, Glossary & Term Linking)
Plan: 3 of 3 executed in current phase
Status: Complete — the glossary wave now includes canonical article coverage, alias-aware search, inline recipe/guide linking, and passing targeted cross-surface verification
Last activity: 2026-04-08 — completed `23-03` with new bundled guide entries, canonical Knowledge search ranking, stabilized Knowledge search-field UI coverage, and green build/test verification

Progress: [██████████████████░░] 88% (21 of 24 v2 plans complete)

## Performance Metrics

- Historical plans completed (archived v1): 43
- Current milestone plans planned: 24
- Current milestone plans completed: 21

| Phase | Plans Completed | Status |
| ----- | --------------- | ------ |
| 17 | 4/4 | Complete |
| 18 | 3/3 | Complete |
| 19 | 4/4 | Complete |
| 20 | 4/4 | Complete |
| 21 | 3/3 | Complete |
| 22 | 0/3 | Not started |
| 23 | 3/3 | Complete |

**Recent Trend**

- Last completed plans: 23-01, 23-02, 23-03
- Trend: Phase 23 is fully closed; the only remaining v2 delivery wave is the optional Phase 22 kefir-oriented knowledge/culture expansion

## Accumulated Context

### Recent decisions

- `TodayView` now caches a revision-keyed `TodaySnapshot`, while `TodayAgendaBuilder` consumes `TodayAgendaBakeInput` values built from `Bake.OperationalSnapshot` so render paths stop repeatedly resorting bake steps
- `RootTabView` owns the only Knowledge `NavigationStack`, `KnowledgeView` observes `KnowledgeLibrary` directly, and `KefirBatchPresentation.swift` now hosts shared lineage/presentation helpers used by detail, journal, archive, and comparison surfaces
- `ModelContainerFactory` now surfaces explicit `FactoryError` cases for persistent, in-memory, and preview bootstrap failures instead of silently degrading, and `NotificationService.scheduleFridgeReminder` refuses to fabricate fake starter routes
- `.planning` and `.planning/codebase` docs are synced to the shipped three-tab shell, V4 schema, kefir vertical, and current regression suites
- Phase 23 terminology policy is now explicit: one canonical guide entry per concept, Italian-first when natural, English canonical labels only when they are the more stable domain wording, and alias handling instead of mixed-language drift
- `KnowledgeItem` now supports explicit aliases, `KnowledgeLibrary` owns a reusable `glossaryIndex`, and `KnowledgeGlossaryIndex` resolves whole-term Italian/English matches into one canonical article ID
- `GlossaryLinkedText` now exists as the shared read-only rendering primitive that future recipe/guide screens can adopt without duplicating routing logic
- `FormulaDetailView`, `BakeIngredientsView`, and `KnowledgeDetailView` now render glossary-aware inline links through the shared root Knowledge stack, while guide detail excludes self-links to avoid recursive/noisy article copy
- Bundled Knowledge now ships canonical guides for `Levain`, `Appretto`, `Autolisi`, `Pieghe e stretch & fold`, and `Bollitura`, closing the high-value bread glossary backlog found in shipped formulas
- `KnowledgeLibrary.searchResults` now ranks exact title/alias/tag hits ahead of loose summary/content matches, so manual Knowledge search returns the same canonical entries opened by inline glossary links

### Pending Todos

- Plan and execute `22-01` culture and grain tracking surfaces
- Execute `22-02` kefir-aware knowledge filters, content wiring, and contextual tips
- Execute `22-03` verification closeout and planning sync
- [ui] Formula edit button + lista unificata + ripristino default (2026-04-04-formula-edit-and-unified-list.md)
- [ui] Supporto lievito di birra (2026-04-04-lievito-di-birra-support.md)
- [ui] Auto-conversione quando si cambia tipo lievito (2026-04-04-yeast-switch-auto-conversion.md)

### Blockers/Concerns

- Culture/grain tracking must remain optional-first; kefir stays batch-first operationally
- Notification deep links and denied-permission banners are regression-covered, but final production confidence still benefits from one on-device notification pass
- No dedicated Instruments artifact was stored for `21-01`; performance confidence comes from eliminating repeated recomputation and keeping Today regressions green
- Phase 23 closed the bread glossary backlog, but Phase 22 still owns any future kefir-specific knowledge expansion and filtering work
- No dedicated manual small-screen or on-device review artifact was captured for the closed glossary wave; confidence comes from targeted UI coverage plus editorial review rather than a stored visual pass

## Session Continuity

Last session: 2026-04-08
Stopped at: Completed `23-03`; next available work is `22-01` for culture and grain tracking surfaces
Resume file: None

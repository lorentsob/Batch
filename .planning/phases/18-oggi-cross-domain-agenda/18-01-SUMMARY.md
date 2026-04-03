---
phase: 18-oggi-cross-domain-agenda
plan: 01
status: complete
---

## Summary

Refactored `TodayAgendaBuilder` to output a single ranked cross-domain feed with explicit domain and urgency metadata. Added v2 ordering contract tests.

### Changes

- **`Levain/Services/TodayAgendaBuilder.swift`**: Added `Domain` enum (`.pane`, `.starter`, `.kefir`) and `Urgency` enum (`.overdue`/`.warning`/`.active`/`.preview` with `Comparable`) to `TodayAgendaItem`. Added `.kefir` case to `TodayAgendaItem.Kind` (Phase 19 hook). Added `feed: [TodayAgendaItem]` to `TodayAgendaSnapshot` as the canonical v2 surface. Feed is sorted primary by urgency ascending, secondary by `sortDate` ascending. `sections` kept as a backward-compat computed property derived from `feed`. Removed `sortPriority` field in favour of `urgency`.
- **`Levain/Features/Today/TodayView.swift`**: Added `.kefir` case to the `switch item.kind` exhaustive match (renders `EmptyView()` — Phase 19 wires it up).
- **`LevainTests/TodayAgendaBuilderTests.swift`**: Added 4 new v2 ordering contract tests: domain/urgency metadata on feed items, cross-domain ordering (overdue before active regardless of domain), overdue oldest-first tie-breaker, and backward-compat `sections` derivation from `feed`.

### Verification

- Build: SUCCEEDED
- LevainTests: 36/36 passed (15 BakeScheduler + 8 KnowledgeLibrary + 2 KnowledgeLoader + 3 RecipeFormula + 2 AppRouter + 2 PersistenceMigration + 4 TodayAgendaBuilder via Swift Testing + XCTest wrapper)

# Roadmap: Levain v2

## Overview

Archived v1 planning remains in `.planning/milestones/v1-roadmap.md`, `.planning/milestones/v1-requirements.md`, and `.planning/milestones/v1-state.md`. The active roadmap opens the v2 milestone from the multi-fermentation PRD: Levain becomes a planner operativo e journal leggero for domestic fermentations, keeps the current bread/starter workflows intact, and adds a milk kefir vertical through a shared shell that reuses the current design system, routing, and service patterns.

## Active Milestone

**Milestone:** v2 multi-fermentation expansion  
**Primary source:** `docs/levain-prd-v2-multi-fermentations.md`  
**Supporting addendum:** `docs/levain-prd-v2-addendum.md`  
**Delivery rule:** extend the existing app shell, views, models, and services; do not fork a second UI language or invent a generic fermentation abstraction.

## Archived Milestones

- [v1 roadmap](/Users/lorentso/lievito-app/.planning/milestones/v1-roadmap.md)
- [v1 requirements](/Users/lorentso/lievito-app/.planning/milestones/v1-requirements.md)
- [v1 state snapshot](/Users/lorentso/lievito-app/.planning/milestones/v1-state.md)

## Phases

- [ ] **Phase 17: V2 Shell & Preparation Hubs** - Replace the v1 top-level shell with Oggi / Preparazioni / Knowledge, keep direct operational routing intact, add always-visible quick actions, and prepare the additive v2 schema migration.
- [ ] **Phase 18: Oggi Cross-Domain Agenda** - Rebuild Today as a daily operational dashboard for bread, starter, and kefir with card-level urgency, time-based ordering, and direct object routing.
- [ ] **Phase 19: Milk Kefir Batch Core** - Introduce the batch-first milk kefir vertical with local persistence, no-culture-first batch creation, storage-aware state derivation, core screens, and local reminder defaults.
- [ ] **Phase 20: Kefir Lineage & Journal** - Add derived batch genealogy, structured event history, and archive/journal surfaces that support the planner instead of replacing it.
- [ ] **Phase 21: Culture Tracking & Knowledge Expansion** - Add lightweight culture/grain tracking, kefir knowledge filters/content, contextual tips, and final v2 UAT closure.

## Phase Details

### Phase 17: V2 Shell & Preparation Hubs

**Goal**: Reframe the app around the v2 shell while preserving the current bread/starter/formula flows, keeping direct operational routing intact, and preparing the additive v2 schema migration.  
**Depends on**: Archived v1 shell and current bread/starter feature set  
**Requirements**: [SHELL-01, SHELL-02, BREAD-01, SCHEMA-01]  
**Success Criteria**:

1. The app exposes exactly three top-level tabs: `Oggi`, `Preparazioni`, `Knowledge`.
2. Preparazioni shows domain hubs for `Pane e lievito madre` and `Milk kefir`, keeps both cards visible even when empty, and exposes always-visible compact quick actions.
3. Existing bread workflows remain reachable through the bread hub by reusing current views, router logic, and design-system primitives while preserving direct operational entry from existing Today cards.
4. The v1 → v2 SwiftData migration is prepared as an additive VersionedSchema change before kefir models land.

Plans:

- [ ] 17-01: Root shell, tabs, and direct-router migration
- [ ] 17-02: Preparations root, always-visible quick actions, and bread hub composition
- [ ] 17-03: Empty states, shell polish, and regression coverage
- [ ] 17-04: Additive schema migration preparation

### Phase 18: Oggi Cross-Domain Agenda

**Goal**: Make `Oggi` a daily operational dashboard that keeps all active bread, starter, and kefir objects visible with clear urgency and direct navigation.  
**Depends on**: Phase 17  
**Requirements**: [TODAY-01, TODAY-02, TODAY-03, ROUTE-01]  
**Success Criteria**:

1. Oggi shows all active bread, starter, and kefir objects when present, with urgency communicated on the card instead of rigid fixed sections.
2. Ordering is time-based across domains, including explicit tie-breaker rules, with no special priority for bread, starter, or kefir as categories.
3. Taps from Oggi route directly to the underlying bake, starter, or kefir batch detail without traversing the Preparazioni hierarchy.

Plans:

- [ ] 18-01: Dashboard feed model, urgency scoring, and time-based tie-breakers
- [ ] 18-02: Oggi card UI for always-visible active objects
- [ ] 18-03: Direct object routing from Oggi and cross-domain regression coverage

### Phase 19: Milk Kefir Batch Core

**Goal**: Ship the first usable milk kefir vertical around persistent batches, direct-first batch creation, storage-aware routine management, and local reminders.  
**Depends on**: Phase 18  
**Requirements**: [KEFIR-01, KEFIR-02, KEFIR-03, NOTIF-01]  
**Success Criteria**:

1. User can create, view, update, and archive multiple milk kefir batches, including the very first batch without forcing prior culture creation.
2. Batch state, severity, and microcopy derive from routine plus storage mode, using explicit default reminder windows for room temperature, fridge, and freezer behavior.
3. The core batch flow supports one dominant operational action plus quick actions for renew, derive, change state/storage, and archive.

Plans:

- [ ] 19-01: Kefir model, schema, and derived-state foundation
- [ ] 19-02: Batch list, detail, and hub entry UI
- [ ] 19-03: First-batch and manage-batch flows without culture prerequisite
- [ ] 19-04: Storage-aware reminder defaults and automated coverage

### Phase 20: Kefir Lineage & Journal

**Goal**: Add the structured history needed to understand how kefir batches evolve without turning the app into a heavy diary, while keeping bread on the existing bake-history model.  
**Depends on**: Phase 19  
**Requirements**: [LINEAGE-01, JOURNAL-01]  
**Success Criteria**:

1. A new batch can be derived from an existing batch with preserved origin linkage.
2. Structured kefir events capture renewals, storage changes, derivations, notes, and archive events.
3. Journal/archive UI helps compare and understand kefir batches while bread intentionally keeps using the existing bake history instead of gaining a parallel journal.

Plans:

- [ ] 20-01: Batch derivation and provenance UI
- [ ] 20-02: Structured kefir events and journal surfaces
- [ ] 20-03: Archive states, comparison notes, and workflow polish

### Phase 21: Culture Tracking & Knowledge Expansion

**Goal**: Close the v2 milestone with optional culture/grain tracking, kefir knowledge integration, and final cross-domain verification.  
**Depends on**: Phase 20  
**Requirements**: [CULTURE-01, KNOW-01, KNOW-02]  
**Success Criteria**:

1. Culture/grain tracking exists but stays ignorable for users who only manage batches.
2. Knowledge supports kefir-aware filters and contextual tips without splitting into a separate editorial system.
3. Final UAT verifies that bread, starter, and kefir coexist cleanly under the v2 shell.

Plans:

- [ ] 21-01: Culture and grain tracking surfaces
- [ ] 21-02: Knowledge filters, kefir content wiring, and contextual tips
- [ ] 21-03: Cross-domain UAT, release notes, and milestone closure

## Progress: [░░░░░░░░░░░░░░░░] 0% (0 of 17 v2 plans complete)

**Execution Order:**  
Phases execute in numeric order: 17 → 18 → 19 → 20 → 21

| Phase | Plans Complete | Status | Completed |
| ----- | -------------- | ------ | --------- |
| 17. V2 Shell & Preparation Hubs | 0/4 | Planned | - |
| 18. Oggi Cross-Domain Agenda | 0/3 | Planned | - |
| 19. Milk Kefir Batch Core | 0/4 | Planned | - |
| 20. Kefir Lineage & Journal | 0/3 | Not started | - |
| 21. Culture Tracking & Knowledge Expansion | 0/3 | Not started | - |

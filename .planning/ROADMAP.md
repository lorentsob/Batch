# Roadmap: Levain v2

## Overview

Archived v1 planning remains in `.planning/milestones/v1-roadmap.md`, `.planning/milestones/v1-requirements.md`, and `.planning/milestones/v1-state.md`. The active roadmap opens the v2 milestone from the multi-fermentation PRD: Levain becomes a planner operativo e journal leggero for domestic fermentations, keeps the current bread/starter workflows intact, and adds a milk kefir vertical through a shared shell that reuses the current design system, routing, and service patterns.

## Active Milestone

**Milestone:** v2 multi-fermentation expansion  
**Primary source:** `docs/levain-prd-v2-multi-fermentations.md`  
**Supporting addendum:** `docs/levain-prd-v2-addendum.md`  
**Delivery rule:** extend the existing app shell, views, models, and services; do not fork a second UI language or invent a generic fermentation abstraction.
**Current state:** Phases 17 through 21 are complete in code and verification. `21-03` closed the runtime-hardening wave by surfacing explicit persistence failures, guarding starter reminder routes, and syncing the active/codebase docs. Phase 22 is the final open milestone wave and still needs its execution plans.

## Archived Milestones

- [v1 roadmap](/Users/lorentso/lievito-app/.planning/milestones/v1-roadmap.md)
- [v1 requirements](/Users/lorentso/lievito-app/.planning/milestones/v1-requirements.md)
- [v1 state snapshot](/Users/lorentso/lievito-app/.planning/milestones/v1-state.md)

## Phases

- [x] **Phase 17: V2 Shell & Preparation Hubs** - Replace the v1 top-level shell with Oggi / Preparazioni / Knowledge, keep direct operational routing intact, add always-visible quick actions, and prepare the additive v2 schema migration.
- [x] **Phase 18: Oggi Cross-Domain Agenda** - Rebuild Today as a daily operational dashboard foundation with card-level urgency, time-based ordering, and direct-object routing for the shipped domains while keeping the kefir contract ready for Phase 19.
- [x] **Phase 19: Milk Kefir Batch Core** - Introduce the batch-first milk kefir vertical with local persistence, no-culture-first batch creation, storage-aware state derivation, core screens, and local reminder defaults.
- [x] **Phase 20: Kefir Lineage & Journal** - Add derived batch genealogy, structured event history, and archive/journal surfaces that support the planner instead of replacing it.
- [x] **Phase 21: Runtime Hardening & Planning Sync** - Harden `Oggi`, Knowledge, kefir lineage lookups, persistence/routing safety, and `.planning`/codebase memory before new product scope lands.
- [ ] **Phase 22: Culture Tracking & Knowledge Expansion** - Add lightweight culture/grain tracking, kefir knowledge filters/content, contextual tips, and final v2 UAT closure.

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

- [x] 17-01: Root shell, tabs, and direct-router migration
- [x] 17-02: Preparations root, always-visible quick actions, and bread hub composition
- [x] 17-03: Empty states, shell polish, and regression coverage
- [x] 17-04: Additive schema migration preparation

### Phase 18: Oggi Cross-Domain Agenda

**Goal**: Make `Oggi` a daily operational dashboard foundation that keeps active bread and starter objects visible with clear urgency and direct navigation, while preparing the kefir-ready agenda and routing contract for Phase 19.  
**Depends on**: Phase 17  
**Requirements**: [TODAY-01, TODAY-02, TODAY-03, ROUTE-01]  
**Success Criteria**:

1. Oggi shows all active bread and starter objects through one shared feed and card grammar, with a kefir-ready agenda contract that Phase 19 can plug real batches into.
2. Ordering is time-based across domains, including explicit tie-breaker rules, with no special priority for bread, starter, or kefir as categories.
3. Taps from Oggi route directly to the underlying bake or starter detail without traversing the Preparazioni hierarchy, and the router/deep-link surface is kefir-ready for Phase 19 batch detail.

Plans:

- [x] 18-01: Dashboard feed model, urgency scoring, and time-based tie-breakers
- [x] 18-02: Oggi card UI for always-visible active objects
- [x] 18-03: Direct object routing from Oggi and cross-domain regression coverage

### Phase 19: Milk Kefir Batch Core

**Goal**: Ship the first usable milk kefir vertical around persistent batches, direct-first batch creation, storage-aware routine management, and local reminders.  
**Depends on**: Phase 18  
**Requirements**: [KEFIR-01, KEFIR-02, KEFIR-03, NOTIF-01]  
**Success Criteria**:

1. User can create, view, update, and archive multiple milk kefir batches, including the very first batch without forcing prior culture creation.
2. Batch state, severity, and microcopy derive from routine plus storage mode, using explicit default reminder windows for room temperature, fridge, and freezer behavior.
3. The core batch flow supports one dominant operational action plus quick actions for renew, derive, change state/storage, and archive.

Plans:

- [x] 19-01: Kefir model, schema, and derived-state foundation
- [x] 19-02: Batch list, detail, and hub entry UI
- [x] 19-03: First-batch and manage-batch flows without culture prerequisite
- [x] 19-04: Storage-aware reminder defaults and automated coverage

### Phase 20: Kefir Lineage & Journal

**Goal**: Add the structured history needed to understand how kefir batches evolve without turning the app into a heavy diary, while keeping bread on the existing bake-history model.  
**Depends on**: Phase 19  
**Requirements**: [LINEAGE-01, JOURNAL-01]  
**Success Criteria**:

1. A new batch can be derived from an existing batch with preserved origin linkage.
2. Structured kefir events capture renewals, storage changes, derivations, notes, and archive events.
3. Journal/archive UI helps compare and understand kefir batches while bread intentionally keeps using the existing bake history instead of gaining a parallel journal.

Plans:

- [x] 20-01: Batch derivation and provenance UI
- [x] 20-02: Structured kefir events and journal surfaces
- [x] 20-03: Archive states, comparison notes, and workflow polish
- [x] 20-04: Verification closeout, accessibility hardening, and planning sync

### Phase 21: Runtime Hardening & Planning Sync

**Goal**: Harden the shipped v2 shell before any new product scope by addressing runtime cost, state propagation, persistence-safety, and stale planning memory.  
**Depends on**: Phase 20  
**Requirements**: [TODAY-01, ROUTE-01, NOTIF-01]  
**Success Criteria**:

1. `Oggi` and bread operational helpers stop doing repeated render-time scans and sorts while preserving the shipped dashboard semantics.
2. Knowledge navigation/state ownership and kefir lineage lookup surfaces are centralized and regression-covered.
3. Persistence/bootstrap failures and reminder route anomalies become explicit, and active/codebase planning docs match the real three-tab shell and feature map.

Plans:

- [x] 21-01: `Oggi` and bread operational data-flow hardening
- [x] 21-02: Knowledge and kefir state/navigation hardening
- [x] 21-03: Persistence, routing, and planning sync

### Phase 22: Culture Tracking & Knowledge Expansion

**Goal**: Close the v2 milestone with optional culture/grain tracking, kefir knowledge integration, and final cross-domain verification.  
**Depends on**: Phase 21  
**Requirements**: [CULTURE-01, KNOW-01, KNOW-02]  
**Success Criteria**:

1. Culture/grain tracking exists but stays ignorable for users who only manage batches.
2. Knowledge supports kefir-aware filters and contextual tips without splitting into a separate editorial system.
3. Final UAT verifies that bread, starter, and kefir coexist cleanly under the v2 shell.

Plans:

- [ ] 22-01: Culture and grain tracking surfaces
- [ ] 22-02: Knowledge filters, kefir content wiring, and contextual tips
- [ ] 22-03: Cross-domain UAT, release notes, and milestone closure

## Progress: [█████████████████░░] 86% (18 of 21 v2 plans complete)

**Execution Order:**  
Phases execute in numeric order: 17 → 18 → 19 → 20 → 21 → 22

| Phase | Plans Complete | Status | Completed |
| ----- | -------------- | ------ | --------- |
| 17. V2 Shell & Preparation Hubs | 4/4 | Complete | 2026-03-29 |
| 18. Oggi Cross-Domain Agenda | 3/3 | Complete | 2026-03-29 |
| 19. Milk Kefir Batch Core | 4/4 | Complete | 2026-03-30 |
| 20. Kefir Lineage & Journal | 4/4 | Complete | 2026-04-02 |
| 21. Runtime Hardening & Planning Sync | 3/3 | Complete | 2026-04-03 |
| 22. Culture Tracking & Knowledge Expansion | 0/3 | Not started | - |

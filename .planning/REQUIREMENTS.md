# Requirements: Levain v2

**Defined:** 2026-03-29  
**Core Value:** The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.

## Current Milestone Requirements

### Shell & Navigation

- [x] **SHELL-01**: User sees three stable top-level tabs: `Oggi`, `Preparazioni`, `Knowledge`.
- [x] **SHELL-02**: `Preparazioni` shows scalable hub entry cards for `Pane e lievito madre` and `Milk kefir`; the cards stay visible even when empty and the root always exposes compact quick actions for `Nuovo impasto`, `Nuovo starter`, and `Nuovo batch kefir`.
- [x] **BREAD-01**: Existing `Impasti`, `Starter`, and `Formule` workflows remain reachable inside the bread hub without losing current clarity, action-first behavior, or local reminder support.

### Platform & Migration

- [x] **SCHEMA-01**: The v1 → v2 SwiftData migration is prepared as an additive `VersionedSchema` change before any kefir model ships, and no existing bread/starter/user data is modified or dropped.

### Oggi & Routing

- [x] **TODAY-01**: `Oggi` works as a daily operational dashboard where all active bread, starter, and kefir objects remain visible when present, with uniform operational cards and clear domain labels.
- [x] **TODAY-02**: `Oggi` empty/future states and primary CTAs reflect multi-domain use without turning into a descriptive dashboard.
- [x] **TODAY-03**: When urgency is equal, `Oggi` orders objects by time-based tie-breakers across domains with no bread/starter/kefir domain priority.
- [x] **ROUTE-01**: Taps from `Oggi`, deep links, router paths, and local notification entry open the underlying bake, starter, or kefir batch detail directly without traversing the Preparazioni hierarchy.

### Milk Kefir Batch Core

- [x] **KEFIR-01**: User can create and manage multiple milk kefir batches with name, storage mode, routine, and optional use/difference notes, including the first batch without forcing prior culture creation.
- [x] **KEFIR-02**: Kefir batch state derives clearly from last management, expected routine, and storage mode, including paused fridge/freezer states.
- [x] **KEFIR-03**: Batch detail exposes one dominant operational action plus quick actions for renew, derive, change state/storage, and archive.
- [x] **NOTIF-01**: Kefir local reminders respect batch routine and storage mode, defaulting to 24h room temperature, 7-day fridge, and no automatic freezer alerts unless the user schedules reactivation.

### Lineage & Journal

- [x] **LINEAGE-01**: User can derive a new batch from an existing batch and keep origin lineage visible in UI and data.
- [x] **JOURNAL-01**: Kefir journal stores structured lifecycle events without requiring heavy manual journaling for basic use, while bread intentionally continues to use the existing bake history instead of a new dedicated journal.

### Culture & Knowledge

- [ ] **CULTURE-01**: Optional culture/grain tracking exists as a secondary area and stays lightweight when the user ignores grain metrics.
- [ ] **KNOW-01**: Knowledge supports visible domain filters including `Kefir`, `Troubleshooting`, and `Routine` while keeping global search.
- [ ] **KNOW-02**: Contextual knowledge can be surfaced from problematic or overdue bread, starter, and kefir states.

## Deferred / Later

- **WATER-01**: Water kefir support may be considered only after the milk kefir model proves stable.
- **KREC-01**: Kefir recipe or consumption flows stay outside the current operational planner milestone.
- **ANALYTICS-01**: Advanced charts or quasi-scientific metrics stay deferred until a real need emerges.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Water kefir vertical in this milestone | Explicitly excluded by the v2 PRD |
| Generic fermentation abstraction layer | Would weaken domain-specific UX and increase implementation risk |
| Backend, cloud sync, or multi-device support | Conflicts with the offline-first personal-product constraint |
| AI-generated fermentation advice | Not part of the product promise |
| Social/community features | Not relevant to the operational core |
| iPad layout work | Not needed for the current validation target |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SHELL-01 | Phase 17 | Complete |
| SHELL-02 | Phase 17 | Complete |
| BREAD-01 | Phase 17 | Complete |
| SCHEMA-01 | Phase 17 | Complete |
| TODAY-01 | Phase 18 | Complete |
| TODAY-02 | Phase 18 | Complete |
| TODAY-03 | Phase 18 | Complete |
| ROUTE-01 | Phase 18 | Complete |
| KEFIR-01 | Phase 19 | Complete |
| KEFIR-02 | Phase 19 | Complete |
| KEFIR-03 | Phase 19 | Complete |
| NOTIF-01 | Phase 19 | Complete |
| LINEAGE-01 | Phase 20 | Complete |
| JOURNAL-01 | Phase 20 | Complete |
| CULTURE-01 | Phase 22 | Pending |
| KNOW-01 | Phase 22 | Pending |
| KNOW-02 | Phase 22 | Pending |

**Coverage:**
- Current milestone requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0 ✓

**Notes:**
- `TODAY-01`, `ROUTE-01`, and `NOTIF-01` are now complete because Phase 19-04 plugged real kefir batches into the shipped ranked feed, router contract, and local reminder defaults without breaking bread/starter behavior.
- Phase 21 hardened those same shipped requirements without changing scope: `Today` snapshot building now avoids repeated recomputation, router ownership remains centralized in `AppRouter`/`RootTabView`, and fridge reminders no longer synthesize fake starter targets.
- `KEFIR-02` is now complete because the storage-aware derived state shipped in Phase 19-01 is surfaced through the real hub/detail UI in Phase 19-02.
- `KEFIR-01` and `KEFIR-03` are now complete because Phase 19-03 shipped no-culture first-batch creation, persisted manage flows, derive-from-batch, archive, and a real dominant action plus quick-action detail flow.
- `LINEAGE-01` is now complete because `20-01` shipped named source/derived provenance across kefir list/detail surfaces while preserving the existing derive flow and stored source linkage.
- `JOURNAL-01` is now complete because `20-01` shipped additive `KefirEvent` persistence plus automatic event capture, and `20-02` turned that model into readable journal/archive surfaces with deterministic seeded coverage while bread still uses the existing bake history.
- `CULTURE-01`, `KNOW-01`, and `KNOW-02` now map to Phase 22 because Phase 21 has been repurposed for runtime hardening and planning sync discovered during Phase 20 closeout.

---
*Requirements defined: 2026-03-29*  
*Last updated: 2026-04-03 after closing Phase 21 and moving focus to Phase 22*

# Requirements: Levain v2

**Defined:** 2026-03-29  
**Core Value:** The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.

## Current Milestone Requirements

### Shell & Navigation

- [ ] **SHELL-01**: User sees three stable top-level tabs: `Oggi`, `Preparazioni`, `Knowledge`.
- [ ] **SHELL-02**: `Preparazioni` shows scalable hub entry cards for `Pane e lievito madre` and `Milk kefir`; the cards stay visible even when empty and the root always exposes compact quick actions for `Nuovo impasto`, `Nuovo starter`, and `Nuovo batch kefir`.
- [ ] **BREAD-01**: Existing `Impasti`, `Starter`, and `Formule` workflows remain reachable inside the bread hub without losing current clarity, action-first behavior, or local reminder support.

### Platform & Migration

- [ ] **SCHEMA-01**: The v1 → v2 SwiftData migration is prepared as an additive `VersionedSchema` change before any kefir model ships, and no existing bread/starter/user data is modified or dropped.

### Oggi & Routing

- [ ] **TODAY-01**: `Oggi` works as a daily operational dashboard where all active bread, starter, and kefir objects remain visible when present, with uniform operational cards and clear domain labels.
- [ ] **TODAY-02**: `Oggi` empty/future states and primary CTAs reflect multi-domain use without turning into a descriptive dashboard.
- [ ] **TODAY-03**: When urgency is equal, `Oggi` orders objects by time-based tie-breakers across domains with no bread/starter/kefir domain priority.
- [ ] **ROUTE-01**: Taps from `Oggi`, deep links, router paths, and local notification entry open the underlying bake, starter, or kefir batch detail directly without traversing the Preparazioni hierarchy.

### Milk Kefir Batch Core

- [ ] **KEFIR-01**: User can create and manage multiple milk kefir batches with name, storage mode, routine, and optional use/difference notes, including the first batch without forcing prior culture creation.
- [ ] **KEFIR-02**: Kefir batch state derives clearly from last management, expected routine, and storage mode, including paused fridge/freezer states.
- [ ] **KEFIR-03**: Batch detail exposes one dominant operational action plus quick actions for renew, derive, change state/storage, and archive.
- [ ] **NOTIF-01**: Kefir local reminders respect batch routine and storage mode, defaulting to 24h room temperature, 7-day fridge, and no automatic freezer alerts unless the user schedules reactivation.

### Lineage & Journal

- [ ] **LINEAGE-01**: User can derive a new batch from an existing batch and keep origin lineage visible in UI and data.
- [ ] **JOURNAL-01**: Kefir journal stores structured lifecycle events without requiring heavy manual journaling for basic use, while bread intentionally continues to use the existing bake history instead of a new dedicated journal.

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
| SHELL-01 | Phase 17 | In Progress |
| SHELL-02 | Phase 17 | In Progress |
| BREAD-01 | Phase 17 | In Progress |
| SCHEMA-01 | Phase 17 | In Progress |
| TODAY-01 | Phase 18 | Planned |
| TODAY-02 | Phase 18 | Planned |
| TODAY-03 | Phase 18 | Planned |
| ROUTE-01 | Phase 18 | Planned |
| KEFIR-01 | Phase 19 | Planned |
| KEFIR-02 | Phase 19 | Planned |
| KEFIR-03 | Phase 19 | Planned |
| NOTIF-01 | Phase 19 | Planned |
| LINEAGE-01 | Phase 20 | Pending |
| JOURNAL-01 | Phase 20 | Pending |
| CULTURE-01 | Phase 21 | Pending |
| KNOW-01 | Phase 21 | Pending |
| KNOW-02 | Phase 21 | Pending |

**Coverage:**
- Current milestone requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-29*  
*Last updated: 2026-03-29 after archiving the v1 planning baseline and opening the v2 milestone*

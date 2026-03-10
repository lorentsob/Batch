# Roadmap: Levain

## Overview

The roadmap moves from a native iPhone foundation into core baking logic, then adds formula authoring, bake execution, operational Today workflows, starter management, bundled knowledge, and final hardening for internal testing. Each phase delivers a coherent slice that can be validated on-device without requiring backend infrastructure.

## Phases

- [x] **Phase 1: Foundation App Shell** - Bootstrap the repository, native project, persistence container, and navigation shell.
- [x] **Phase 2: Domain Scheduling** - Implement the core models, derived logic, and backward schedule generation.
- [x] **Phase 3: Formula Authoring** - Build reusable formula CRUD with editable default step templates.
- [x] **Phase 4: Bake Creation Execution** - Create and run bakes with step actions, timers, and timeline shifting.
- [x] **Phase 5: Today Notifications** - Build the operational Today experience and local reminder orchestration.
- [x] **Phase 6: Starter Management** - Add starter CRUD, refresh logging, and due-state reminders.
- [x] **Phase 7: Knowledge Tips** - Bundle static knowledge, browse it, and surface contextual tips.
- [ ] **Phase 8: Hardening UAT** - Finish tests, empty states, internal-seed polish, and release readiness.

## Phase Details

### Phase 1: Foundation App Shell
**Goal**: Create the repo, Xcode app, SwiftData container, app environment, and four-tab shell.
**Depends on**: Nothing (first phase)
**Requirements**: [QUAL-01]
**Success Criteria**:
  1. App launches into the final tab structure on iPhone.
  2. SwiftData container and app-level services are configured without placeholder wiring.
  3. Sample data can be seeded for local internal testing.
**Plans**: 3 plans

Plans:
- [x] 01-01: Workspace bootstrap and repository setup
- [x] 01-02: Persistence and environment shell
- [x] 01-03: Navigation and design system skeleton

### Phase 2: Domain Scheduling
**Goal**: Define the domain model, derived-state rules, and backward schedule generation.
**Depends on**: Phase 1
**Requirements**: [BAKE-02, STEP-02, STEP-03, QUAL-02]
**Success Criteria**:
  1. A formula can generate ordered bake steps from a target bake time.
  2. Shifted timelines affect only incomplete future steps.
  3. Derived bake and starter logic is covered by unit tests.
**Plans**: 3 plans

Plans:
- [x] 02-01: Model layer and persistence relationships
- [x] 02-02: Scheduler and derived-logic services
- [x] 02-03: Unit test foundation for core logic

### Phase 3: Formula Authoring
**Goal**: Let the user create and maintain reusable formulas with editable default step templates.
**Depends on**: Phase 2
**Requirements**: [FORM-01, FORM-02, FORM-03, FORM-04]
**Success Criteria**:
  1. User can create, edit, and save formulas locally.
  2. Default steps can be added, edited, deleted, and reordered inside a formula.
  3. Formula values remain coherent enough to drive bake generation.
**Plans**: 3 plans

Plans:
- [x] 03-01: Formula list and detail views
- [x] 03-02: Step template editor flow
- [x] 03-03: Validation and persistence polish

### Phase 4: Bake Creation Execution
**Goal**: Generate real bakes from formulas and support real-time step execution.
**Depends on**: Phase 3
**Requirements**: [BAKE-01, BAKE-03, BAKE-04, STEP-01, STEP-04, STEP-05]
**Success Criteria**:
  1. User can create a bake from a formula and optional starter.
  2. Bake detail shows readable step cards with one primary action per state.
  3. Running a bake preserves planned and actual timing separately.
**Plans**: 3 plans

Plans:
- [x] 04-01: Bake creation flow
- [x] 04-02: Bake detail and step execution
- [x] 04-03: Timer UI and timeline shifting

### Phase 5: Today Notifications
**Goal**: Make the app operational day-to-day with prioritized work and local reminders.
**Depends on**: Phase 4
**Requirements**: [TODAY-01, TODAY-02, TODAY-03, NOTIF-01, NOTIF-02, NOTIF-04]
**Success Criteria**:
  1. Today clearly prioritizes now and overdue items.
  2. Notification scheduling stays aligned with bake timelines.
  3. Notification taps reopen the related bake or starter context.
**Plans**: 3 plans

- [x] 05-01: Today aggregation and prioritization
- [x] 05-02: Bake reminder scheduling and resync
- [x] 05-03: Deep-link routing and action handling

### Phase 6: Starter Management
**Goal**: Support ongoing starter maintenance as a secondary but complete workflow.
**Depends on**: Phase 5
**Requirements**: [STARTER-01, STARTER-02, STARTER-03, STARTER-04, NOTIF-03]
**Success Criteria**:
  1. User can manage multiple starters and refresh logs.
  2. Starter due status derives from simple maintenance data.
  3. Starter reminders surface correctly in Today and notifications.
**Plans**: 3 plans

Plans:
- [x] 06-01: Starter list and detail flows
- [x] 06-02: Refresh logging flow
- [x] 06-03: Starter reminder integration

### Phase 7: Knowledge Tips
**Goal**: Make bundled baking knowledge available both as articles and contextual tips.
**Depends on**: Phase 6
**Requirements**: [KNOW-01, KNOW-02, KNOW-03]
**Success Criteria**:
  1. Knowledge content ships as local JSON and loads offline.
  2. User can browse categories and article details.
  3. Relevant tips appear inside bake and starter workflows.
**Plans**: 3 plans

Plans:
- [x] 07-01: Content schema and JSON bundle
- [x] 07-02: Knowledge tab and article view
- [x] 07-03: Contextual tip surfacing

### Phase 8: Hardening UAT
**Goal**: Improve confidence, first-launch polish, and internal release readiness.
**Depends on**: Phase 7
**Requirements**: [QUAL-03, QUAL-04]
**Success Criteria**:
  1. Baseline automated tests cover the highest-risk workflows.
  2. First launch feels useful even before the user adds their own data.
  3. The app survives relaunch and background or foreground notification paths cleanly.
**Plans**: 3 plans

Plans:
- [ ] 08-01: UI and unit test completion
- [ ] 08-02: Empty states and internal polish
- [ ] 08-03: Release-readiness verification

## Progress: [████████░░] 87.5%

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation App Shell | 3/3 | Complete | 2026-03-10 |
| 2. Domain Scheduling | 3/3 | Complete | 2026-03-10 |
| 3. Formula Authoring | 3/3 | Complete | 2026-03-10 |
| 4. Bake Creation Execution | 3/3 | Complete | 2026-03-10 |
| 5. Today Notifications | 3/3 | Complete | 2026-03-10 |
| 6. Starter Management | 3/3 | Complete | 2026-03-10 |
| 7. Knowledge Tips | 3/3 | Complete | 2026-03-10 |
| 8. Hardening UAT | 0/3 | Planned | 2026-03-10 |

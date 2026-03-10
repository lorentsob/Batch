# Requirements: Levain

**Defined:** 2026-03-10
**Core Value:** The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.

## v1 Requirements

### Formula Management

- [ ] **FORM-01**: User can create a reusable recipe formula with core baker's math fields.
- [ ] **FORM-02**: User can edit, duplicate intent, and reuse a saved recipe formula without rebuilding its defaults from scratch.
- [ ] **FORM-03**: User can manage an editable ordered list of default step templates inside a recipe formula.
- [ ] **FORM-04**: Formula values derive hydration, salt, inoculation, and dough totals consistently for bake creation.

### Bake Lifecycle

- [ ] **BAKE-01**: User can create a bake from a saved recipe formula and a target bake date/time.
- [ ] **BAKE-02**: App generates an initial step timeline backward from the target bake time.
- [ ] **BAKE-03**: User can review and manually adjust bake details after generation.
- [ ] **BAKE-04**: User can view all bakes with their derived status and key schedule information.

### Step Execution

- [ ] **STEP-01**: User can start, complete, or skip an individual bake step.
- [ ] **STEP-02**: App stores actual step timestamps separately from planned schedule values.
- [ ] **STEP-03**: App shows overdue or late as a derived UI label instead of a persisted logical status.
- [ ] **STEP-04**: User can shift the remaining schedule for incomplete future steps by presets or custom minutes.
- [ ] **STEP-05**: User can see timer guidance for a running step without automatic completion.

### Today Experience

- [ ] **TODAY-01**: Today screen prioritizes now or overdue work before upcoming and later items.
- [ ] **TODAY-02**: Each Today item shows a clear title, timing context, state, and one primary action.
- [ ] **TODAY-03**: Today aggregates both bake-step work and starter reminders into one operational view.

### Starter Management

- [ ] **STARTER-01**: User can create and edit multiple starter profiles with core maintenance fields.
- [ ] **STARTER-02**: User can log a starter refresh quickly with essential weights and notes.
- [ ] **STARTER-03**: App derives starter due state from `lastRefresh` and `refreshIntervalDays`.
- [ ] **STARTER-04**: Starter reminders can be enabled or disabled per starter.

### Knowledge

- [ ] **KNOW-01**: App bundles static baking knowledge locally in JSON files.
- [ ] **KNOW-02**: User can browse a lightweight Knowledge tab by category and article.
- [ ] **KNOW-03**: App surfaces contextual knowledge tips inside starter and bake workflows.

### Notifications

- [ ] **NOTIF-01**: App schedules local notifications for upcoming bake-step reminders.
- [ ] **NOTIF-02**: App reschedules future bake notifications when the timeline shifts.
- [ ] **NOTIF-03**: App schedules starter due reminders and a next-day follow-up when still overdue.
- [ ] **NOTIF-04**: Tapping a notification opens the related bake or starter context.

### Quality and Confidence

- [ ] **QUAL-01**: App persists user data locally with SwiftData across relaunches.
- [ ] **QUAL-02**: Core scheduling and derived-state logic have unit-test coverage.
- [ ] **QUAL-03**: Core user journeys have baseline UI test coverage.
- [ ] **QUAL-04**: First launch provides useful empty states and sample seed data for internal testing.

## v2 Requirements

### Backlog

- **BACKLOG-01**: Import or export formulas and bake history
- **BACKLOG-02**: Localization beyond Italian-first MVP
- **BACKLOG-03**: Rich bake journaling, media, and result evaluation
- **BACKLOG-04**: Cross-device sync or backup

## Out of Scope

| Feature | Reason |
|---------|--------|
| Backend or auth | Explicitly excluded by the PRD to keep setup light |
| AI-generated suggestions | Static knowledge is sufficient for MVP validation |
| Community features | Not aligned with the planner-first personal-use core |
| iPad layout support | Increases UI scope without helping the current validation goal |
| Third-party dependency ecosystem | Native Apple APIs are the preferred baseline |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FORM-01 | Phase 3 | Pending |
| FORM-02 | Phase 3 | Pending |
| FORM-03 | Phase 3 | Pending |
| FORM-04 | Phase 3 | Pending |
| BAKE-01 | Phase 4 | Pending |
| BAKE-02 | Phase 2 | Pending |
| BAKE-03 | Phase 4 | Pending |
| BAKE-04 | Phase 4 | Pending |
| STEP-01 | Phase 4 | Pending |
| STEP-02 | Phase 2 | Pending |
| STEP-03 | Phase 2 | Pending |
| STEP-04 | Phase 4 | Pending |
| STEP-05 | Phase 4 | Pending |
| TODAY-01 | Phase 5 | Pending |
| TODAY-02 | Phase 5 | Pending |
| TODAY-03 | Phase 5 | Pending |
| STARTER-01 | Phase 6 | Pending |
| STARTER-02 | Phase 6 | Pending |
| STARTER-03 | Phase 6 | Pending |
| STARTER-04 | Phase 6 | Pending |
| KNOW-01 | Phase 7 | Pending |
| KNOW-02 | Phase 7 | Pending |
| KNOW-03 | Phase 7 | Pending |
| NOTIF-01 | Phase 5 | Pending |
| NOTIF-02 | Phase 5 | Pending |
| NOTIF-03 | Phase 6 | Pending |
| NOTIF-04 | Phase 5 | Pending |
| QUAL-01 | Phase 1 | Pending |
| QUAL-02 | Phase 2 | Pending |
| QUAL-03 | Phase 8 | Pending |
| QUAL-04 | Phase 8 | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0

---
*Requirements defined: 2026-03-10*
*Last updated: 2026-03-10 after roadmap bootstrap*

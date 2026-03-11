# Requirements: Levain

**Defined:** 2026-03-10
**Core Value:** The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.

## v1 Requirements

### Formula Management

- [x] **FORM-01**: User can create a reusable recipe formula with core baker's math fields.
- [x] **FORM-02**: User can edit, duplicate intent, and reuse a saved recipe formula without rebuilding its defaults from scratch.
- [x] **FORM-03**: User can manage an editable ordered list of default step templates inside a recipe formula.
- [x] **FORM-04**: Formula values derive hydration, salt, inoculation, and dough totals consistently for bake creation.

### Bake Lifecycle

- [x] **BAKE-01**: User can create a bake from a saved recipe formula and a target bake date/time.
- [x] **BAKE-02**: App generates an initial step timeline backward from the target bake time.
- [x] **BAKE-03**: User can review and manually adjust bake details after generation.
- [x] **BAKE-04**: User can view all bakes with their derived status and key schedule information.

### Step Execution

- [x] **STEP-01**: User can start, complete, or skip an individual bake step.
- [x] **STEP-02**: App stores actual step timestamps separately from planned schedule values.
- [x] **STEP-03**: App shows overdue or late as a derived UI label instead of a persisted logical status.
- [x] **STEP-04**: User can shift the remaining schedule for incomplete future steps by presets or custom minutes.
- [x] **STEP-05**: User can see timer guidance for a running step without automatic completion.

### Today Experience

- [x] **TODAY-01**: Today screen prioritizes now or overdue work before upcoming and later items.
- [x] **TODAY-02**: Each Today item shows a clear title, timing context, state, and one primary action.
- [x] **TODAY-03**: Today aggregates both bake-step work and starter reminders into one operational view.

### Starter Management

- [x] **STARTER-01**: User can create and edit multiple starter profiles with core maintenance fields.
- [x] **STARTER-02**: User can log a starter refresh quickly with essential weights and notes.
- [x] **STARTER-03**: App derives starter due state from `lastRefresh` and `refreshIntervalDays`.
- [x] **STARTER-04**: Starter reminders can be enabled or disabled per starter.

### Knowledge

- [x] **KNOW-01**: App bundles static baking knowledge locally in JSON files.
- [x] **KNOW-02**: User can browse a lightweight Knowledge tab by category and article.
- [x] **KNOW-03**: App surfaces contextual knowledge tips inside starter and bake workflows.

### Notifications

- [x] **NOTIF-01**: App schedules local notifications for upcoming bake-step reminders.
- [x] **NOTIF-02**: App reschedules future bake notifications when the timeline shifts.
- [x] **NOTIF-03**: App schedules starter due reminders and a next-day follow-up when still overdue.
- [x] **NOTIF-04**: Tapping a notification opens the related bake or starter context.

### Quality and Confidence

- [x] **QUAL-01**: App persists user data locally with SwiftData across relaunches.
- [x] **QUAL-02**: Core scheduling and derived-state logic have unit-test coverage.
- [x] **QUAL-03**: Core user journeys have baseline UI test coverage.
- [x] **QUAL-04**: First launch provides useful empty states and sample seed data for internal testing.
- [x] **QUAL-05**: v1 sign-off is backed by a written audit covering requirement traceability, manual smoke flows, results, and residual risks.
- [x] **QUAL-06**: Repository changes run CI that builds the app and executes the agreed automated test suites on a clean macOS runner.
- [x] **QUAL-07**: Maintainer can trigger a documented CD workflow that produces a signed release candidate or TestFlight-ready build using managed secrets.

## Phase 10 Realignment Requirements

### Operational Home and Navigation

- [ ] **REALIGN-01**: Home groups operational work by bake context and routes into the dedicated bake detail instead of listing raw pending steps one after another.
- [ ] **REALIGN-02**: Cancelled bakes no longer surface pending work in Home and can be safely treated as non-operational items.
- [ ] **REALIGN-03**: Primary navigation foregrounds Home, Impasti, and Starter, while Ricette and Knowledge move to a secondary access pattern.
- [ ] **REALIGN-04**: When no bake is planned or active, Home still offers useful CTAs to create a new impasto and reach Ricette or Knowledge.

### Recipes, Starters, and Authoring

- [ ] **REALIGN-05**: User-facing "Formula" terminology is replaced by "Ricetta", and template recipes are directly usable during bake creation without a mandatory save-as flow.
- [ ] **REALIGN-06**: Recipe type is presented as a category, including renaming "Pagnotta" to "Pane" and "Pezzi" to "Porzioni".
- [ ] **REALIGN-07**: Recipe and starter editors use persistent labels and enough descriptive context that fields remain understandable after values are entered.
- [ ] **REALIGN-08**: Flour mix in recipes and starters uses a structured multi-select with reusable predefined categories plus custom additions.
- [ ] **REALIGN-09**: Recipes can store the selected yeast family, including sourdough via saved starters and common commercial yeasts, with quantity expectations derived accordingly for bake creation.

### Lifecycle, Visual Trust, and Assets

- [ ] **REALIGN-10**: Bake creation and visual states use user-facing semantics and system polish that restore trust, including target usage time wording, destructive cancelled chips, stronger contrast, coherent iconography, deletion of terminal bakes, and working App Icon recognition.

## v2 Requirements

### Backlog

- **BACKLOG-01**: Import or export formulas and bake history
- **BACKLOG-02**: Localization beyond Italian-first MVP
- **BACKLOG-03**: Rich bake journaling, media, and result evaluation
- **BACKLOG-04**: Cross-device sync or backup

## Out of Scope

| Feature                          | Reason                                                         |
| -------------------------------- | -------------------------------------------------------------- |
| Backend or auth                  | Explicitly excluded by the PRD to keep setup light             |
| AI-generated suggestions         | Static knowledge is sufficient for MVP validation              |
| Community features               | Not aligned with the planner-first personal-use core           |
| iPad layout support              | Increases UI scope without helping the current validation goal |
| Third-party dependency ecosystem | Native Apple APIs are the preferred baseline                   |

## Traceability

| Requirement | Phase   | Status                              |
| ----------- | ------- | ----------------------------------- |
| FORM-01     | Phase 3 | Complete                            |
| FORM-02     | Phase 3 | Complete                            |
| FORM-03     | Phase 3 | Complete                            |
| FORM-04     | Phase 3 | Complete                            |
| BAKE-01     | Phase 4 | Complete                            |
| BAKE-02     | Phase 2 | Complete                            |
| BAKE-03     | Phase 4 | Complete                            |
| BAKE-04     | Phase 4 | Complete                            |
| STEP-01     | Phase 4 | Complete                            |
| STEP-02     | Phase 2 | Complete                            |
| STEP-03     | Phase 2 | Complete                            |
| STEP-04     | Phase 4 | Complete                            |
| STEP-05     | Phase 4 | Complete                            |
| TODAY-01    | Phase 5 | Complete                            |
| TODAY-02    | Phase 5 | Complete                            |
| TODAY-03    | Phase 5 | Complete                            |
| STARTER-01  | Phase 6 | Complete                            |
| STARTER-02  | Phase 6 | Complete                            |
| STARTER-03  | Phase 6 | Complete                            |
| STARTER-04  | Phase 6 | Complete                            |
| KNOW-01     | Phase 7 | Complete                            |
| KNOW-02     | Phase 7 | Complete                            |
| KNOW-03     | Phase 7 | Complete                            |
| NOTIF-01    | Phase 5 | Complete                            |
| NOTIF-02    | Phase 5 | Complete                            |
| NOTIF-03    | Phase 6 | Complete                            |
| NOTIF-04    | Phase 5 | Complete                            |
| QUAL-01     | Phase 1 | Complete                            |
| QUAL-02     | Phase 2 | Complete                            |
| QUAL-03     | Phase 8 | Complete                            |
| QUAL-04     | Phase 8 | Complete                            |
| QUAL-05     | Phase 9 | Complete                            |
| QUAL-06     | Phase 9 | Complete (pending first hosted run) |
| QUAL-07     | Phase 9 | Complete (pending signing secrets)  |
| REALIGN-01  | Phase 10 | Planned                            |
| REALIGN-02  | Phase 10 | Planned                            |
| REALIGN-03  | Phase 10 | Planned                            |
| REALIGN-04  | Phase 10 | Planned                            |
| REALIGN-05  | Phase 10 | Planned                            |
| REALIGN-06  | Phase 10 | Planned                            |
| REALIGN-07  | Phase 10 | Planned                            |
| REALIGN-08  | Phase 10 | Planned                            |
| REALIGN-09  | Phase 10 | Planned                            |
| REALIGN-10  | Phase 10 | Planned                            |

**Coverage:**

- v1 + phase 10 realignment requirements: 44 total
- Mapped to phases: 44
- Unmapped: 0

---

_Requirements defined: 2026-03-10_
_Last updated: 2026-03-11 after adding Phase 10 operational UX realignment requirements_

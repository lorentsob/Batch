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

- [x] **REALIGN-01**: Home groups operational work by bake context and routes into the dedicated bake detail instead of listing raw pending steps one after another.
- [x] **REALIGN-02**: Cancelled bakes no longer surface pending work in Home and can be safely treated as non-operational items.
- [x] **REALIGN-03**: Primary navigation foregrounds Home, Impasti, and Starter, while Ricette and Knowledge move to a secondary access pattern.
- [x] **REALIGN-04**: When no bake is planned or active, Home still offers useful CTAs to create a new impasto and reach Ricette or Knowledge.

### Recipes, Starters, and Authoring

- [x] **REALIGN-05**: User-facing "Formula" terminology is replaced by "Ricetta", and template recipes are directly usable during bake creation without a mandatory save-as flow.
- [x] **REALIGN-06**: Recipe type is presented as a category, including renaming "Pagnotta" to "Pane" and "Pezzi" to "Porzioni".
- [x] **REALIGN-07**: Recipe and starter editors use persistent labels and enough descriptive context that fields remain understandable after values are entered.
- [x] **REALIGN-08**: Flour mix in recipes and starters uses a structured multi-select with reusable predefined categories plus custom additions.
- [x] **REALIGN-09**: Recipes can store the selected yeast family, including sourdough via saved starters and common commercial yeasts, with quantity expectations derived accordingly for bake creation.

### Lifecycle, Visual Trust, and Assets

- [x] **REALIGN-10**: Bake creation and visual states use user-facing semantics and system polish that restore trust, including target usage time wording, destructive cancelled chips, stronger contrast, coherent iconography, deletion of terminal bakes, and working App Icon recognition.

## Phase 11 Hardening Requirements

- [x] **REALIGN-11**: Product and AI-facing markdown context use `Levain` consistently with no stale `Lievito` product naming drift.
- [x] **REALIGN-12**: Today separates urgent work, same-day scheduled work, tomorrow preview, and hides work beyond tomorrow.
- [x] **REALIGN-13**: Notification deep links validate live entities and degrade safely for missing bake, missing step, missing starter, cancelled bake, and completed bake routes.

## Phase 12 Userflow v2 Requirements

### Flow-by-Flow Conformance

- [x] **USERFLOW-01**: Today exposes explicit `firstLaunch`, `allClear`, `futureOnly`, and actionable agenda states, with starter urgency and tomorrow preview matching userflow v2.
- [x] **USERFLOW-02**: Bake creation always offers system templates, treats bake name as optional with recipe-name fallback, uses target usage semantics, and follows create-then-edit behavior.
- [x] **USERFLOW-03**: Active bake execution is sequential by default, requires confirmation for out-of-order starts, persists `Fuori ordine` feedback, and limits quick shift to operational steps.
- [x] **USERFLOW-04**: Window-based steps use `flexibleWindowStart` and `flexibleWindowEnd` to drive compact pre-window state, in-window action emphasis, overdue semantics, and soft closing reminders.
- [x] **USERFLOW-05**: Starter refresh stays a fast three-field flow with advanced details collapsed by default and removes the Today starter row immediately after save.
- [x] **USERFLOW-06**: Notification entry validates payloads on warm and cold launch, supports terminal and missing-entity fallbacks, and surfaces a non-blocking notifications-disabled banner.

## Phase 13 and Phase 14 Trust Requirements

- [x] **QUAL-08**: MVP closure is tracked through explicit UAT, copy, micro-UX, and operational sign-off artifacts instead of assuming feature completeness is enough.
- [x] **REALIGN-14**: Home, bake execution, notifications, starter flow, naming, and empty states reach MVP trust quality after post-UAT refinement.
- [x] **REALIGN-15**: The app enforces light-only appearance across tab chrome, navigation chrome, toolbar controls, and modal backgrounds regardless of iOS system dark mode.
- [x] **REALIGN-16**: Bake cancel/delete confirmation appears bottom-aligned and design-system aligned instead of as a misplaced system popover.
- [x] **REALIGN-17**: Cancelling a bake makes the detail experience visibly terminal: archived future steps, no active contextual guidance, and notification cleanup.
- [x] **REALIGN-18**: Timeline rails and danger chips stay visually legible after the design-system refresh, including centered dots and bordered red states.

## v2 Requirements

### Backlog

- **BACKLOG-01**: Import or export formulas and bake history
- **BACKLOG-02**: Localization beyond Italian-first MVP
- **BACKLOG-03**: Rich bake journaling, media, and result evaluation
- **BACKLOG-04**: Cross-device sync or backup

## Out of Scope

| Feature | Reason |
| -------------------------------- | -------------------------------------------------------------- |
| Backend or auth | Explicitly excluded by the PRD to keep setup light |
| AI-generated suggestions | Static knowledge is sufficient for MVP validation |
| Community features | Not aligned with the planner-first personal-use core |
| iPad layout support | Increases UI scope without helping the current validation goal |
| Third-party dependency ecosystem | Native Apple APIs are the preferred baseline |

## Traceability

| Requirement | Phase | Status |
| ----------- | ----- | ------ |
| FORM-01 | Phase 3 | Complete |
| FORM-02 | Phase 3 | Complete |
| FORM-03 | Phase 3 | Complete |
| FORM-04 | Phase 3 | Complete |
| BAKE-01 | Phase 4 | Complete |
| BAKE-02 | Phase 2 | Complete |
| BAKE-03 | Phase 4 | Complete |
| BAKE-04 | Phase 4 | Complete |
| STEP-01 | Phase 4 | Complete |
| STEP-02 | Phase 2 | Complete |
| STEP-03 | Phase 2 | Complete |
| STEP-04 | Phase 4 | Complete |
| STEP-05 | Phase 4 | Complete |
| TODAY-01 | Phase 5 | Complete |
| TODAY-02 | Phase 5 | Complete |
| TODAY-03 | Phase 5 | Complete |
| STARTER-01 | Phase 6 | Complete |
| STARTER-02 | Phase 6 | Complete |
| STARTER-03 | Phase 6 | Complete |
| STARTER-04 | Phase 6 | Complete |
| KNOW-01 | Phase 7 | Complete |
| KNOW-02 | Phase 7 | Complete |
| KNOW-03 | Phase 7 | Complete |
| NOTIF-01 | Phase 5 | Complete |
| NOTIF-02 | Phase 5 | Complete |
| NOTIF-03 | Phase 6 | Complete |
| NOTIF-04 | Phase 5 | Complete |
| QUAL-01 | Phase 1 | Complete |
| QUAL-02 | Phase 2 | Complete |
| QUAL-03 | Phase 8 | Complete |
| QUAL-04 | Phase 8 | Complete |
| QUAL-05 | Phase 9 | Complete |
| QUAL-06 | Phase 9 | Complete (pending first hosted run) |
| QUAL-07 | Phase 9 | Complete (pending signing secrets) |
| REALIGN-01 | Phase 10 | Complete |
| REALIGN-02 | Phase 10 | Complete |
| REALIGN-03 | Phase 10 | Complete |
| REALIGN-04 | Phase 10 | Complete |
| REALIGN-05 | Phase 10 | Complete |
| REALIGN-06 | Phase 10 | Complete |
| REALIGN-07 | Phase 10 | Complete |
| REALIGN-08 | Phase 10 | Complete |
| REALIGN-09 | Phase 10 | Complete |
| REALIGN-10 | Phase 10 | Complete |
| REALIGN-11 | Phase 11 | Complete |
| REALIGN-12 | Phase 11 | Complete |
| REALIGN-13 | Phase 11 | Complete |
| USERFLOW-01 | Phase 12 | Complete (manual UAT pending) |
| USERFLOW-02 | Phase 12 | Complete (manual UAT pending) |
| USERFLOW-03 | Phase 12 | Complete (manual UAT pending) |
| USERFLOW-04 | Phase 12 | Complete (manual UAT pending) |
| USERFLOW-05 | Phase 12 | Complete (manual UAT pending) |
| USERFLOW-06 | Phase 12 | Complete (manual UAT pending) |
| QUAL-08 | Phase 13 | Complete |
| REALIGN-14 | Phase 13 | Complete |
| REALIGN-15 | Phase 14 | Complete (manual visual UAT pending) |
| REALIGN-16 | Phase 14 | Complete (manual visual UAT pending) |
| REALIGN-17 | Phase 14 | Complete (manual visual UAT pending) |
| REALIGN-18 | Phase 14 | Complete (manual visual UAT pending) |

**Coverage:**

- v1 + realignment + userflow requirements: 59 total
- Mapped to phases: 59
- Unmapped: 0

---

_Requirements defined: 2026-03-10_  
_Last updated: 2026-03-14 after adding Phase 13/14 trust and design-system regression requirements_

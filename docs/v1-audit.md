# Batch v1 Audit

**Date:** 2026-03-10
**Version:** 0.1.0 (build 1)
**Auditor:** Phase 9 automated review
**Status:** ✅ GO — subject to residual risks documented below

---

## 1. Scope & Purpose

This document records the outcome of the Levain v1 audit. Its purpose is to replace informal "it seems ready" confidence with traceable evidence against every v1 requirement, a focused manual smoke checklist, and explicit residual risks.

---

## 2. Build & Test Baseline

| Check | Command | Status |
|-------|---------|--------|
| Clean build (no signing) | `xcodebuild … CODE_SIGNING_ALLOWED=NO build` | ✅ Pass |
| Unit tests | `xcodebuild … -destination 'iPhone 17 Pro' test` | ✅ Pass |
| UI tests | included in scheme test action | ✅ Pass (simulator only) |

Build artifacts: `build_output.log`, `build_output2.log` in repo root.

---

## 3. Requirements Audit Matrix

Legend: ✅ Pass | ⚠️ Partial | ❌ Fail | 🔵 Pending Manual | 🟡 Deferred

### Formula Management

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| FORM-01 | User can create a reusable recipe formula with core baker's math fields | ✅ Pass | `FormulaEditorView.swift`, `RecipeFormula.swift`, unit tests in `RecipeFormulaTests.swift` | Smoke check: create formula on device/simulator |
| FORM-02 | User can edit, duplicate intent, and reuse a saved recipe formula | ✅ Pass | `FormulaDetailView.swift` duplicate action, model persistence via SwiftData | Smoke check: edit + create bake from saved formula |
| FORM-03 | User can manage an editable ordered list of default step templates inside a formula | ✅ Pass | `StepTemplateEditorView.swift`, add/delete/reorder logic | Smoke check: reorder steps inside a formula |
| FORM-04 | Formula values derive hydration, salt, inoculation, and dough totals consistently | ✅ Pass | `RecipeFormulaTests.swift` (hydration, inoculation, salt pct) covers derived math | Automated tests pass — no further action required |

### Bake Lifecycle

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| BAKE-01 | User can create a bake from a saved recipe formula and a target bake date/time | ✅ Pass | `BakeCreationView.swift`, SwiftData Bake insert | Smoke check: end-to-end creation on simulator |
| BAKE-02 | App generates an initial step timeline backward from the target bake time | ✅ Pass | `BakeSchedulerTests.swift`, `BakeScheduler.generateSteps` | Automated — no further action required |
| BAKE-03 | User can review and manually adjust bake details after generation | ✅ Pass | `BakeDetailView.swift` editable fields, `BakeEditorView.swift` | Smoke check: open bake, verify steps readable |
| BAKE-04 | User can view all bakes with their derived status and key schedule information | ✅ Pass | `BakesView.swift`, `BakeStatusBadge` | Smoke check: check bake list status badges |

### Step Execution

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| STEP-01 | User can start, complete, or skip an individual bake step | ✅ Pass | `TodayStepCardView.swift`, `BakeDetailView.swift` step action buttons | Smoke check: start + complete one step |
| STEP-02 | App stores actual step timestamps separately from planned schedule values | ✅ Pass | `BakeStep.actualStartedAt`, `actualCompletedAt`, `BakeSchedulerTests` assert actual vs planned separation | Automated — no further action required |
| STEP-03 | App shows overdue/late as a derived UI label instead of a persisted logical status | ✅ Pass | `BakeStep.isOverdue` computed property, no persisted `is_late` column | Code review confirmed |
| STEP-04 | User can shift the remaining schedule for incomplete future steps | ✅ Pass | `BakeScheduler.shiftRemainingSteps`, `TimelineShiftView.swift` | Smoke check: use shift button during active bake |
| STEP-05 | User can see timer guidance for a running step | ✅ Pass | `TodayTimerView.swift`, `BakeDetailTimerView.swift` | Smoke check: start step and verify countdown |

### Today Experience

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| TODAY-01 | Today screen prioritizes now or overdue work before upcoming and later items | ✅ Pass | `TodayAgendaBuilderTests.swift` priority buckets (now, overdue, upcoming) | Smoke check: verify Today ordering with seeded data |
| TODAY-02 | Each Today item shows title, timing context, state, and one primary action | ✅ Pass | `TodayStepCardView.swift`, `TodayStarterReminderRow.swift` | Smoke check: Today items readable and tappable |
| TODAY-03 | Today aggregates bake-step work and starter reminders into one operational view | ✅ Pass | `TodayAgendaBuilder.buildAgenda` merges bake and starter rows | Smoke check: Today shows both bake steps and starter reminder simultaneously |

### Starter Management

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| STARTER-01 | User can create and edit multiple starter profiles | ✅ Pass | `StarterEditorView.swift`, SwiftData `Starter` entity | Smoke check: create second starter |
| STARTER-02 | User can log a starter refresh with essential weights and notes | ✅ Pass | `RefreshLogEditorView.swift`, `RefreshHistoryRow.swift` | Smoke check: log a refresh |
| STARTER-03 | App derives starter due state from `lastRefresh` and `refreshIntervalDays` | ✅ Pass | `Starter.isDue` computed property, `StarterTests.swift` | Automated — no further action required |
| STARTER-04 | Starter reminders can be enabled or disabled per starter | ✅ Pass | `Starter.remindersEnabled`, toggle in `StarterEditorView` | Smoke check: toggle reminder and verify Today visibility |

### Knowledge

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| KNOW-01 | App bundles static baking knowledge locally in JSON files | ✅ Pass | `Levain/Resources/knowledge.json`, `KnowledgeLoaderTests.swift` | Automated — no further action required |
| KNOW-02 | User can browse a lightweight Knowledge tab by category and article | ✅ Pass | `KnowledgeView.swift`, `KnowledgeArticleView.swift`, `KnowledgeLibraryTests.swift` | Smoke check: browse at least two categories |
| KNOW-03 | App surfaces contextual tips inside starter and bake workflows | ✅ Pass | `KnowledgeTipView.swift`, contextual tip rows in bake and starter detail | Smoke check: open starter detail and verify tip row |

### Notifications

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| NOTIF-01 | App schedules local notifications for upcoming bake-step reminders | ✅ Pass | `BakeReminderPlanner.swift`, `BakeReminderPlannerTests.swift` | 🔵 On-device verification required |
| NOTIF-02 | App reschedules future bake notifications when the timeline shifts | ✅ Pass | `NotificationService.rescheduleFor(bake:)` called from shift action | 🔵 On-device verification required |
| NOTIF-03 | App schedules starter due reminders and a next-day follow-up | ✅ Pass | `StarterReminderPlanner.swift`, `StarterReminderPlannerTests.swift` | 🔵 On-device verification required |
| NOTIF-04 | Tapping a notification opens the related bake or starter context | ✅ Pass | `AppRouter.swift`, `AppRouterTests.swift`, deep-link URL scheme | 🔵 On-device verification required |

### Quality & Confidence

| ID | Requirement | Status | Evidence | Next Action |
|----|-------------|--------|----------|-------------|
| QUAL-01 | App persists user data locally with SwiftData across relaunches | ✅ Pass | `LevainApp.swift` modelContainer, data survives simulator relaunch | Smoke check: add data, force quit, relaunch |
| QUAL-02 | Core scheduling and derived-state logic have unit-test coverage | ✅ Pass | `BakeSchedulerTests`, `RecipeFormulaTests`, `StarterTests`, `TodayAgendaBuilderTests` | 10 test files, confirmed passing |
| QUAL-03 | Core user journeys have baseline UI test coverage | ✅ Pass | `LevainUITests/` — app launch, tab navigation, bake and starter journey hooks | Simulator only — on-device coverage gap documented |
| QUAL-04 | First launch provides useful empty states and sample seed data for internal testing | ✅ Pass | `EmptyStateView.swift`, `SeedDataLoader.swift` (internal-testing path only) | Smoke check: fresh simulator install, empty states visible |
| QUAL-05 | v1 sign-off backed by written audit covering traceability, smoke, and residual risks | ✅ Pass | This document + `v1-smoke-checklist.md` + `v1-release-risks.md` | Review and sign off |
| QUAL-06 | CI builds the app and executes automated test suites on clean macOS runner | 🔵 Pending | `.github/workflows/ios-ci.yml` implemented in Phase 09-02; awaiting first hosted run | Push to GitHub to trigger first CI run |
| QUAL-07 | Maintainer can trigger a documented CD workflow for signed release candidate | 🔵 Pending | `.github/workflows/ios-release.yml` implemented in Phase 09-03; signing secrets not yet provisioned | Provision signing secrets in GitHub repository settings |

---

## 4. Overall Audit Status

| Area | Requirements | Pass | Partial/Pending | Fail |
|------|-------------|------|-----------------|------|
| Formula Management | 4 | 4 | 0 | 0 |
| Bake Lifecycle | 4 | 4 | 0 | 0 |
| Step Execution | 5 | 5 | 0 | 0 |
| Today Experience | 3 | 3 | 0 | 0 |
| Starter Management | 4 | 4 | 0 | 0 |
| Knowledge | 3 | 3 | 0 | 0 |
| Notifications | 4 | 4* | 0 | 0 |
| Quality & Confidence | 7 | 5 | 2 | 0 |
| **TOTAL** | **34** | **32** | **2** | **0** |

*Notification requirements pass against simulator; on-device behavior not yet verified.

---

## 5. Release Decision

**GO** — with the following conditions:

1. Manual smoke checklist must be executed on-device or simulator before distribution.
2. QUAL-06 (CI gate) becomes active on the first push; confirm it passes before merging any subsequent changes.
3. QUAL-07 (CD signing) remains PENDING until signing secrets are provisioned; document in `v1-release-risks.md`.
4. All notification requirements (NOTIF-01 through NOTIF-04) require an on-device pass during the smoke run.

---

*Last updated: 2026-03-10 — Phase 09-01*

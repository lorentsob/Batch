# Phase 12 Discovery

**Date:** 2026-03-12  
**Depth:** Standard  
**Purpose:** Audit the updated userflow v2 against the current app, identify flow gaps, and record implementation evidence.

## Audit Summary

The attached HTML v2 introduced six explicit operational flows and several stronger UX expectations that were only partially represented in the codebase after Phase 11. The primary gaps were:

1. Today still derived emptiness mostly from item count instead of explicit operational modes.
2. Bake creation still allowed the UX to feel recipe-name mandatory and did not expose template availability clearly enough.
3. Active bake execution allowed out-of-order starts too casually and lacked persistent feedback.
4. Window-based steps did not use `flexibleWindowStart` / `flexibleWindowEnd` as the real urgency model.
5. Starter refresh still behaved correctly in domain terms, but the form and Today removal loop were not as explicit as the flow demanded.
6. Notification routing covered some stale-ID cases, but not the full v2 matrix including cold launch and denied notifications UX.

## Conformance Matrix

| Flow node | Status | Code evidence | Automated evidence | Manual UAT hook |
| --- | --- | --- | --- | --- |
| Today exposes `firstLaunch`, `allClear`, `futureOnly`, actionable agenda | Implemented | `Levain/Services/TodayAgendaBuilder.swift`, `Levain/Features/Today/TodayView.swift` | `LevainTests/TodayAgendaBuilderTests.swift`, `LevainUITests/TodayFlowUITests.swift` | Test 1 in `12-UAT.md` |
| Bake creation keeps templates always available, optional bake name, create-then-edit | Implemented | `Levain/Features/Bakes/BakeCreationView.swift`, `Levain/Services/BakeScheduler.swift`, `Levain/Features/Bakes/BakesView.swift` | `LevainTests/BakeSchedulerTests.swift`, `LevainUITests/BakesFlowUITests.swift` | Test 2 in `12-UAT.md` |
| Active bake execution is sequential by default, override confirmed, `Fuori ordine` persisted | Implemented | `Levain/Models/BakeStep.swift`, `Levain/Features/Bakes/BakeStepDetailView.swift`, `Levain/Features/Bakes/BakeStepCardView.swift` | `LevainTests/BakeSchedulerTests.swift` | Test 3 in `12-UAT.md` |
| Window-based steps use window open / close semantics with soft reminder | Implemented | `Levain/Models/BakeStep.swift`, `Levain/Services/BakeReminderPlanner.swift`, `Levain/Services/TodayAgendaBuilder.swift` | `LevainTests/BakeSchedulerTests.swift`, `LevainTests/BakeReminderPlannerTests.swift` | Test 4 in `12-UAT.md` |
| Starter refresh is a fast 3-field flow and removes Today row immediately after save | Implemented | `Levain/Features/Starter/RefreshLogView.swift`, `Levain/Features/Today/TodayView.swift` | `LevainUITests/TodayFlowUITests.swift` | Test 5 in `12-UAT.md` |
| Notification routes validate live entities, handle cold launch, terminal states, denied notifications | Implemented | `Levain/App/AppRouter.swift`, `Levain/Features/Shared/RootTabView.swift`, `Levain/App/AppLaunchOptions.swift`, `Levain/Services/NotificationService.swift` | `LevainTests/AppRouterTests.swift`, `LevainUITests/NotificationRouteUITests.swift`, `LevainUITests/LifecycleUITests.swift` | Test 6 in `12-UAT.md` |

## Closed Gaps

- Today now distinguishes first launch, all-clear, future-only, and active agenda instead of inferring every case from aggregate count.
- Future-only Today now shows the next upcoming action with a coherent CTA into Impasti.
- Bake name is optional and safely falls back to the recipe name.
- System templates are visible and selectable even with zero saved recipes.
- Step execution now asks for explicit confirmation before starting out of sequence and marks the step `Fuori ordine`.
- Quick shift is limited to operational running/overdue contexts.
- Window-based urgency now opens on `flexibleWindowStart`, goes late only after `flexibleWindowEnd`, and adds a soft closing reminder.
- Denied-notification and stale-entity routes now produce deterministic, non-blocking UI feedback.

## Remaining Human Checks

- Real on-device notification delivery timing
- Perceived UX of the window-close reminder
- End-to-end tactile feel of the six flows outside simulator automation

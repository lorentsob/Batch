# Architecture

## Summary

Levain is a single-target iPhone app built with SwiftUI, SwiftData, UserNotifications, and bundled JSON content. The shipped v2 shell has exactly three top-level tabs: `Oggi`, `Preparazioni`, and `Conoscenza`. Bread/starter and milk kefir share shell and infrastructure, but keep separate domain models, reminder logic, and presentation helpers.

## Layers

### App composition

- `Levain/App/LevainApp.swift` boots the app and injects the SwiftData container
- `Levain/App/AppEnvironment.swift` owns app-scoped services (`NotificationService`, `KnowledgeLibrary`) plus transient banner state
- `Levain/App/AppRouter.swift` owns selected tab plus `preparationsPath` / `knowledgePath` and enforces direct-object deep linking
- `Levain/Features/Shared/RootTabView.swift` renders the three-tab shell and owns the only `NavigationStack`s for `Preparazioni` and `Knowledge`

### Persistence and models

- Persisted `@Model` types live in `Levain/Models/`: `Starter`, `StarterRefresh`, `RecipeFormula`, `Bake`, `BakeStep`, `AppSettings`, `KefirBatch`, and `KefirEvent`
- Non-persistent editorial content remains `KnowledgeItem` plus related enums/value types
- `Levain/Persistence/LevainSchema.swift` exposes live schema V4 with additive migration stages `V1 -> V3 -> V4`
- `Levain/Persistence/ModelContainerFactory.swift` is the only container bootstrap entry and now surfaces explicit `FactoryError` cases for store/bootstrap failures
- `Levain/Persistence/SeedDataLoader.swift` owns deterministic preview/test seeding and launch-harness scenarios

### Services

- `BakeScheduler` and `TodayAgendaBuilder` derive bread timing plus cross-domain `Oggi` state
- `NotificationService`, `BakeReminderPlanner`, `StarterReminderPlanner`, and `KefirReminderPlanner` own local reminder planning and deep-link payloads
- `KnowledgeLoader` and `KnowledgeLibrary` load bundled `knowledge.json` into an observable in-memory store
- `KefirEventRecorder` plus `Levain/Features/Kefir/KefirBatchPresentation.swift` support typed kefir history and shared lineage/presentation summaries
- `DateFormattingService` centralizes Italian-facing date/time copy

### Features

- `Levain/Features/Today/` is the operational dashboard; `TodayView` caches a revision-keyed `TodaySnapshot` built from `Bake.OperationalSnapshot`
- `Levain/Features/Preparations/` hosts the root domain hubs and always-visible quick actions
- `Levain/Features/Bakes/` and `Levain/Features/Starter/` preserve the existing bread/starter flows under the bread hub
- `Levain/Features/Kefir/` contains the batch-first kefir vertical: hub, list/detail/editor/manage, journal, archive, comparison, and shared presentation helpers
- `Levain/Features/Knowledge/` is bundled article browsing and article detail

## Navigation and Data Flow

- `Oggi` never owns object detail navigation; taps route through `AppRouter` directly to bake, starter, or kefir detail under `Preparazioni`
- `KnowledgeView` does not create its own `NavigationStack`; `RootTabView` owns article navigation through `KnowledgeRoute`
- Notification and deep-link routes use `levain://` URLs parsed by `AppRouter`
- `TodayAgendaBuilder` accepts `TodayAgendaBakeInput` so derived bake state is computed once per model update rather than repeatedly inside the SwiftUI tree
- Kefir lineage-heavy surfaces share `KefirLineageIndex` and `KefirBatchLineageSummary` from `KefirBatchPresentation.swift`

## Runtime Safety

- Persistent store setup is fail-fast: bootstrap errors surface explicitly and the app does not silently fall back to a degraded in-memory store
- Fridge reminders require a real `StarterRefresh -> Starter` relationship; missing targets cancel pending reminders instead of inventing random IDs
- Seed data remains opt-in via launch options, previews, or test harnesses; normal first launch does not auto-seed

## Residual Risks

- Phase 22 adds more schema and knowledge scope, so additive migration discipline must continue
- Notification delivery/tap behavior is well covered in simulator tests but still benefits from a final on-device pass
- No dedicated Instruments artifact is stored for the Phase 21 `Oggi` hardening pass

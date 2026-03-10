# Architecture

## Summary

Levain is a single-target native iPhone app built with SwiftUI and SwiftData. The architecture is feature-oriented at the UI layer, model-centric for persisted state, and service-based for scheduling, notifications, and bundled knowledge loading.

## Layers

### App Layer

- Location: `Levain/App/`
- Contains: `LevainApp.swift`, `AppRouter.swift`, `AppEnvironment.swift`
- Responsibility: app bootstrap, root navigation state, shared app services, model container wiring

### Domain Models

- Location: `Levain/Models/`
- Contains: `Starter`, `StarterRefresh`, `RecipeFormula`, `Bake`, `BakeStep`, `AppSettings`, enums, `KnowledgeItem`
- Responsibility: persisted baking and starter state plus lightweight non-persistent knowledge content

### Services

- Location: `Levain/Services/`
- Contains: `BakeScheduler`, `NotificationService`, `TodayAgendaBuilder`, `KnowledgeLoader`, `DateFormattingService`
- Responsibility: business logic, schedule generation, derived today agenda items, local notifications, bundled JSON reading

### Persistence

- Location: `Levain/Persistence/`
- Contains: `ModelContainerFactory.swift`, `SeedDataLoader.swift`
- Responsibility: schema creation, preview container creation, sample seed data for internal testing

### Features

- Location: `Levain/Features/`
- Shared: root tab shell, tip components
- Today: operational action list
- Bakes: formulas, bake generation, step execution
- Starter: starter CRUD and refresh logging
- Knowledge: bundled article browsing

### Resources

- Location: `Levain/Resources/` and `Levain/Assets.xcassets`
- Responsibility: bundled JSON content and asset catalog data

## Navigation

- Root tab state lives in `AppRouter`
- Four root tabs: `Today`, `Bakes`, `Starter`, `Knowledge`
- Each tab owns its own `NavigationStack`
- Route enums keep cross-tab deep links simple and local

## Persistence and Data Flow

- SwiftData `@Model` types are the source of truth for operational data
- `SeedDataLoader` inserts one starter, one formula, and one bake for first-launch validation
- `BakeScheduler` generates steps backward from target bake time and can shift incomplete future steps
- `NotificationService` derives all local reminders from persisted bakes and starters

## Current Risks

- Full build verification still depends on running Apple build tooling outside the Codex sandbox
- SwiftData migrations should stay conservative until the core model stabilizes

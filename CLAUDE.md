---
description: 
alwaysApply: true
---
# CLAUDE.md — Batch

This file is the stable AI contributor context for Batch. It is derived from `docs/levain-prd-complete-v2.md`, the `.planning/` folder, and the current state of the codebase.

---

## What This App Is

A native iPhone-only planner for real-world fermentation execution. The public product name is **Batch**; internal targets, modules, and identifiers may still use `Levain` until a dedicated technical rename wave.

This is **not** a recipe manager, not a social app, not an AI assistant. It is a focused operational tool for one person.

---

## Platform & Stack

| Concern | Choice |
|---|---|
| Platform | iPhone only — no iPad, no Mac Catalyst |
| OS target | iOS 26 minimum (acceptable for personal/internal use) |
| Language | Swift 6.0 (`SWIFT_STRICT_CONCURRENCY: complete`) |
| UI | SwiftUI |
| Persistence | SwiftData (`@Model`) |
| Notifications | UserNotifications — local only |
| Knowledge content | Bundled JSON (`Resources/knowledge.json`) |
| Third-party libs | None — Apple-native only |
| Backend | None |
| Auth | None |
| Cloud sync | None |

Bundle ID: `com.lorentso.levain`
Display name: `Batch`
Internal target/module name: `Levain`
Version: `0.1.0`

---

## Project Structure

```
Levain/
├── App/
│   ├── LevainApp.swift           # @main entry, injects container + environment
│   ├── AppRouter.swift           # Navigation / deep-link routing
│   └── AppEnvironment.swift      # ObservableObject: NotificationService, KnowledgeLibrary
├── Models/
│   ├── Starter.swift
│   ├── StarterRefresh.swift
│   ├── RecipeFormula.swift
│   ├── FormulaStepTemplate.swift
│   ├── Bake.swift
│   ├── BakeStep.swift
│   ├── KnowledgeItem.swift       # Codable only, not SwiftData
│   ├── AppSettings.swift
│   └── DomainEnums.swift         # BakeType, StepStatus, BakeStepType, etc.
├── Features/
│   ├── Today/         TodayView.swift
│   ├── Bakes/         BakesView.swift
│   ├── Starter/       StarterView.swift
│   ├── Knowledge/     KnowledgeView.swift
│   └── Shared/        RootTabView.swift
├── Services/
│   ├── NotificationService.swift
│   ├── BakeScheduler.swift
│   ├── KnowledgeLoader.swift      # → KnowledgeLibrary
│   ├── DateFormattingService.swift
│   └── TodayAgendaBuilder.swift
├── Persistence/
│   ├── ModelContainerFactory.swift
│   └── SeedDataLoader.swift
├── Resources/
│   └── knowledge.json
└── DesignSystem/
    ├── Theme.swift
    ├── Components/
    │   ├── EmptyStateView.swift
    │   ├── SectionCard.swift
    │   └── StateBadge.swift
    └── Extensions/
        └── Date+Levain.swift
```

Also in repo root:
- `project.yml` — XcodeGen spec
- `docs/levain-knowledge.md` — editorial source for knowledge.json
- `.planning/` — roadmap, requirements, state, phase plans

---

## Navigation

Four-tab structure (defined in `RootTabView.swift`):

1. **Today** — operational home, action-first
2. **Bakes** — bake list and detail
3. **Starter** — starter management
4. **Knowledge** — lightweight browse tab

---

## Data Model

### SwiftData entities (persisted)

#### Starter
Fields: `name`, `type`, `hydration`, `flourMix`, `containerWeight`, `storageMode`, `refreshIntervalDays`, `remindersEnabled`, `lastRefresh`, `notes`
Relationships: → many `StarterRefresh`, → many `Bake`

Derived UI state (computed, not persisted):
- `ok` — refreshed within interval
- `due today` — due date is today
- `overdue` — past due date

#### StarterRefresh
Fields: `starterId`, `dateTime`, `flourWeight`, `waterWeight`, `starterWeightUsed`, `ratioText`, `putInFridgeAt`, `notes`
Advanced (optional): `ambientTemp`, `photoUri`

#### RecipeFormula
Fields: `id`, `name`, `type`, `totalFlourWeight`, `totalWaterWeight`, `hydrationPercent`, `saltWeight`, `saltPercent`, `inoculationPercent`, `servings`, `notes`, `flourMix`
Relationship: → many `FormulaStepTemplate` (cascade delete), → many `Bake`

#### FormulaStepTemplate
The editable default step list inside a formula. Used to generate `BakeStep` instances when creating a bake.

#### Bake
Fields: `id`, `name`, `typeRaw`, `dateCreated`, `targetBakeDateTime`, `inoculationPercent`, `totalFlourWeight`, `totalWaterWeight`, `totalDoughWeight`, `hydrationPercent`, `servings`, `notes`, `isCancelled`
Relationships: `formula: RecipeFormula?`, `starter: Starter?`, `steps: [BakeStep]` (cascade delete)

Derived status (computed from steps):
```
cancelled   → isCancelled == true
completed   → all steps .done or .skipped (and non-empty)
in_progress → any step is .running OR has actualStart
planned     → default
```

#### BakeStep
Fields: `id`, `orderIndex`, `typeRaw`, `nameOverride`, `descriptionText`, `plannedStart`, `plannedDurationMinutes`, `flexibleWindowStart?`, `flexibleWindowEnd?`, `actualStart?`, `actualEnd?`, `reminderOffsetMinutes`, `temperatureRange`, `volumeTarget`, `statusRaw`, `notes`, `photoURI`
Relationship: `bake: Bake?`

Step status values: `pending | running | done | skipped`

Critical rules:
- Steps **never auto-complete** — the user controls state
- `overdue` / `late` is a **derived UI label** only, not a persisted status
- `actualStart` and `actualEnd` are stored separately from planned values
- `.start()`, `.complete()`, `.skip()` are convenience mutators on the model

#### AppSettings
Global preferences — persisted via SwiftData.

### Non-persisted

#### KnowledgeItem (Codable only)
Loaded from `knowledge.json` at runtime by `KnowledgeLibrary`. Fields: `id`, `title`, `category`, `tags`, `summary`, `content`, `relatedStepTypes`, `relatedStarterStates`.

---

## Core Enums (DomainEnums.swift)

- `BakeType` — type of bake (e.g., `.paneBase`, `.focaccia`, `.custom`)
- `StepStatus` — `.pending`, `.running`, `.done`, `.skipped`
- `BakeStepType` — named step types (`.autolyse`, `.bulkFermentation`, `.shaping`, `.baking`, `.custom`, etc.) each with a `.title` string
- Storage mode for starters

---

## Services

### BakeScheduler
Generates `BakeStep` instances from a `RecipeFormula` working **backward** from `targetBakeDateTime`. Also handles **timeline shifting**: moves `plannedStart` forward on all future non-terminal steps by a given number of minutes.

### NotificationService
Schedules and cancels local `UNNotificationRequest` entries:
- Step reminders (fire at `plannedStart - reminderOffsetMinutes`)
- Starter due reminders (fire on due date, +1 day follow-up if still overdue)
- Must reschedule on every timeline shift
- Notification tap → deep-link into correct bake or starter via `AppRouter`

### TodayAgendaBuilder
Aggregates and prioritizes items for the Today view:
1. Now / overdue items
2. Upcoming steps today
3. Starter refreshes due
4. Later / tomorrow

### KnowledgeLoader / KnowledgeLibrary
Reads `knowledge.json` from the app bundle. Exposed as `AppEnvironment.knowledgeLibrary`.

### DateFormattingService
Shared date/time formatting utilities used across views.

---

## Key Product Behaviors

### Step execution flow
1. Step starts as `.pending`
2. Tap **Start** → `.running`, `actualStart` recorded
3. Tap **Complete** → `.done`, `actualEnd` recorded
4. Tap **Skip** → `.skipped`
5. If time has elapsed but step not completed → show "overdue" UI label; status stays `.pending`

### Timeline shift
From any step: user picks `+15 min`, `+30 min`, `+1h`, or `Custom`.
Effect: shifts `plannedStart` of all **future, non-terminal** steps.
After shift: `NotificationService` must **reschedule** affected notifications.

### Bake creation from formula
1. Pick formula
2. Set `targetBakeDateTime`
3. Optionally link a starter
4. `BakeScheduler` generates steps backward from target time using formula's `defaultSteps`
5. User can edit the resulting schedule before confirming

### Starter reminder logic
`dueDate = lastRefresh + refreshIntervalDays`
- Schedule notification for due date
- If no refresh logged by next day → schedule follow-up notification
- Both notifications are cancelled and rescheduled whenever `lastRefresh` changes

---

## UX Principles

- **Action-first, not dashboard-first** — every screen surfaces the next action
- **One primary action per step card** — Start / Complete / View details / Shift timeline
- **Progressive disclosure** — secondary and advanced fields live in expandable sections or detail screens; never in the core flow
- **Minimal onboarding** — first launch shows: `New bake` CTA, `Add starter` secondary CTA, `Explore tips` tertiary CTA
- **Italian-first** — labels, seed data, and knowledge content are in Italian for MVP

---

## Architecture Rules

- **No heavy patterns** — no VIPER, no Combine pipelines, no elaborate DI containers
- **Folder-by-feature** for Views; **flat Models/** for data; **Services/** for logic
- **@MainActor** on `AppEnvironment` and services that update UI
- **SwiftData queries** done at the view level with `@Query` or passed down via environment
- **No runtime state machines** — derive status from data fields; never persist redundant computed state
- **Keep AI-generated code predictable** — one clear responsibility per file; avoid clever abstractions

---

## Roadmap & Current Status

13 phases, **Phase 13 — MVP Closure completa** (39/39 piani eseguiti).

| # | Phase | Status |
|---|---|---|
| 1 | Foundation App Shell | ✅ Complete |
| 2 | Domain Scheduling | ✅ Complete |
| 3 | Formula Authoring | ✅ Complete |
| 4 | Bake Creation & Execution | ✅ Complete |
| 5 | Today & Notifications | ✅ Complete |
| 6 | Starter Management | ✅ Complete |
| 7 | Knowledge & Tips | ✅ Complete |
| 8 | Hardening & UAT | ✅ Complete |
| 9 | V1 Audit & CI/CD | ✅ Complete |
| 10 | Operational UX Realignment | ✅ Complete |
| 11 | Naming, Today, Router Hardening | ✅ Complete |
| 12 | Userflow UX Conformance | ✅ Complete |
| 13 | MVP Closure | ✅ Complete |

**Prossimo step:** UAT su device fisico (iPhone reale). Vedere `.planning/phases/13-mvp-closure/13-UAT.md`.

See `.planning/phases/` for detailed plan files per phase.

---

## What Is Already Implemented (Phase 1 scaffold)

All files exist but views are stubs. The following is production-quality scaffold:

- `LevainApp.swift` — `@main`, injects `ModelContainer` + `AppEnvironment` + `AppRouter`
- `AppEnvironment.swift` — holds `NotificationService` and `KnowledgeLibrary`
- `ModelContainerFactory.swift` — creates the SwiftData container
- All `@Model` classes in `Models/` — `Bake`, `BakeStep`, `Starter`, `StarterRefresh`, `RecipeFormula`, `FormulaStepTemplate`, `AppSettings`
- `DomainEnums.swift` — all shared enums
- `Services/` — `BakeScheduler`, `NotificationService`, `TodayAgendaBuilder`, `KnowledgeLoader`, `DateFormattingService` (scaffolded)
- `DesignSystem/` — `Theme.swift`, `EmptyStateView`, `SectionCard`, `StateBadge`, `Date+Levain`
- `Features/Shared/RootTabView.swift` — four-tab structure
- Stub views for Today, Bakes, Starter, Knowledge
- `SeedDataLoader.swift`
- `knowledge.json` (in Resources)
- `project.yml` (XcodeGen)

---

## Working with This Codebase (AI Instructions)

1. **Read this file AND `UX-SPEC.md` before starting any UI task.** They are the joint canonical context.
2. **Generate feature by feature.** Do not attempt to generate the entire app in one pass.
3. **Never change model names or field names without noting it here.** Model stability is critical for SwiftData migrations.
4. **Always check the current phase.** Only implement what the current phase requires — see `.planning/STATE.md` and `.planning/phases/`.
5. **Derive, don't persist derived state.** Never store computed fields that can be recalculated from the raw model.
6. **Keep views lean.** Logic goes in Services or model methods, not in SwiftUI body closures.
7. **Use `@Query` at the top view level** and pass data down — avoid issuing queries deep in the hierarchy.
8. **After any timeline shift**, always call `NotificationService` to reschedule notifications.
9. **Timers are UI helpers only** — reliability with app closed comes from persisted data + local notifications.
10. **Advanced fields** (temperatureRange, volumeTarget, photoURI, ambientTemp, etc.) must live behind expandable sections or detail screens — never visible in the primary flow.

---

## Git Workflow Rules

Full reference: `docs/levain-ios-git-workflow.md`

### Branch discipline
- **Never commit or push directly to `main` or `develop`.** All work goes through feature branches + PR targeting `develop`.
- **One branch = one objective.** A branch must not mix feature + bugfix + refactor. If the scope drifts, stop and split.
- **Branch naming:** `feature/`, `fix/`, `refactor/`, `chore/`, `docs/`, `test/` + descriptive slug (e.g. `feature/sourdough-timer`, `fix/recipe-detail-crash`).
- **Start every branch from an up-to-date `develop`:** `git switch develop && git pull origin develop && git switch -c <branch>`.
- **`develop` → `main`** only when the milestone is stable and ready for production.

### Commits
- Small, focused, descriptive commits. No `"fix stuff"` or `"updates"`.
- **Stage specific files** — never `git add .` or `git add -A` (risk of committing caches, .env, temp files).
- **Build verification:** run `xcodebuild` build before pushing. If the build fails, do not push.

### Pull Requests
- Every branch merges via **PR to `develop`** — no exceptions, even for small changes.
- PR must include: what changed, why, how to test, risks.
- **Squash merge** on PRs to keep history clean (one commit per feature/fix).
- After merge: delete the remote branch, switch to `develop`, pull.

### CI cache — periodic clean build
The CI caches DerivedData keyed on Swift sources + `project.yml`. This speeds up incremental builds but can accumulate stale state. **Every ~20 PRs** (or when CI passes locally but fails remotely for no clear reason), force a clean build by temporarily adding a suffix to the cache key in `.github/workflows/ios-ci.yml`, then reverting it after the run.

### Pre-PR checklist
1. Branch has a single clear scope
2. No unrelated files in the diff
3. Project compiles (`xcodebuild` passes)
4. Feature/fix works on simulator
5. No debug leftovers, temp files, or commented-out code
6. Commits are readable
7. PR is explainable in 3-5 lines

### AI agent stop rules
I (the AI agent) must **stop and propose a split** when:
1. The task spans multiple distinct functional areas
2. The request mixes feature + fix + refactor in one pass
3. The solution touches many unrelated parts of the project
4. The branch can no longer be described with a single objective
5. The estimated diff is too large for simple review
6. Secondary tasks emerge that deserve their own branch

When I detect scope creep, I will not continue accumulating changes. I will propose a decomposition into separate branches.

### iOS-specific rules
- Never mix UI changes with deep technical refactors in the same branch
- Keep branches vertical: prefer UI-only, logic-only, persistence-only, navigation-only, or tooling-only
- If a branch touches assets + models + views + state + dependencies, evaluate splitting

---

## Out of Scope (Do Not Implement)

- Backend, server, or API of any kind
- Cloud sync or iCloud
- Authentication
- iPad layout
- Third-party libraries
- AI-generated baking suggestions
- Social or sharing features
- Rich photo journaling as a primary flow
- Bake `rating` field (removed from MVP)
- Automatic step completion based on timer expiry

---

## Reference Files

| File | Purpose |
|---|---|
| `docs/levain-ios-git-workflow.md` | **Git workflow reference** — full branching, PR, and CI rules |
| `docs/levain-prd-complete-v2.md` | Full product spec — source of truth for scope |
| `docs/UX-SPEC.md` | **Screen-by-screen UX specification** — layout, components, states, flows |
| `docs/levain-knowledge.md` | Editorial source for `knowledge.json` |
| `.planning/PROJECT.md` | Project overview and key decisions |
| `.planning/ROADMAP.md` | Full 8-phase roadmap with phase details |
| `.planning/REQUIREMENTS.md` | Traceable v1 requirements (FORM-xx, BAKE-xx, STEP-xx…) |
| `.planning/STATE.md` | Current phase, progress metrics, blockers |
| `.planning/config.json` | Workflow configuration |
| `.planning/phases/` | Per-phase plan detail folders |

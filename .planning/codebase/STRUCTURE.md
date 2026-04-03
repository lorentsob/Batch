# Structure

## Repo Layout

```text
lievito-app/
├── .planning/
│   ├── codebase/
│   ├── milestones/
│   └── phases/
├── Levain/
│   ├── App/
│   ├── Assets.xcassets/
│   ├── DesignSystem/
│   ├── Features/
│   ├── Models/
│   ├── Persistence/
│   ├── Resources/
│   └── Services/
├── LevainTests/
├── LevainUITests/
├── docs/
└── Levain.xcodeproj
```

## Important Directories

**`.planning/`**

- Active project memory: `STATE.md`, `ROADMAP.md`, `PROJECT.md`, `REQUIREMENTS.md`
- Codebase snapshots live in `.planning/codebase/`
- Per-phase plans and summaries live in `.planning/phases/`

**`Levain/`**

- Only application target source tree
- Key entry points: `App/LevainApp.swift`, `App/AppRouter.swift`, `Features/Shared/RootTabView.swift`, `Persistence/ModelContainerFactory.swift`

**`LevainTests/`**

- Unit and integration coverage for routing, scheduling, persistence, seeding, knowledge lookup, and kefir domain logic

**`LevainUITests/`**

- Deterministic launch-harness UI regressions for `Oggi`, `Preparazioni`, Knowledge, kefir flows, and notification routing

**`docs/`**

- Product source material and UX references
- Current v2 scope lives primarily in `levain-prd-v2-multi-fermentations.md` plus `levain-prd-v2-addendum.md`
- `levain-knowledge.md` remains the editorial source for bundled knowledge content

## Feature Areas

- `Levain/Features/Shared/` - root shell, banners, shared UI helpers
- `Levain/Features/Today/` - cross-domain operational dashboard
- `Levain/Features/Preparations/` - root domain hubs and quick actions
- `Levain/Features/Bakes/` - formulas, bake creation, execution, timers, timeline shifting
- `Levain/Features/Starter/` - starter CRUD, refresh log flow, starter detail
- `Levain/Features/Kefir/` - batch-first kefir hub, detail, management, journal, archive, comparison, presentation helpers
- `Levain/Features/Knowledge/` - bundled article browsing and detail

## Code Ownership Boundaries

- Domain entities: `Levain/Models/`
- Business logic and content loading: `Levain/Services/`
- Local persistence and schema: `Levain/Persistence/`
- Shared UI primitives and visual language: `Levain/DesignSystem/`
- Planning memory and execution history: `.planning/`

## Notes

- The workspace root still uses the folder name `lievito-app`, but the app target, source tree, tests, and planning artifacts are unified under `Levain`
- `Levain.xcodeproj` is the only live Xcode project; there is no parallel legacy app target or duplicate shell

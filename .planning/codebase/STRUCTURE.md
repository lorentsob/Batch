# Structure

## Repo Layout

```text
lievito-app/
├── .planning/
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
│   ├── UX-SPEC.md
│   ├── levain-knowledge.md
│   └── levain-prd-complete-v2.md
└── project.yml
```

## Important Directories

**Levain/**

- Native iOS source tree for the only app target
- Key files: `App/LevainApp.swift`, `Persistence/ModelContainerFactory.swift`, `Features/Shared/RootTabView.swift`

**LevainTests/**

- Unit tests for scheduling and derived model logic

**LevainUITests/**

- UI smoke tests for app launch and core shell behavior

**docs/**

- Product source material and UX references
- `levain-prd-complete-v2.md` is the planning scope source
- `levain-knowledge.md` is the editorial source for bundled knowledge items

## Feature Areas

- `Levain/Features/Today/` - Today screen and action prioritization
- `Levain/Features/Bakes/` - formulas, bake creation, step execution, timers, timeline shift
- `Levain/Features/Starter/` - starter CRUD, refresh log flow, starter detail
- `Levain/Features/Knowledge/` - article browsing
- `Levain/Features/Shared/` - root tab shell and contextual tips

## Code Ownership Boundaries

- Domain entities: `Levain/Models/`
- Business logic: `Levain/Services/`
- Local persistence setup: `Levain/Persistence/`
- Shared UI primitives: `Levain/DesignSystem/`
- Planning memory: `.planning/`

## Notes

- The workspace root still uses the folder name `lievito-app`, but the app target, source tree, tests, and planning artifacts are unified under `Levain`
- The old duplicate scaffold has been removed; there is now one project definition to generate: `Levain.xcodeproj`

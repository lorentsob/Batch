---
phase: 15-memory-durability-content-separation
plan: 03
status: complete
completed: 2026-03-14
---

## Summary

### Task 1: Replace hardcoded template source with bundled JSON

- Added `SystemFormula.swift` as a read-only bundled-template value type.
- Added `SystemFormulaLoader.swift` and `system_formulas.json` as the official source for app-provided system formulas.
- Removed the old hardcoded `RecipeTemplates.swift` source.

### Task 2: Keep system templates available in bake creation without persisting them by default

- `BakeCreationView.swift` now loads bundled system formulas alongside saved recipes.
- System selections generate transient `RecipeFormula` values so the user can create a bake without auto-saving a recipe into SwiftData.
- The create flow still supports starter selection and recipe metadata derived from bundled formulas.

### Task 3: Clarify user-facing separation from saved recipes and demo seed

- `FormulaListView.swift` copy now clarifies that app-provided templates live in the `Nuovo bake` flow rather than the user's saved recipe list.
- Added tests to validate bundled formula decoding and transient conversion behavior.

## Files Modified

- `Levain/Models/SystemFormula.swift`
- `Levain/Services/SystemFormulaLoader.swift`
- `Levain/Resources/system_formulas.json`
- `Levain/Features/Bakes/BakeCreationView.swift`
- `Levain/Features/Bakes/FormulaListView.swift`
- `LevainTests/SystemFormulaLoaderTests.swift`

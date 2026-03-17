---
phase: 16-baking-phase-ingredients-ux
plan: 01
subsystem: ui
tags: [swiftdata, swiftui, content-pipeline, python, json]

# Dependency graph
requires:
  - phase: 15-memory-durability-content-separation
    provides: system_formulas.json content pipeline and FormulaStepTemplate Codable struct

provides:
  - Step-specific ingredient list stored in FormulaStepTemplate.ingredients ([String])
  - Step-specific ingredient list stored in BakeStep.ingredientsPayload (String? JSON) + stepIngredients computed var
  - Content formatter matches ingredient subsections to step names and emits per-step ingredient arrays
  - BakeStepDetailView shows "Ingredienti" section above "Procedimento" when ingredients exist

affects:
  - future formula authoring phases (step ingredient authoring UX)
  - BakeCreationView (steps carry ingredients from BakeScheduler)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Step ingredients stored as [String] in FormulaStepTemplate (Codable) and JSON-encoded String in BakeStep (@Model)"
    - "Content pipeline: Python substring matching of ingredient section titles to step names"
    - "BakeScheduler passes template.ingredients to BakeStep init; no schema migration needed for new nullable field"

key-files:
  created: []
  modified:
    - Levain/Models/FormulaStepTemplate.swift
    - Levain/Models/BakeStep.swift
    - Levain/Models/RecipeFormula.swift
    - Levain/Services/BakeScheduler.swift
    - Levain/Features/Bakes/FormulaStepEditorView.swift
    - Levain/Features/Bakes/BakeStepDetailView.swift
    - scripts/format_content.py
    - Levain/Resources/system_formulas.json

key-decisions:
  - "ingredients stored as [String] (flat item lines) not structured objects — simplest representation for display-only use"
  - "ingredient subsection matching uses case-insensitive substring: section title contains step name OR step name contains title"
  - "no step ingredients for formulas with flat ingredient lists (pizza) or ingredient-type subsections (pan brioche) — display section hidden"
  - "ingredientsPayload on BakeStep is nullable String (not Data?) for consistency with other JSON-string fields in the model"

patterns-established:
  - "Step-level metadata follows ingredient pattern: template carries [String], BakeStep carries JSON string payload + computed decoder"

# Metrics
duration: 4min
completed: 2026-03-17
---

# Phase 16 Plan 01: Step-Specific Ingredients in Baking Phase Modal Summary

**Step-level ingredient lines stored in FormulaStepTemplate and BakeStep, populated via Python content pipeline subsection matching, and displayed in the BakeStepDetailView modal above procedimento**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-17T11:03:50Z
- **Completed:** 2026-03-17T11:08:44Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- `FormulaStepTemplate.ingredients: [String]` added — Codable, defaults to empty, carried through all init and duplicate paths
- `BakeStep.ingredientsPayload: String?` + `stepIngredients` computed var added — JSON-encoded on init, safely decoded on access
- `BakeScheduler` passes template ingredients to `BakeStep` at bake creation time
- Python content formatter `match_step_ingredients()` matches `### SubsectionName` headers to step names via case-insensitive substring logic
- `system_formulas.json` regenerated — focaccia (6 items), bagel (7 items), potato buns (8 items) `Impasto` steps now carry ingredient arrays
- `BakeStepDetailView` shows "Ingredienti" `Form` section with accent bullet bars, identical styling to `BakeIngredientsView`, hidden when empty

## Task Commits

1. **Task 1: Model Schema Updates** - `9752419` (feat)
2. **Task 2: Content Formatter Enhancement** - `9e2d887` (feat)
3. **Task 3: Phase Modal UI Update** - `5082b78` (feat)

## Files Created/Modified

- `Levain/Models/FormulaStepTemplate.swift` - Added `ingredients: [String]` field with default `[]`
- `Levain/Models/BakeStep.swift` - Added `ingredientsPayload: String?` stored field and `stepIngredients` computed var
- `Levain/Models/RecipeFormula.swift` - Updated `duplicate()` to pass `ingredients` through step copy
- `Levain/Services/BakeScheduler.swift` - Passes `template.ingredients` to `BakeStep` init
- `Levain/Features/Bakes/FormulaStepEditorView.swift` - Preserves `initialStep.ingredients` on save (UI doesn't edit them)
- `Levain/Features/Bakes/BakeStepDetailView.swift` - New "Ingredienti" section above "Procedimento" with bullet bar styling
- `scripts/format_content.py` - Added `match_step_ingredients()` and wired into `parse_steps()`
- `Levain/Resources/system_formulas.json` - Regenerated with per-step `ingredients` arrays

## Decisions Made

- Stored ingredients as `[String]` flat lines (not `{name, grams, note}` objects) — display-only per context spec, no baker's math needed
- `ingredientsPayload` on `BakeStep` is a nullable `String?` to match the pattern of `procedure`/`ingredients`/`bakingInstructions` on `Bake`
- Ingredient subsection matching uses substring: `"Per l'impasto"` matches step name `"Impasto"` — avoids requiring exact title parity in formula markdown
- Formulas with flat ingredient lists (pizza) or ingredient-type-named subsections (pan brioche) produce empty step ingredients — section hidden in UI, no visual clutter

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Step ingredients display complete for system formulas
- Formula authoring UX (assigning ingredients to steps in `FormulaStepEditorView`) is deferred per context — the editor preserves but does not expose step-level ingredient editing
- `system_formulas.json` is the source of truth for step ingredients on bundled formulas; user-created formulas will have empty step ingredients until authoring UX is implemented

---
*Phase: 16-baking-phase-ingredients-ux*
*Completed: 2026-03-17*

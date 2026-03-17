---
phase: 16-baking-phase-ingredients-ux
verified: 2026-03-17T11:13:34Z
status: passed
score: 3/3 must-haves verified
---

# Phase 16: Baking Phase Ingredients UX — Verification Report

**Phase Goal:** Display relevant ingredient weights directly within the phase modal to prevent navigation context loss.
**Verified:** 2026-03-17T11:13:34Z
**Status:** passed
**Re-verification:** No — initial verification (previous file had no frontmatter or gaps)

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Baking phases in the modal display only ingredients associated with that specific step | VERIFIED | `BakeStepDetailView.swift` line 19: `if !stepIngredients.isEmpty` guard renders a `Section("Ingredienti")` with per-item bullet rows; hidden when empty |
| 2 | Ingredient data is automatically derived from the formula content via scripts | VERIFIED | `format_content.py` `match_step_ingredients()` (line 194) parses `### SubsectionName` headers from Markdown and emits per-step `ingredients` arrays; `system_formulas.json` confirmed: Bagel/Impasto (7), Focaccia/Impasto (6), Potato Buns/Impasto (8) items |
| 3 | UI remains consistent with the existing Design System and BakeIngredientsView styling | VERIFIED | `BakeStepDetailView` lines 23–27 use identical bullet-bar pattern: `RoundedRectangle(cornerRadius: 1).fill(Theme.Control.primaryFill.opacity(0.55)).frame(width: 3, height: 16).padding(.top, 3)` — exact same tokens as `BakeIngredientsView` lines 192–197 |

**Score:** 3/3 truths verified

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `Levain/Models/FormulaStepTemplate.swift` | `ingredients: [String]` field | VERIFIED | Line 15: `var ingredients: [String]`; init defaults to `[]`; passed through `duplicate()` in `RecipeFormula.swift` line 104 |
| `Levain/Models/BakeStep.swift` | `ingredientsPayload: String?` + `stepIngredients` computed var | VERIFIED | Line 32: `var ingredientsPayload: String?`; lines 78–84: `stepIngredients` JSON-decodes on access; init encodes `[String]` to JSON at line 73 |
| `Levain/Services/BakeScheduler.swift` | Passes `template.ingredients` to `BakeStep` init | VERIFIED | Line 65: `ingredients: template.ingredients` — wired in `generateSteps()` |
| `scripts/format_content.py` | `match_step_ingredients()` function + wired into `parse_steps()` | VERIFIED | Lines 194–220: function implemented with 3-priority substring matching; wired at line 259 within `parse_steps()`; passed to `convert_formula()` at line 337 |
| `Levain/Resources/system_formulas.json` | Non-empty `ingredients` arrays on `Impasto` steps | VERIFIED | Bagel Impasto: 7 items, Focaccia Impasto: 6 items, Potato Buns Impasto: 8 items |
| `Levain/Features/Bakes/BakeStepDetailView.swift` | "Ingredienti" section above "Procedimento", hidden when empty | VERIFIED | Lines 19–37: conditional `Section("Ingredienti")` renders before `Section("Procedimento")` at line 39; guard on `!stepIngredients.isEmpty` |
| `Levain/Features/Bakes/FormulaStepEditorView.swift` | Preserves `initialStep.ingredients` on save | VERIFIED | Line 89: `ingredients: initialStep.ingredients` passed through in save path — UI does not expose editing but preserves existing values |
| `Levain/Models/RecipeFormula.swift` | `duplicate()` carries `ingredients` per step | VERIFIED | Line 104: `ingredients: $0.ingredients` included in step map inside `duplicate()` |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `format_content.py` | `system_formulas.json` | `match_step_ingredients()` + `parse_steps()` | WIRED | `match_step_ingredients()` called at line 259; result written into each step dict under `"ingredients"` key; output file is the app bundle resource |
| `system_formulas.json` | `FormulaStepTemplate.ingredients` | JSON decode in `RecipeFormula.defaultSteps` | WIRED | `defaultSteps` computed property decodes payload including `ingredients` field (Codable struct) |
| `FormulaStepTemplate.ingredients` | `BakeStep.ingredientsPayload` | `BakeScheduler.generateSteps()` line 65 | WIRED | `ingredients: template.ingredients` passed to `BakeStep` init, which JSON-encodes to `ingredientsPayload` at line 73 |
| `BakeStep.stepIngredients` | `BakeStepDetailView` render | `private var stepIngredients` + `ForEach` | WIRED | Line 15: `private var stepIngredients: [String] { step.stepIngredients }`; lines 22–33: `ForEach(stepIngredients, id: \.self)` renders bullet rows |
| `BakeStepDetailView` | `BakeDetailView` | `sheet` presentation | WIRED | `BakeDetailView.swift` line 131: `BakeStepDetailView(step: step)` inside `NavigationStack` |
| `BakeStepDetailView` | `TodayView` | `sheet` presentation | WIRED | `TodayView.swift` line 163: `BakeStepDetailView(step: selection.step)` inside `NavigationStack` |

---

### Requirements Coverage

| Requirement | Status | Notes |
|-------------|--------|-------|
| Step-specific ingredients visible in `BakeStepDetailView` | SATISFIED | Section renders when `stepIngredients` is non-empty; hidden automatically for steps with no ingredients (no visual clutter) |
| Content pipeline automatically scales ingredients for each step | SATISFIED | Python `match_step_ingredients()` maps ingredient subsections to step names; `system_formulas.json` regenerated with per-step arrays |
| No visual clutter for steps with no ingredients | SATISFIED | `if !stepIngredients.isEmpty` guard — entire section absent from `Form` when step has no ingredients |

---

### Anti-Patterns Found

None detected. Scan of `BakeStepDetailView.swift`, `BakeStep.swift`, `FormulaStepTemplate.swift`, `BakeScheduler.swift` showed no TODO/FIXME, placeholder text, empty returns, or console-log-only implementations.

---

### Human Verification Required

#### 1. Step ingredients visible in modal on device

**Test:** Create a bake from the Focaccia or Bagel formula. Open any step modal by tapping a step in the bake timeline (both from the Bakes tab detail and the Today tab).
**Expected:** The "Ingredienti" section appears above "Procedimento" for the "Impasto" step and shows 6–7 ingredient lines with the accent bullet bar. Other steps (e.g. Cottura, Bulk fermentation) show no ingredient section.
**Why human:** Visual rendering and correct step-to-ingredient matching requires runtime data flow (SwiftData bake creation + seeded formula loading).

#### 2. No ingredient section for formulas with flat ingredient lists

**Test:** Create a bake from a formula that uses a flat ingredient list (e.g. Pizza if available, or any user-created formula).
**Expected:** No "Ingredienti" section appears in any step modal — no visual clutter.
**Why human:** Requires runtime test with the specific formula category.

#### 3. Ingredient section absent from user-created formula steps

**Test:** Create a new custom formula via the formula editor, then create a bake from it. Open a step modal.
**Expected:** No "Ingredienti" section (user-created formulas have empty step ingredients until authoring UX is added).
**Why human:** Requires live bake creation with a user formula.

---

### Summary

All three must-haves are fully verified against actual code. The data pipeline is complete end-to-end: Python script parses Markdown subsections into per-step ingredient arrays, the `system_formulas.json` bundle resource carries those arrays, `FormulaStepTemplate` holds them in memory as `[String]`, `BakeScheduler` transfers them to `BakeStep.ingredientsPayload` at bake creation time, and `BakeStepDetailView` conditionally renders the "Ingredienti" `Form` section with styling identical to `BakeIngredientsView` (same `RoundedRectangle` bullet bar, same `Theme.Control.primaryFill`, same font/color tokens). The section is suppressed when `stepIngredients` is empty, satisfying the no-visual-clutter requirement for steps without ingredient data.

Three human verification items are flagged for device-side runtime confirmation of the full data path and visual rendering.

---

_Verified: 2026-03-17T11:13:34Z_
_Verifier: Claude (gsd-verifier)_

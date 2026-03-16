# Phase 16: Baking Phase Ingredients UX — Verification

**Date:** 2026-03-16
**Status:** Pending

## Automated Verification

### Step 1: Model Schema
- [ ] `BakeStep` and `FormulaStepTemplate` have `ingredientsPayload` field.
- [ ] Computed `ingredients` property returns correct array.

### Step 2: Content Pipeline
- [ ] `format_content.py` successfully parses `Ingredients:` markers.
- [ ] `system_formulas.json` contains non-empty `ingredients` for "Impasto" phases.

## Manual Verification

### UI Behavior
- [ ] Real-device check: `BakeStepDetailView` modal displays ingredients.
- [ ] No layout broken when instructions are long.

### Data Flow
- [ ] Creating a new bake imports step-ingredients correctly from the formula.

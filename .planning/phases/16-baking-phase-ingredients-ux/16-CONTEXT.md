# Phase 16: Baking Phase Ingredients UX — Context

**Gathered:** 2026-03-16 (updated)
**Status:** Ready for planning

<domain>
## Phase Boundary

Display step-specific ingredient weights inside `BakeStepDetailView` so users don't need to navigate back to the recipe view while actively baking. This phase covers data model, authoring flow in formula templates, content pipeline update, and UI integration. It does NOT include interactive checkboxes or baker's math calculations beyond weight display.

</domain>

<decisions>
## Implementation Decisions

### Ingredient-to-step mapping
- Mapping is **author-defined in the formula template** — the baker explicitly assigns ingredients to steps during formula authoring, not auto-inferred by step type
- In the formula template editor, the baker selects from the formula's defined ingredients (not free text) and assigns each a **percentage of the total ingredient weight** for that step
- Example: autolyse step gets 80% of farina + 100% of acqua; impasto step gets the remaining 20% farina + salt
- When a bake is created, ingredient weights in step modals are **auto-scaled to the bake's actual totals** (not the formula template's fixed values)
- The step modal displays computed **grams only** — no percentages shown to the baker during active baking

### Display format
- Each ingredient line shows: **name + grams** (e.g. `Farina 800g`)
- Optional **short note per ingredient** is supported (e.g. `Acqua 700g · 15°C`) — rendered inline if present
- **No baker's math** (percentages, hydration ratios) in the step modal — keeps focus on the task
- Steps with no ingredients: ingredient section **hidden entirely** — no header, no placeholder

### Visual placement in modal
- Ingredients section appears **above the procedimento section** — baker sees what to gather before reading what to do
- Section header: **"Ingredienti"** (matches recipe view, consistent language)
- Visual style: **bulleted list**, same styling as the "Ingredienti" section in `FormulaDetailView`

### Content pipeline
- The existing formula Markdown files in `docs/content/formulas/` must be **updated to include step-ingredient mappings** for each step that has ingredients
- After updating formula files, `format_content.py` must be **re-run** to regenerate JSON content and push updated data into the app bundle
- This ensures all bundled formulas ship with correct step-specific ingredient data out of the box

</decisions>

<specifics>
## Specific Ideas

- Ingredient display in the modal should feel identical to the recipe view's ingredient list — same bullet style, same accent color, familiar to the baker who has already seen the recipe
- The authoring UX (assigning ingredients to steps) should leverage the formula's already-defined ingredient list — no duplicate data entry

</specifics>

<deferred>
## Deferred Ideas

- Interactive ingredient checkboxes within the step modal (check off as you add each) — v2.1
- Auto-inferred mapping by step type (e.g. autolyse always gets flour + water) — possible optimization after MVP
- Display of baker's math / percentages in step modal — explicitly excluded from this phase

</deferred>

---

*Phase: 16-baking-phase-ingredients-ux*
*Context gathered: 2026-03-16*

# Phase 16: Baking Phase Ingredients UX — Context

**Gathered:** 2026-03-16
**Status:** Planning

<domain>
## Phase Boundary

Phase 16 addresses a critical UX gap in the baking workflow: the lack of visibility for ingredient weights while viewing a specific bake phase instructions. Currently, users must navigate back to the "Ricetta" detail view to see weights, which is disruptive during active baking.

The goal is to map ingredients to their relevant baking steps (e.g., "Farina" and "Acqua" to the "Impasto" step) and display them directly within the phase modal.

</domain>

<decisions>
## Implementation Decisions

### Step-Specific Ingredient Mapping
- Add an `ingredients` metadata field to `FormulaStepTemplate` and `BakeStep`.
- This field will store a JSON-encoded array of strings (e.g., `["Farina: 1000g", "Acqua: 700g"]`).
- For "window-based" steps like proofing, this section will likely be empty.

### Content Automation
- The `format_content.py` script will be updated to parse ingredients directly from formula Markdown files.
- A new section or marker in the Markdown (e.g., `Ingredients: ...`) will be used to associate ingredients with specific steps.
- This ensures consistency between the static recipe data and the generated bakes.

### UI Integration
- The `BakeStepDetailView` will include a new section for ingredients, positioned similarly to the "Procedimento" section.
- The UI will remain minimal, showing only the relevant ingredients without "Baker's Math" metrics to keep the modal focused on the current task.

</decisions>

<specifics>
## Specific Ideas

- The ingredients in the modal should use the same styling as the "Ingredienti" section in the full recipe view (bulleted list with a theme-colored accent).
- If a step has no specific ingredients (like "Bulk Fermentation" or "Shape"), the section should not appear at all to reduce clutter.

</specifics>

<deferred>
## Deferred

- Dynamic scaling of step ingredients (already handled by the formula calculation logic during bake creation).
- Interactive checkboxes for ingredients within the modal (v2.1).

</deferred>

---

_Phase: 16-baking-phase-ingredients-ux_  
_Context gathered: 2026-03-16_

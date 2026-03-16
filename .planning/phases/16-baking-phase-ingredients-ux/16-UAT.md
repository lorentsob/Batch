# Phase 16: Baking Phase Ingredients UX — UAT

To be verified on a real device or simulator.

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| 16.1 | Open "Impasto" modal | "Ingredienti" section is visible with Farina, Acqua, etc. and their weights. |
| 16.2 | Open "Bulk" modal | "Ingredienti" section is NOT visible (no ingredients for this step). |
| 16.3 | Layout regression | The modal scrolls correctly and labels are bottom-aligned with instructions. |
| 16.4 | Content synchronization | Updating a formula Markdown and running `format_content.py` updates the modal content immediately on new bakes. |

**User Sign-off:**
- [ ] Modal information is sufficient to perform the step without closing it.
- [ ] No visual noise for steps with no ingredients.

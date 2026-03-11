# Phase 10: Operational UX Realignment - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 10 realigns the shipped MVP with real usage. It covers the operational home experience, the bake-first information architecture, the rename and restructuring of formulas into recipes, the recipe and starter form model needed for flour/yeast choices, the cleanup of cancelled/completed bake behavior, and the visual-system fixes that UAT exposed. It does not add backend, sync, journaling, analytics, or new editorial tooling.

</domain>

<decisions>
## Implementation Decisions

### Operational home and agenda
- The current Today root is no longer acceptable as a flat list of pending steps; the home must cluster work by bake and show planned or in-progress bakes first.
- Cancelled bakes must disappear from the operational agenda entirely, including any pending steps previously generated from them.
- When there are no active or planned bakes, the home must still be useful through direct CTAs to create a new impasto and open recipes or knowledge.
- User-facing copy should move away from the current "Oggi" framing toward a true home screen.

### Information architecture and navigation
- The product remains planner-first and bake-centric; Impasti becomes the operational center for active, planned, completed, and cancellable bakes.
- Recipes and Knowledge should move out of the primary tab bar into a secondary menu or secondary access pattern.
- The current primary navigation assumptions in `docs/UX-SPEC.md` are superseded by this phase where they conflict with the new bake-first IA.
- The `birthday.cake.fill` icon is explicitly rejected and must be replaced with an icon that matches dough or bake planning.

### Recipes instead of formulas
- User-facing "Formula" terminology becomes "Ricetta" throughout the app.
- Built-in template recipes must be directly usable when creating a new bake; cloning into a saved personal recipe should be optional, not required just to use a preset.
- What is currently `BakeType` should behave as a recipe category from the user's point of view; "Pagnotta" is renamed to "Pane" and categories should support grouping.
- "Pezzi" becomes "Porzioni".

### Recipe and starter data modeling
- Flour mix can no longer remain a free-text field in recipes and starters; it must become a structured multi-select with reusable predefined categories plus custom entries.
- Recipe authoring must capture which yeast family the recipe is configured for, including sourdough via saved starters and common commercial yeasts such as dry yeast and fresh yeast.
- The chosen yeast strategy must persist with the recipe so bake creation already knows the expected yeast type and quantity; quantity adjustments should derive automatically from the selected yeast option.
- The starter selector in bake creation belongs in the primary flow, not buried behind an "advanced" disclosure.

### Form UX and visual compliance
- Placeholder-only forms are not acceptable; fields need persistent labels and enough descriptive context to remain legible after input.
- Contrast, typography, chips, and status colors must be audited against the intended design system, with cancelled states using destructive red.
- The app icon issue is part of this phase and must be debugged to completion rather than left as a build-time annoyance.

### Claude's Discretion
- Exact presentation of the secondary menu, provided recipes and knowledge are clearly secondary to operational bake flows.
- Exact multi-select control pattern for flour categories, provided it is tappable, editable, and reusable in both recipes and starters.
- Exact conversion logic for yeast quantities, provided assumptions are documented and the UI makes the active yeast basis clear.

</decisions>

<specifics>
## Specific Ideas

- Home should show "bake in programma / in corso" and tapping one should open its dedicated page.
- Impasti should keep recipes reachable with a quick link, but the page itself must stay focused on bakes.
- New bake should use a target usage/eating time instead of the current target bake time phrasing.
- New bake should flatten the form and remove the misleading advanced section.
- Compare the shipped screens against both `docs/levain-prd-complete-v2.md` and `docs/UX-SPEC.md`, then align implementation to the latest product direction rather than preserving inconsistent legacy decisions.

</specifics>

<deferred>
## Deferred Ideas

- Import/export of recipes or bake history
- Richer bake journaling or result scoring
- iPad layouts or cross-device navigation patterns
- Cloud sync, accounts, or external knowledge management

</deferred>

---

*Phase: 10-operational-ux-realignment*
*Context gathered: 2026-03-11*

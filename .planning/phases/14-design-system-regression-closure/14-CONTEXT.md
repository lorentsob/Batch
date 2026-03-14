# Phase 14: Design System Regression Closure — Context

**Gathered:** 2026-03-14
**Status:** Implemented, awaiting UAT

<domain>
## Phase Boundary

Phase 14 closes the regressions introduced after the v2.0 design-system rollout. Scope is intentionally narrow: enforce the app's light-only contract, keep system chrome aligned with the design tokens, fix destructive bake confirmations that now appear in the wrong place, and make cancelled / overdue bake states visually trustworthy again.

This phase does not add new baking features. It restores fidelity and trust in existing flows that were already part of the MVP.

</domain>

<decisions>
## Implementation Decisions

### Light-only contract

- The app-level color scheme must be forced to light so dark iOS appearance never leaks into sheets, tab chrome, navigation bars, or toolbar controls.
- Navigation and tab bars should also declare a light toolbar color scheme explicitly, not only rely on content tint.
- Sheet backgrounds for bake creation should use `Theme.Surface.app` instead of inheriting system dark grouped materials.

### Destructive bake actions

- System `confirmationDialog` is replaced with a bottom-anchored custom destructive sheet inside `BakeDetailView` to avoid misplaced popovers and keep the visual language inside the design system.
- Cancelling a bake must immediately resync notifications so cancelled timelines stop scheduling reminders.
- Deleting a bake must clear navigation state and remove orphaned reminders via a full notification resync.

### Cancelled and overdue readability

- A cancelled bake becomes a terminal visual state: red summary card, archived future steps, no active contextual tips, and a final destructive action that changes to delete.
- Overdue danger chips need a border so they stay legible on error-tinted cards.
- Timeline rows should use a centered rail/dot layout instead of a top-floating dot, with left-aligned timing metadata.

</decisions>

<specifics>
## Specific Ideas

- The "Nuovo bake" sheet should feel like the rest of the app, not like a system-dark modal.
- Cancelled future phases should stop looking actionable even if their underlying persisted status remains `.pending`.
- The visual difference between "problem" and "archived" should be obvious at a glance.

</specifics>

<deferred>
## Deferred

- Broad refactors of every form surface in the app
- Replacing other system confirmation dialogs outside bake cancellation/deletion
- Additional animation or motion polish beyond what is needed to restore trust

</deferred>

---

_Phase: 14-design-system-regression-closure_  
_Context gathered: 2026-03-14_

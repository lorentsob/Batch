---
phase: 17-shell-preparations-hubs
plan: 02
status: complete
---

## Summary

Built the Preparazioni root and internal hub views that rehouse the bread domain under the v2 shell.

### New Files

- **`Levain/Features/Preparations/PreparationsView.swift`**: Root view for the Preparazioni tab. Shows two domain hub cards (Pane e lievito madre, Milk kefir) and a compact quick-action strip (Nuovo impasto, Nuovo starter, Nuovo kefir). Uses existing `SectionCard`, `StateBadge`, and `Theme` tokens.
- **`Levain/Features/Preparations/PreparationHubCardView.swift`**: Reusable hub card component with icon, title, badge, subtitle, chevron, and inline empty-state CTA. Built with `SectionCard` and current design tokens.
- **`Levain/Features/BreadHub/BreadHubView.swift`**: Pane e lievito madre hub with three entry rows (Impasti, Starter, Formule). Each row routes to existing bread views via `PreparationsRoute` without duplicating any view logic. Shows inline empty-state CTAs when a section has no data.
- **`Levain/Features/Kefir/KefirHubView.swift`**: Lightweight milk kefir hub placeholder. Shows `EmptyStateView("Nessun batch attivo")` with a disabled CTA. Full batch management ships in Phase 19.

### Verification

- Build: SUCCEEDED
- Both hub cards visible even with zero active objects
- Bread hub routes into existing BakesView / StarterView / FormulaListView destinations

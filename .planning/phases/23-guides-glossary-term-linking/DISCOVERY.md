# Guides, Glossary & Term Linking Discovery

## Summary

The current bundled Knowledge system is structurally capable of hosting a glossary, but the shipped content and schema are still too small for recipe-term linking as-is. `knowledge.json` currently contains 8 articles, while `system_formulas.json` already exposes a broader vocabulary across 6 bundled formulas and their step/procedure text. The existing navigation model is already suitable because `AppRouter` can deep-link directly into Knowledge articles.

The main gap is not routing. It is editorial and indexing coherence. Several concepts already present in recipes have either no dedicated guide or inconsistent naming across English and Italian variants (`bulk` vs `bulk fermentation`, `proof` vs `appretto`, `first rise` vs `prima lievitazione`). A successful Phase 23 therefore needs one canonical concept map plus aliases before wiring inline links.

## Primary Recommendation

Build Phase 23 around a centralized glossary index that maps many terms and aliases to one Knowledge article ID, then reuse one shared rich-text/linking component across read-only recipe and guide surfaces. This keeps the implementation coherent, lets the app support English and Italian phrasing without drift, and avoids scattering special cases inside each SwiftUI screen.

Editorially, ship the first rollout with three buckets:

1. Terms already covered well enough to link immediately.
2. Terms that can reuse an existing article only after alias handling exists.
3. Terms that need a new dedicated guide before they should be linked.

## Existing Knowledge Inventory

| Knowledge ID | Current title | Practical coverage |
| --- | --- | --- |
| `starter-basics` | `Basi del lievito madre` | Starter fundamentals, general `starter` / `lievito madre` concept |
| `starter-maintenance-fridge` | `Manutenzione starter in frigo` | Fridge storage and refresh cadence |
| `starter-recovery` | `Recuperare uno starter pigro` | Troubleshooting weak starter activity |
| `bulk-fermentation-basics` | `Bulk fermentation` | Main dough fermentation, temperature, fold context |
| `bakers-math` | `Baker's math e idratazione` | Percentages, hydration, inoculation math |
| `shaping-guide` | `Formatura e preforma` | `Formatura`, `preforma`, `bench rest`, surface tension |
| `cold-retard-guide` | `Cold retard` | Final proof in fridge / cold retard concept |
| `common-problems` | `Problemi comuni e soluzioni` | Broad troubleshooting, not term-specific |

## Recipe Term Inventory

Discovery sampled the exact `defaultSteps` names plus structured `procedure` section titles in `system_formulas.json`.

### Terms already strong enough to link in the first rollout

| Recipe term | Occurrences | Canonical destination | Notes |
| --- | ---: | --- | --- |
| `Bulk fermentation` | 6 | `bulk-fermentation-basics` | Exact current article match |
| `Cold retard` | 5 | `cold-retard-guide` | Exact current article match |
| `Formatura` | 8 | `shaping-guide` | Exact Italian match |
| `Shape` | 4 | `shaping-guide` | Clear English alias to `Formatura` |

### Terms that can map to an existing article once alias support exists

| Recipe term | Occurrences | Proposed destination | Reason |
| --- | ---: | --- | --- |
| `Bulk` | 3 | `bulk-fermentation-basics` | Short label for the same concept |
| `First rise` | 1 | `bulk-fermentation-basics` | Conceptually first fermentation phase |
| `Prima lievitazione` | 2 | `bulk-fermentation-basics` | Italian variant of first fermentation |
| `Starter`, `lievito madre`, `rinfresco` | many | `starter-basics` / `starter-maintenance-fridge` | Existing coverage is split across two starter guides |
| `bench rest` / `preforma` | implied | `shaping-guide` | Already present in the shaping article even if not common in formula titles |

### Terms that should not be auto-linked in the first rollout

| Term | Why it should stay plain text initially |
| --- | --- |
| `Impasto` | Too generic in the current UI and unlikely to improve comprehension as a glossary jump |
| `Cottura`, `Bake`, `Forno` | Broad cooking labels, not precise glossary concepts yet |
| `Raffreddamento`, `Cooling` | Low-value glossary jump for the current user goal |
| `Timeline`, `Oggi, ore 21:00`, `Domani, ore 8:30` | Scheduling structure, not terminology |
| `Alternative same-day path`, `Variante un po’ più dolce` | Content labels, not glossary concepts |

## Missing Guide Backlog

These concepts appear in bundled recipes but do not yet have a focused guide entry strong enough for direct linking.

| Priority | Concept | Evidence in recipes | Recommendation |
| --- | --- | --- | --- |
| P0 | `Appretto` | 4 occurrences plus `Proof`, `Final proof`, `Second rise`, `Seconda lievitazione` | Create one canonical `Appretto` guide with English aliases |
| P0 | `Levain` | 4 occurrences plus `Starter prep` sections | Create a dedicated `Levain` guide distinct from general starter maintenance |
| P1 | `Autolisi` | 2 occurrences | Add dedicated guide; common technical term and high glossary value |
| P1 | `Pieghe` / `stretch & fold` | Explicit recipe section plus mention inside bulk article | Create dedicated guide or significantly expand current bulk article with precise alias coverage |
| P1 | `Bollitura` | 2 occurrences plus bagel troubleshooting references | Create bagel-specific guide for boiling stage |
| P2 | `Proof` family if not solved only by aliases | `Proof`, `Final proof`, `Second rise` | May collapse into `Appretto` if coverage is strong enough |

## Product and UX Findings

### Current rendering surfaces

- `FormulaDetailView` renders recipe procedure and step names as plain `Text`.
- `BakeIngredientsView` renders the same structured procedure text as plain `Text`.
- `KnowledgeDetailView` renders article body as plain `Text`.

### Navigation baseline

- The app already has a shared root Knowledge stack and a direct router entrypoint through `AppRouter.openKnowledge(_:)`.
- No new tab or modal architecture is required for this phase.

### Search/indexing baseline

- `KnowledgeView` search currently matches only `title`, `content`, and `tags`.
- There is no first-class alias field or centralized term-to-article resolver today.

## Proposed Canonical Vocabulary Direction

- Prefer Italian for concepts that are already normal in Italian baking UX: `Formatura`, `Appretto`, `Autolisi`, `Pieghe`, `Bollitura`.
- Keep English when that is already the app wording or the domain’s most legible stable term: `Bulk fermentation`, `Cold retard`, `Levain`, `Baker's math`.
- Use aliases to catch the opposite-language variant and shorter recipe labels.

## Implementation Implications

- Add alias/search-term support to the bundled Knowledge schema.
- Introduce a shared glossary index or resolver instead of per-view string matching.
- Add one shared attributed-text or segmented-text renderer for tappable inline terms.
- Limit the first rollout to read-only surfaces and glossary-worthy concepts so the UI stays calm.

## Metadata

<metadata>
<confidence level="high">
This discovery is based on the exact bundled local content and UI code that the app currently ships: `knowledge.json`, `system_formulas.json`, `KnowledgeView`, `KnowledgeDetailView`, `FormulaDetailView`, `BakeIngredientsView`, and `AppRouter`.
</confidence>

<sources>
- `Levain/Resources/knowledge.json`
- `Levain/Resources/system_formulas.json`
- `Levain/Features/Knowledge/KnowledgeView.swift`
- `Levain/Features/Knowledge/KnowledgeDetailView.swift`
- `Levain/Features/Bakes/FormulaDetailView.swift`
- `Levain/Features/Bakes/BakeIngredientsView.swift`
- `Levain/App/AppRouter.swift`
</sources>

<open_questions>
- Whether `Pieghe` should get a dedicated guide immediately or first ship as an alias-backed jump into the bulk article
- Whether first rollout link density should be limited to the first occurrence per section or per screen
- Whether `Starter prep` should deep-link to `Levain` once created or to a broader starter article in the interim
</open_questions>

<validation_checkpoints>
- Verify that the chosen inline-link rendering remains accessible with Dynamic Type and VoiceOver
- Verify that link density feels supportive in long procedure paragraphs on smaller iPhones
- Verify that search/indexing still returns the canonical guide when the user searches aliases in either language
</validation_checkpoints>
</metadata>

---
*Phase: 23-guides-glossary-term-linking*
*Discovery gathered: 2026-04-08*

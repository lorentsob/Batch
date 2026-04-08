# Phase 23: Guides, Glossary & Term Linking - Context

**Gathered:** 2026-04-08
**Status:** Planning complete

<domain>
## Phase Boundary

Turn `Knowledge` into a practical guide/glossary layer that can be reached directly from recipe terminology and other read-only learning surfaces. This phase owns canonical term mapping, Italian/English alias policy, non-invasive inline linking, and the editorial backlog needed to cover the terminology already present in shipped formulas. It does not redesign the top-level shell, move Knowledge to a remote CMS, or auto-link every generic cooking label in the app.

</domain>

<decisions>
## Implementation Decisions

### Canonical terminology and language policy
- One concept must resolve to one canonical Knowledge entry; aliases and synonyms should redirect to that single entry rather than creating duplicate articles.
- Prefer Italian as the canonical user-facing term when that wording is common and natural in this domain.
- Keep English as the canonical label when the Italian alternative is uncommon, awkward, or already established in the product and the baking domain (`bulk fermentation`, `cold retard`, `levain` are current candidates).
- Once a canonical label is chosen for a concept, recipes, Knowledge, aliases, and search/indexing should follow it consistently instead of alternating languages unpredictably.

### What should and should not become a link
- Link only technical terms that a user may plausibly need explained while reading a recipe or guide.
- Do not blanket-link generic labels such as `Impasto`, `Cottura`, `Timeline`, clock headings, or decorative section titles that do not add glossary value.
- The first rollout should prioritize read-only surfaces where the user is already in a learning or execution mindset: formula detail, bake recipe detail, and Knowledge article text where cross-reference improves comprehension.

### Link UX and density
- Linking must feel integrated, not noisy: the treatment should be visually secondary to the recipe content and should avoid turning entire paragraphs into a dense field of taps.
- Density should be capped per block or section so repeated occurrences of the same term do not overwhelm the screen.
- Interaction should deep-link into the shared `Knowledge` stack that already exists in `AppRouter`, keeping navigation consistent with the current shell.

### Data and indexing model
- The current `KnowledgeItem` dataset is too small and too title-driven for robust term linking; Phase 23 should add alias/search-term support beyond `title` and `tags`.
- Term matching and article lookup should be centralized behind one glossary/knowledge index instead of hand-coded conditionals inside individual views.
- The bundled JSON model remains the editorial source of truth; this phase extends the local content shape rather than introducing a backend or remote sync path.

### Editorial scope and gap handling
- Existing guides that already cover a concept can accept aliases immediately once the index exists (`Bulk fermentation`, `Cold retard`, `Formatura`/`Shape`).
- Concepts present in recipes but not yet represented as a focused guide should be listed explicitly and then authored in a prioritized editorial pass.
- Synonyms that only describe the same concept in a different style (`Bulk`, `First rise`, `Prima lievitazione`) should map to one canonical article instead of spawning parallel entries.

### Claude's Discretion
- The exact schema shape for aliases/index terms, as long as it stays bundled, testable, and easy to edit.
- The exact inline-link affordance, as long as it is subtle, accessible, and reusable across recipe/guide surfaces.
- Which low-value terms stay unlinked in the first rollout if evidence from implementation shows they create noise instead of clarity.

</decisions>

<specifics>
## Specific Ideas

- The primary content sources are `Levain/Resources/knowledge.json` and `Levain/Resources/system_formulas.json`.
- The current read-only recipe/detail surfaces are `Levain/Features/Bakes/FormulaDetailView.swift` and `Levain/Features/Bakes/BakeIngredientsView.swift`.
- The current guide browsing/detail surfaces are `Levain/Features/Knowledge/KnowledgeView.swift` and `Levain/Features/Knowledge/KnowledgeDetailView.swift`.
- `Levain/App/AppRouter.swift` already supports direct Knowledge deep linking through `openKnowledge(_:)` and `levain://knowledge/<id>`.
- Current regression anchors include `LevainTests/KnowledgeLoaderTests.swift`, `LevainTests/KnowledgeLibraryTests.swift`, `LevainUITests/KnowledgeFlowUITests.swift`, and `LevainUITests/FermentationsFlowUITests.swift`.
- Discovery on 2026-04-08 confirmed only 8 bundled guide entries versus 6 shipped formulas whose step/procedure vocabulary already includes `Bulk fermentation`, `Cold retard`, `Levain`, `Appretto`, `Autolisi`, `Pieghe`, `Bollitura`, and several proof/bulk aliases.

</specifics>

<deferred>
## Deferred Ideas

- User-authored glossary notes or editable custom guide content
- Remote content syncing or CMS-backed editorial workflows
- Auto-linking inside editors or other write-heavy surfaces where taps would fight text editing
- Full-app term detection in every card, notification, or badge before the read-only recipe/guide surfaces prove the UX works

</deferred>

---
*Phase: 23-guides-glossary-term-linking*
*Context gathered: 2026-04-08*

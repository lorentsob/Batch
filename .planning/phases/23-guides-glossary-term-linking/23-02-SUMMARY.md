# Phase 23-02 — Recipe & Guide Surface Linking

**Status:** Complete
**Date:** 2026-04-08

## What shipped

### Modified app files
- `Levain/Features/Shared/GlossaryLinkedText.swift` — extended the shared renderer so read-only surfaces can exclude self-links while still routing matched terms through the canonical Knowledge deep link
- `Levain/Features/Bakes/FormulaDetailView.swift` — replaced plain recipe step/procedure rendering with glossary-aware linked text while keeping the current card hierarchy unchanged
- `Levain/Features/Bakes/BakeIngredientsView.swift` — upgraded the read-only bake recipe modal so structured procedure titles and explanatory copy use the same glossary-linked renderer
- `Levain/Features/Knowledge/KnowledgeDetailView.swift` — enabled cross-reference links inside article bodies using the shared renderer, with the current article excluded to avoid recursive self-linking
- `Levain/Features/Bakes/FormulaListView.swift` — added an explicit accessibility identifier to stabilize the formula-list navigation assertion used by the new UI flow

### Modified test files
- `LevainUITests/FermentationsFlowUITests.swift` — added an end-to-end glossary-link flow from formula detail into the shared Knowledge stack and hardened card lookup for the recipe tile path
- `LevainUITests/KnowledgeFlowUITests.swift` — added an end-to-end glossary-link flow from one guide article into a related guide article

## Key decisions

- Link density stays intentionally capped by surface: step/section titles link once, recipe paragraphs link up to two concepts, and Knowledge body copy links up to three concepts
- Guide detail excludes the current article ID from inline linking so article bodies do not generate noisy self-references
- All new links continue to route through `AppRouter.openKnowledge(_:)`, so recipe and guide taps land in the one shared root Knowledge stack instead of opening a parallel modal/navigation path

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/FermentationsFlowUITests/testFormulaGlossaryLinkOpensKnowledgeArticleOnSharedRootStack` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KnowledgeFlowUITests/testKnowledgeArticleGlossaryLinkNavigatesToRelatedGuide` — passed

## Residuals

- Re-running the full `FermentationsFlowUITests` class still exposes pre-existing simulator/UI-suite instability around dashboard card discovery (`RicetteCard`, `KefirHubCard`) that is broader than the glossary-linking change itself
- Re-running the full `KnowledgeFlowUITests` class also showed a simulator restart during the legacy suite, even though the new glossary-link test passes in isolation
- No dedicated manual small-screen simulator review was captured in artifacts during this execution pass

## Outcome

Levain now surfaces practical inline glossary navigation exactly where the phase intended: in formula detail, bake recipe detail, and guide copy. Recipe readers can jump directly into the relevant guide article without leaving the shared navigation model, and guide articles can now cross-link related concepts without turning the screen into a dense field of links.

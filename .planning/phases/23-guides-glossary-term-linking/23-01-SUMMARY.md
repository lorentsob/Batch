# Phase 23-01 — Canonical Glossary Foundation

**Status:** Complete
**Date:** 2026-04-08

## What shipped

### Modified app files
- `Levain/Models/KnowledgeItem.swift` — added alias-aware decoding plus `glossaryTerms` so each Knowledge article can express canonical terms and supported synonyms without duplicating entries
- `Levain/Services/KnowledgeLoader.swift` — centralized a reusable `glossaryIndex` inside `KnowledgeLibrary` and added direct glossary-term lookup on top of the existing local Knowledge loading path
- `Levain/Services/KnowledgeGlossaryIndex.swift` — introduced the canonical term resolver, whole-term matching, alias normalization, and attributed-text generation for future inline linking
- `Levain/Features/Shared/GlossaryLinkedText.swift` — added one shared read-only text component that renders glossary-linked text and routes Knowledge taps through the app’s existing deep-link contract
- `Levain/Resources/knowledge.json` — enriched the bundled Knowledge dataset with the first canonical aliases for `Bulk fermentation`, `Cold retard`, `Formatura e preforma`, starter terminology, and `Baker's math`
- `Levain.xcodeproj/project.pbxproj` — regenerated via `xcodegen generate` so the new glossary files are included in the app target

### Modified test files
- `LevainTests/KnowledgeLoaderTests.swift` — now verifies alias decoding and glossary lookup through the real bundled dataset
- `LevainTests/KnowledgeLibraryTests.swift` — added coverage for English/Italian alias resolution and whole-term matching inside free text

## Key decisions

- One article remains the canonical destination for one concept; aliases now point to that entry instead of encouraging duplicate guide records
- Alias-based glossary matching currently uses article `title + aliases`, not free-form `tags`, so linkable terms stay explicit and editorially controlled
- The first shared text primitive only prepares subtle inline linking and routing; actual screen integration stays deferred to `23-02`

## Verification

- `xcodegen generate` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KnowledgeLoaderTests` — passed (`2/2`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KnowledgeLibraryTests` — passed (`11/11`)

## Outcome

Levain now has a canonical, alias-aware glossary foundation ready for UI wiring: Knowledge can resolve Italian and English term variants to one article, and the app has one reusable linked-text primitive for the next phase of recipe and guide integration.

# Conventions

**Analysis Date:** 2026-03-10

## Code Style

- Prefer small SwiftUI views split by workflow instead of giant screen files.
- Keep business rules in models or services, not embedded in view bodies.
- Use Apple-native APIs only unless a concrete limitation forces a change.
- Treat overdue and due labels as derived presentation, not persisted domain state.

## Naming

- Use Italian copy for user-facing text.
- Use English identifiers for code symbols, models, and services.
- Name services after the domain behavior they encapsulate, for example `BakeScheduler` or `KnowledgeLoader`.

## Persistence Patterns

- Persist operational data in SwiftData models with explicit UUID identifiers.
- Keep static editorial content out of SwiftData and in bundled JSON.
- Favor simple stored primitives and computed helpers over fragile heavy abstractions.

## UI Patterns

- The Today screen is action-first and should keep one primary action visible per item.
- Bake detail step cards should surface one dominant action depending on the step state.
- Advanced or nerdy fields belong in secondary sections or sheets.

## Error Handling

- Fail fast on invalid bootstrap conditions.
- Use empty states instead of placeholder dashboards.
- Avoid silent data loss when recalculating schedules or editing formulas.

## Documentation Patterns

- Update `.planning/STATE.md` when the current phase or major focus changes.
- Keep `.planning/PROJECT.md` aligned with real decisions, not hypothetical future scope.

---
*Conventions analysis: 2026-03-10*
*Update when patterns become stable or shift*


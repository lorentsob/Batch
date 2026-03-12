# 11-02 Summary: Today Semantics

## Outcome
Today now distinguishes three operational buckets: `Da fare`, `In programma oggi`, and `Domani`. Overdue starter reminders move into the urgent section, due-today starter reminders remain visible but visually reduced, and tomorrow is now a capped preview instead of an open-ended later bucket.

## Verification
- `TodayAgendaBuilderTests` updated and passing with coverage for urgent starter split, scheduled starter split, tomorrow cap, and terminal-bake exclusion.

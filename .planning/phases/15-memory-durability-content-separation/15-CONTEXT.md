# Phase 15: Memory Durability & System Content Separation — Context

**Gathered:** 2026-03-14
**Status:** Implemented, verification pending

<domain>
## Phase Boundary

Phase 15 hardens Levain's memory model without changing the product scope. The goal is to keep user-created SwiftData records durable across app updates, add a manual JSON backup or restore path, and separate bundled system content from demo-only seed data.

This phase does not add backend, auth, sync, or new baking workflows. It protects the existing local-first product from data-loss and content-mixing risks.

</domain>

<decisions>
## Implementation Decisions

### Safe persistence ownership

- Persisted models are now owned by `LevainSchemaV1` and `LevainMigrationPlan`, which become the only valid source of truth for SwiftData schema evolution.
- Any future `@Model` change requires a schema-version decision before commit; no more implicit model drift.
- Persistent bootstrap must fail safe. If container creation fails, the app may fall back to in-memory for the current session, but it must never erase the on-disk store automatically.

### Backup and restore

- Backup uses explicit JSON DTOs (`BackupPayloadV1`) instead of encoding `@Model` objects directly.
- Import is a replace-current-user-data restore, not a merge. Technical flags remain outside the backup scope.
- Notification scheduling is resynced after restore, because reminders are derived from restored bake or starter state.

### System content separation

- Knowledge and system formulas are bundled JSON, read-only, and not part of user-data persistence by default.
- `system_formulas.json` replaces hardcoded in-app recipe templates as the official bundled source.
- Demo seed remains an internal launch-option path and is no longer treated as the app's official template content.

### Deferred infrastructure

- No backend, account system, or sync layer is added in this phase.
- CloudKit remains an explicit later-phase option if multi-device support ever becomes necessary.

</decisions>

<specifics>
## Specific Ideas

- The backup UI should stay minimal and low-risk: a settings sheet with only export and import actions.
- System templates should remain visible in `Nuovo bake` even when the user has not saved any personal recipes.
- The project memory in `.planning` should explicitly document the schema-versioning rule so future model edits do not silently reintroduce the original data-loss risk.

</specifics>

<deferred>
## Deferred

- Automatic background sync or multi-device replication
- Auto-importing bundled system formulas into SwiftData on first launch
- Rich backup conflict resolution or record-level merge tools
- Public-facing account or sharing infrastructure

</deferred>

---

_Phase: 15-memory-durability-content-separation_  
_Context gathered: 2026-03-14_

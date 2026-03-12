# 11-03 Summary: Router Hardening and Flow Docs

## Outcome
Notification-driven navigation now resolves live SwiftData entities before routing. Missing bake IDs fall back to the `Impasti` tab, missing starter IDs fall back to the `Starter` tab, stale step IDs open the surviving bake detail, and cancelled/completed bakes open safely with an informational toast.

## Verification
- `AppRouterTests` now cover missing bake, missing starter, stale step, and cancelled bake fallback behavior.
- A new markdown flow document replaces the missing legacy HTML artifact and documents the real operational flows.

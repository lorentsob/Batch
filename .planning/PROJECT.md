# Levain

## What This Is

Levain is a native iPhone-only planning tool for sourdough starter management and real-world baking execution. The product is intentionally planner-first: it helps the user know what needs attention now, manage active bakes, adapt schedules when reality changes, and keep lightweight baking knowledge close to the workflow.

## Core Value

The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.

## Requirements

### Validated

(None yet — greenfield MVP)

### Active

- [x] Operational Home grouped by bake instead of a flat list of pending steps
- [x] Bake-first information architecture with Home / Impasti / Starter primary navigation and secondary access to Ricette and Knowledge
- [x] Recipe and starter authoring with explicit labels, structured flour selection, and yeast-aware planning inputs
- [x] Bake lifecycle cleanup for cancellation, deletion, target-usage semantics, and trustworthy visual-state feedback
- [x] Visual and asset compliance pass, including corrected state colors, iconography, and working App Icon recognition
- [x] Naming, Today urgency semantics, and notification-router fallback behavior aligned after post-UAT gap review
- [ ] Userflow v2 conformance across Today, bake creation/execution, window-based steps, starter refresh, and notification entry, with final closure gated by manual on-device UAT

### Out of Scope

- Backend, auth, cloud sync, or external database — personal internal MVP only
- iPad and multi-device support — iPhone-only validation target
- AI-generated baking advice — knowledge stays static and bundled
- Social, community, or public sharing features — not part of the operational core
- Advanced analytics, rich photo logging, or exhaustive journaling — too much complexity for v1

## Context

- Source of truth for scope: `docs/levain-prd-complete-v2.md`
- Source of truth for operational flow behavior: `docs/levain-user-flows.md`
- Source of truth for bundled editorial content: `docs/levain-knowledge.md`
- MVP language is Italian-first to match the current knowledge content and personal-use scope
- Implementation baseline is native Apple tooling with Xcode 26.3 and Swift 6.2.4
- Repository started as a greenfield workspace with only PRD and knowledge documents before bootstrap

## Constraints

- **Platform**: iPhone only, iOS 26 minimum — simplifies native implementation and testing
- **Architecture**: SwiftUI + SwiftData + UserNotifications + bundled JSON — keeps the stack Apple-native and predictable
- **Infrastructure**: No backend, auth, sync, or third-party libraries — minimizes setup and maintenance
- **UX**: Minimal, action-first, progressive disclosure — keeps advanced baking detail out of the core flow
- **Validation**: Internal test MVP — optimize for fast confidence instead of public-launch completeness

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Italian-first MVP | Fastest fit for personal use and matches existing content | — Pending |
| Backward-only schedule generation | Simplest useful planner logic for v1 | — Pending |
| Editable default step templates live on `RecipeFormula` | Keeps formulas reusable without inventing a heavier template system | — Pending |
| Knowledge is bundled JSON, not SwiftData | Static content is easier to version and ship locally | — Pending |
| Notifications are local and rescheduled from persisted state | Reliable behavior with the app closed | — Pending |
| `INFOPLIST_KEY_UILaunchScreen_Generation = YES` must be kept in `.pbxproj` | Prevents iOS 26+ legacy compatibility mode (letterboxing) since we removed `ZStack` from `RootTabView` to fix native TabBar layout | — Pending |
| v1 sign-off requires a written audit, not only successful local test runs | Feature completeness alone is not enough for release confidence | — Pending |
| CI/CD should use GitHub Actions plus the existing XcodeGen and `xcodebuild` toolchain | Matches the current repository structure and keeps hosted automation close to local commands | — Pending |
| Release delivery should remain manual-triggered and secret-backed for the MVP | Avoids accidental signed distribution while still automating repeatable release-candidate creation | — Pending |
| Post-v1 UAT realignment takes precedence over treating the current v1 UI as final | Real use exposed IA, workflow, and clarity gaps that the original milestone completion did not close | 2026-03-11 |
| Primary navigation should foreground Home, Impasti, and Starter; Ricette and Knowledge become secondary destinations | The product promise is operational bake guidance, not equal-weight feature browsing | 2026-03-11 |
| User-facing "Formula" language is replaced by "Ricetta", with built-in templates directly reusable | Current terminology and flow force unnecessary duplication before starting a bake | 2026-03-11 |
| Structured flour and yeast selection are required domain features, not optional UI polish | Real recipe and starter use needs reusable ingredient taxonomy and clear fermentation basis | 2026-03-11 |
| Phase 10 must explicitly close the unresolved App Icon issue | The asset catalog is partly configured, but the icon still is not recognized in practice | 2026-03-11 |
| Product and AI context naming must use `Levain` consistently | Conflicting `Levain`/`Lievito` references degrade AI-assisted development quality and document trust | 2026-03-12 |
| Today must separate urgent work from same-day scheduled work and suppress work beyond tomorrow | Operational trust depends on distinguishing "do now" from "planned later today" instead of flattening both into one signal | 2026-03-12 |
| Notification deep links must resolve against live entities with safe fallback and transient toast feedback | Stale IDs are normal over time; the app must degrade safely instead of landing in silent empty states | 2026-03-12 |
| The repo-maintained operational source of truth is `docs/levain-user-flows.md`, mirrored from the external HTML v2 | The attached HTML drives UX expectations, but the repository needs a durable markdown document for planning, code review, and traceability | 2026-03-12 |
| Window-based bake steps use `flexibleWindowStart`/`flexibleWindowEnd` for urgency instead of `plannedEnd` | Proof and cold-retard windows are inherently flexible; overdue semantics should match real baking behavior | 2026-03-12 |
| Bake execution remains sequential by default, with explicit confirmation and persistent `Fuori ordine` feedback for overrides | The app should prescribe the next correct action while still allowing expert recovery from real-world deviations | 2026-03-12 |

---
*Last updated: 2026-03-12 after Phase 12 implementation and automated verification, with manual UAT still pending*

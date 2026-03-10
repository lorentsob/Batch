# Levain

## What This Is

Levain is a native iPhone-only planning tool for sourdough starter management and real-world baking execution. The product is intentionally planner-first: it helps the user know what needs attention now, manage active bakes, adapt schedules when reality changes, and keep lightweight baking knowledge close to the workflow.

## Core Value

The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.

## Requirements

### Validated

(None yet — greenfield MVP)

### Active

- [ ] Operational Today view for now, overdue, upcoming, and starter reminders
- [ ] Formula-driven bake creation with editable default step structures
- [ ] Reliable step execution, timers, and schedule shifting for active bakes
- [ ] Local-first starter tracking and refresh logging
- [ ] Bundled contextual knowledge and lightweight browsing
- [ ] Written v1 audit packet with requirement traceability, smoke results, and residual risk logging
- [ ] CI/CD automation for build, test, and controlled release-candidate delivery

### Out of Scope

- Backend, auth, cloud sync, or external database — personal internal MVP only
- iPad and multi-device support — iPhone-only validation target
- AI-generated baking advice — knowledge stays static and bundled
- Social, community, or public sharing features — not part of the operational core
- Advanced analytics, rich photo logging, or exhaustive journaling — too much complexity for v1

## Context

- Source of truth for scope: `docs/levain-prd-complete-v2.md`
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

---
*Last updated: 2026-03-10 after adding Phase 9 v1 audit and CI/CD planning*

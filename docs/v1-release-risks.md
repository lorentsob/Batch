# Batch v1 Release Risks

**Prepared:** 2026-03-10 — Phase 09-01
**Version:** 0.1.0 (build 1)

This document separates hard blockers from acceptable MVP follow-ups so the final release decision remains honest rather than optimistic.

---

## Risk Categories

| Symbol | Meaning |
|--------|---------|
| 🔴 BLOCKER | Must be resolved before any public or TestFlight distribution |
| 🟡 RELEASE CONDITION | Must be verified or accepted before distribution but does not require a code change |
| 🟢 POST-V1 | Acceptable to defer; document and schedule |

---

## Blockers

### RISK-01 — Signing secrets not provisioned

| Field | Value |
|-------|-------|
| **ID** | RISK-01 |
| **Category** | 🔴 BLOCKER |
| **Requirement** | QUAL-07 |
| **Description** | GitHub Actions CD workflow (`ios-release.yml`) is implemented but cannot execute signed distribution until signing certificate, provisioning profile, and App Store Connect API key are stored as repository secrets. |
| **Impact** | `xcodebuild archive` and `altool`/`uploadPackage` upload steps will fail with no-signing errors if triggered without secrets. |
| **Owner** | Repository maintainer |
| **Resolution** | Provision secrets as described in `docs/release-secrets.md` and trigger `ios-release.yml` for validation. |
| **Status** | OPEN |

---

## Release Conditions (must verify before distribution)

### RISK-02 — Notification behavior verified on simulator only

| Field | Value |
|-------|-------|
| **ID** | RISK-02 |
| **Category** | 🟡 RELEASE CONDITION |
| **Requirements** | NOTIF-01, NOTIF-02, NOTIF-03, NOTIF-04 |
| **Description** | All four notification requirements have passing automated unit tests (`BakeReminderPlannerTests`, `StarterReminderPlannerTests`, `AppRouterTests`). However, actual local notification delivery and the tap-to-navigate path have only been validated in the simulator, where notification timing behavior differs from a real device. |
| **Impact** | If notification scheduling has a timing bug (e.g., off-by-one in date math) or the `UNUserNotificationCenterDelegate` path has a regression, end-users will miss reminders — the core ops value proposition. |
| **Owner** | Repository maintainer |
| **Resolution** | Complete smoke checklist section S7 on a real iPhone before App Store submission. |
| **Status** | OPEN — blocked on real-device testing |

### RISK-03 — UI tests cover only the simulator environment

| Field | Value |
|-------|-------|
| **ID** | RISK-03 |
| **Category** | 🟡 RELEASE CONDITION |
| **Requirements** | QUAL-03 |
| **Description** | `LevainUITests` verifies core journeys (app launch, tab navigation, bake/starter creation) on simulator. There is no on-device automation run. Dynamic Type, VoiceOver, low-memory, and real touch latency are untested. |
| **Impact** | A layout regression on real hardware would not be caught by CI. |
| **Owner** | Repository maintainer |
| **Resolution** | Combine smoke checklist section S4–S5 on real device with manual accessibility spot check (larger text setting). |
| **Status** | OPEN — acceptable for internal-testing MVP |

---

## Post-v1 Follow-Ups (safe to defer)

### RISK-04 — CI macOS runner hosting cost

| Field | Value |
|-------|-------|
| **ID** | RISK-04 |
| **Category** | 🟢 POST-V1 |
| **Description** | GitHub Actions macOS runners (15-core M1 Pro as of 2024) have a higher per-minute cost than Linux runners. The current workflow uses `macos-15` which is sufficient but not the cheapest option. |
| **Impact** | Minor ongoing CI cost; not a correctness issue. |
| **Resolution** | Revisit runner selection when the project transitions from personal to shared use. |
| **Status** | DEFERRED |

### RISK-05 — XCTest coverage does not include all edge cases for timeline shifting

| Field | Value |
|-------|-------|
| **ID** | RISK-05 |
| **Category** | 🟢 POST-V1 |
| **Description** | `BakeSchedulerTests` covers the standard shift-forward case and the guard against modifying completed steps. Edge cases omitted: shift > bake target date, shift on single-step bakes, and shift when all steps are completed. |
| **Impact** | Low probability for the current personal-use scope; would surface only with atypical workflows. |
| **Resolution** | Add parametric test cases in a follow-up. |
| **Status** | DEFERRED |

### RISK-06 — No iPad layout validation

| Field | Value |
|-------|-------|
| **ID** | RISK-06 |
| **Category** | 🟢 POST-V1 |
| **Description** | Project is declared iPhone-only (`TARGETED_DEVICE_FAMILY: 1`). However, the App Store allows the app to run on iPad via iPhone compatibility mode. No iPad layout testing has been performed. |
| **Impact** | The app may look stretched or misaligned on iPad. Acceptable given current scope. |
| **Resolution** | Add iPad layout support in v2 if adoption warrants. |
| **Status** | DEFERRED — by design (out of scope) |

### RISK-07 — No iCloud backup or data recovery path

| Field | Value |
|-------|-------|
| **ID** | RISK-07 |
| **Category** | 🟢 POST-V1 |
| **Description** | All data is stored in SwiftData local storage. If the user loses their device or uninstalls the app, all formulas, bake history, and starter logs are lost. iCloud sync is not implemented (by design for v1). |
| **Impact** | Data loss risk for active users. Acceptable for internal personal-use MVP. |
| **Resolution** | Implement iCloud sync or export/import in v2. |
| **Status** | DEFERRED — BACKLOG-04 |

### RISK-08 — Localization limited to Italian

| Field | Value |
|-------|-------|
| **ID** | RISK-08 |
| **Category** | 🟢 POST-V1 |
| **Description** | UI strings are Italian-first by decision. No i18n infrastructure is in place. |
| **Impact** | App is not accessible to non-Italian speakers without additional work. |
| **Resolution** | Add string catalog and localization infrastructure in v2. |
| **Status** | DEFERRED — BACKLOG-02 |

### RISK-09 — Notification permission not requested if denied on first launch

| Field | Value |
|-------|-------|
| **ID** | RISK-09 |
| **Category** | 🟢 POST-V1 |
| **Description** | If the user dismisses the notification permission dialog, the app does not re-request or guide them to Settings. Reminders are silently disabled. |
| **Impact** | User misses reminders without understanding why. Low severity for personal-use scope. |
| **Resolution** | Add a settings-link prompt when notification permission is denied. |
| **Status** | DEFERRED |

---

## Summary

| Category | Count |
|----------|-------|
| 🔴 BLOCKERS | 1 (RISK-01 — signing secrets) |
| 🟡 RELEASE CONDITIONS | 2 (RISK-02, RISK-03) |
| 🟢 POST-V1 | 6 (RISK-04 through RISK-09) |

**Overall posture:** The app is ready for internal TestFlight distribution once RISK-01 is resolved and RISK-02 is verified on a real device. All other risks are acceptable for the current personal-use MVP scope.

---

*Last updated: 2026-03-10 — Phase 09-01*

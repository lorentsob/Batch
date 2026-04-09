# Batch v1 Smoke Checklist

**Purpose:** One focused manual pass that covers every MVP-critical flow automation does not fully guarantee.
**Target device:** iPhone running iOS 26 (on-device preferred; iPhone 17 Pro simulator is acceptable for non-notification checks).
**Estimated time:** 20–30 minutes end to end.

---

## How to Use This Checklist

1. Mark each step ✅ (pass), ❌ (fail), or ⚠️ (partial / workaround needed).
2. Record the device/simulator model and iOS version at the top.
3. If any **GATE** checkpoint fails, stop and document the failure before continuing.
4. Sign off at the bottom only when every gate passes.

**Device/Simulator:** __________________________
**iOS Version:** __________________________
**App Version:** 0.1.0 (build 1)
**Run date:** __________________________
**Tester:** __________________________

---

## S1 — Fresh Install & First Launch

| # | Step | Expected | Result |
|---|------|----------|--------|
| S1-1 | Delete app if previously installed. Install clean build. | App installs without error | |
| S1-2 | Launch app for the first time. | Launches directly to Today tab. No crash. No automatic data seeding. | |
| S1-3 | Verify Today tab. | Empty state visible: helpful prompt, no ghost rows.  | |
| S1-4 | Verify Bakes tab. | Empty state visible. | |
| S1-5 | Verify Starters tab. | Empty state visible. | |
| S1-6 | Verify Knowledge tab. | Articles list loads from local JSON. No network request needed. | |

**🔴 GATE S1:** All 6 steps pass before continuing.

---

## S2 — Formula Authoring

| # | Step | Expected | Result |
|---|------|----------|--------|
| S2-1 | Navigate to Bakes tab → Formulas. Tap "+" to create a formula. | Formula editor opens. | |
| S2-2 | Fill in name, flour weight, hydration %, starter %, salt %. Save. | Formula appears in list. No crash. | |
| S2-3 | Open formula detail. Add two default step templates. Assign durations. | Steps appear in order inside formula. | |
| S2-4 | Reorder steps by drag (or up/down buttons). Save. | Order persists after leaving and reopening detail. | |
| S2-5 | Return to formula list. Verify formula is still present after background/foreground. | Formula persists. | |

**🔴 GATE S2:** All 5 steps pass before continuing.

---

## S3 — Bake Lifecycle

| # | Step | Expected | Result |
|---|------|----------|--------|
| S3-1 | Tap "Create Bake" (or equivalent). Select the formula created in S2. Set a target bake time in the near future (e.g., +4 h). | Bake is created and persisted. Detail view opens. | |
| S3-2 | Verify bake detail shows ordered step cards with planned start times computed backward from target. | Steps shown in correct backward order. | |
| S3-3 | Verify Bakes tab shows the new bake with a status badge (upcoming, active, or similar). | Bake visible in list with a readable status. | |
| S3-4 | Return to Today tab. Verify at least one bake step appears. | Step row visible in Today with title and action button. | |

**🔴 GATE S3:** All 4 steps pass before continuing.

---

## S4 — Step Execution

| # | Step | Expected | Result |
|---|------|----------|--------|
| S4-1 | From Today, tap the primary action on the bake step created in S3. | Step status transitions (e.g., "Start" → in progress). `actualStartedAt` set. | |
| S4-2 | Verify timer guidance appears (countdown or elapsed) while step is active. | Timing information visible. | |
| S4-3 | Complete the step. | `actualCompletedAt` set. Next step becomes active in Today (if applicable). | |
| S4-4 | Open bake detail. Use the timeline shift action (+15 min or custom). | Remaining incomplete future steps shift by the chosen offset. Previously completed steps unchanged. | |
| S4-5 | Force quit app. Relaunch. Verify data persists (bake still active, step states intact). | No data loss. No crash on relaunch. | |

**🔴 GATE S4:** All 5 steps pass before continuing.

---

## S5 — Starter Management

| # | Step | Expected | Result |
|---|------|----------|--------|
| S5-1 | Navigate to Starters tab. Create a new starter (name, refresh interval). | Starter appears in list. | |
| S5-2 | Open starter detail. Set last-refresh date to yesterday. Verify due state label. | Due state shows "Due" or "Overdue". | |
| S5-3 | Tap "Log Refresh". Fill weights and optional note. Save. | Refresh entry appears in history. Due state resets. | |
| S5-4 | Verify that Today tab shows the starter reminder row when the starter is due. | Starter reminder row visible in Today. | |
| S5-5 | Disable starter reminders (toggle in editor). Verify Today row disappears for that starter. | Starter reminder hidden when reminders disabled. | |
| S5-6 | Open starter detail. Find the contextual knowledge tip row. Tap it. | Article detail opens with relevant content. | |

**🔴 GATE S5:** All 6 steps pass before continuing.

---

## S6 — Knowledge Tab

| # | Step | Expected | Result |
|---|------|----------|--------|
| S6-1 | Navigate to Knowledge tab. Verify categories load from local JSON. | Category list visible. No spinner or network error. | |
| S6-2 | Tap a category. Verify articles list. | Articles visible. | |
| S6-3 | Tap an article. Verify content renders. Navigate back. | Article readable. Back navigation works. | |
| S6-4 | Kill and relaunch app. Return to Knowledge tab. | Content still loads from bundle without network. | |

**🔴 GATE S6:** All 4 steps pass before continuing.

---

## S7 — Notification Behavior (on-device only)

> ⚠️ These steps require a **real device**. Simulator cannot reliably trigger local notifications. Mark ⚠️ if testing on simulator; re-run on device before distribution.

| # | Step | Expected | Result |
|---|------|----------|--------|
| S7-1 | Grant notification permission when prompted. | System permission dialog appears. Permission granted. | |
| S7-2 | Create a bake step whose planned time is within 5 minutes. Background the app. | Local notification fires at the expected time. | |
| S7-3 | Tap the notification. | App opens and navigates to the correct bake detail. | |
| S7-4 | Create a starter with a past due date and reminders enabled. Background the app. | Starter reminder notification fires (may require waiting for the scheduled time). | |
| S7-5 | Tap the starter notification. | App opens and navigates to the correct starter. | |

**🔴 GATE S7 (device required):** All 5 steps pass on real device before App Store submission.

---

## S8 — Lifecycle & Relaunch

| # | Step | Expected | Result |
|---|------|----------|--------|
| S8-1 | With data present, force quit and relaunch. | All bakes, starters, and formulas still present. | |
| S8-2 | Background the app for 30 seconds. Foreground. | No crash. Today items still current. | |
| S8-3 | Put device to sleep while a bake is active. Wake and open app. | Active bake state intact. Overdue label shown if step time has passed. | |

**🔴 GATE S8:** All 3 steps pass before continuing.

---

## Summary & Sign-Off

| Gate | Result |
|------|--------|
| S1 — Fresh Install | |
| S2 — Formula Authoring | |
| S3 — Bake Lifecycle | |
| S4 — Step Execution | |
| S5 — Starter Management | |
| S6 — Knowledge Tab | |
| S7 — Notifications | |
| S8 — Lifecycle & Relaunch | |

**Overall result:** ☐ GO &nbsp;&nbsp; ☐ NO-GO

**Signed off by:** __________________________
**Date:** __________________________
**Notes:**

---

*Checklist version: 1.0 — Phase 09-01 — 2026-03-10*

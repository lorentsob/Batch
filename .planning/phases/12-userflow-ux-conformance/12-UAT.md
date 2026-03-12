---
status: testing
phase: 12-userflow-ux-conformance
source: 12-01-SUMMARY.md, 12-02-SUMMARY.md, 12-03-SUMMARY.md
started: 2026-03-12T12:10:00+01:00
updated: 2026-03-12T12:10:00+01:00
---

## Current Test

number: 1
name: Today state matrix
expected: |
  First launch, all-clear, future-only, and active-agenda states are all visually and behaviorally distinct on-device.
awaiting: user response

## Tests

### 1. Today state matrix
expected: First launch, all-clear, future-only, and active-agenda states are distinct; future-only shows the next action and the correct CTA.
result: [pending]

### 2. Nuovo bake da zero
expected: A new user can start from `Nuovo bake`, see system templates immediately, leave bake name empty, and land in Bake Detail after creation.
result: [pending]

### 3. Esecuzione bake sequenziale con override
expected: The next correct step is visually prescribed; starting a future step requires confirmation and leaves a persistent `Fuori ordine` badge.
result: [pending]

### 4. Step overnight / window-based
expected: A running proof or cold-retard step stays compact before the window opens, becomes actionable at window open, and only turns late after the window closes.
result: [pending]

### 5. Refresh starter rapido
expected: From Today, the refresh form opens with three primary fields, advanced details collapsed, and the Today starter row disappears immediately after save.
result: [pending]

### 6. Notifica → Deep Link
expected: Valid payloads route correctly on warm and cold launch; missing entities and denied notifications fall back safely with non-blocking feedback.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0

## Gaps

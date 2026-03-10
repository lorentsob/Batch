# Integrations

**Analysis Date:** 2026-03-10

## External Services

None.

The app is intentionally local-first and does not integrate with:
- backend APIs
- authentication providers
- cloud databases
- analytics SDKs
- push notification services

## Platform Integrations

**UserNotifications**
- Purpose: local bake-step and starter reminders
- Direction: schedule, cancel, and reschedule notifications based on persisted app data
- Notes: deep-link routing is handled in-app when the user taps a delivered notification

**SwiftData**
- Purpose: local persistence for starters, refresh logs, formulas, bakes, steps, and app settings
- Notes: data stays on-device only

**Bundle Resources**
- Purpose: load static knowledge articles from JSON
- Paths: `Levain/Resources/knowledge.json`, source editorial doc `docs/levain-knowledge.md`

## Auth and Security Boundary

- No auth layer
- No user accounts
- No network calls
- No secrets or API keys expected in the repository

## Operational Concerns

- Notification permission must be requested in-app
- Notification tap routing requires simulator or device verification because it depends on app lifecycle callbacks

---
*Integration analysis: 2026-03-10*
*Update when external services or system integrations change*

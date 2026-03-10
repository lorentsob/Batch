# Testing

## Current Strategy

- `LevainTests/` for unit tests
- `LevainUITests/` for UI smoke tests
- Manual verification via Xcode simulator for the four-tab shell, seed data, and navigation flows

## Covered Areas

- `BakeSchedulerTests` covers backward schedule generation, timeline shifting, derived bake status, and starter due-state derivation

## Planned Additions

- Notification scheduling and rescheduling coverage
- UI coverage for formula creation, bake execution, starter refresh logging, and knowledge browsing
- Manual device verification for notification deep links and app lifecycle behavior

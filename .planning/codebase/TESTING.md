# Testing

## Current Strategy

- `LevainTests/` holds unit and integration coverage using Swift Testing plus targeted XCTest-compatible helpers where needed
- `LevainUITests/` runs deterministic launch-harness UI regressions (`launchEmpty`, `launchSeeded`, pending notification routes, denied notifications)
- Verification is performed through `xcodebuild` against `iPhone 15 Pro` / `iOS 26.4`
- `SeedDataLoader` scenarios are the primary contract for cross-domain UI and routing coverage

## Covered Areas

- `TodayAgendaBuilderTests` lock cross-domain urgency ordering, empty states, tomorrow previews, and kefir participation in `Oggi`
- `BakeSchedulerTests` cover backward schedule generation, timeline shifting, derived bake status, and bread timing logic
- `AppRouterTests` cover direct deep links plus notification fallback behavior for missing or stale bake, starter, and kefir targets
- `PersistenceMigrationTests` and `ModelContainerFactoryTests` cover schema ordering, V4 membership, additive persistence, and explicit container/bootstrap failures
- `SeedDataLoaderTests` verify idempotent seeding plus event-rich operational kefir scenarios
- `KnowledgeLibraryTests` cover bundled article lookup and contextual tips
- `KefirBatchTests`, `KefirEventTests`, and `KefirReminderPlannerTests` cover the batch-first kefir model, typed events, and reminder planning
- `TodayFlowUITests`, `KnowledgeFlowUITests`, `KefirFlowUITests`, and `NotificationRouteUITests` cover the shipped shell, Knowledge entry/article flow, kefir hub/detail/journal/archive/comparison surfaces, and cold-launch notification routing

## Phase 21 Verification Snapshot

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-sim -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-todaytests -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/TodayAgendaBuilderTests` — passed (`14/14`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-todayui -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/TodayFlowUITests` — passed (`7/7`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-knowledgelib -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/KnowledgeLibraryTests` — passed (`8/8`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-knowledge -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/KnowledgeFlowUITests` — passed (`4/4`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-kefir -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/KefirFlowUITests` — passed (`15/15`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-tests -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/ModelContainerFactoryTests` — passed (`4/4`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-router -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/AppRouterTests` — passed (`17/17`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-notify -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/NotificationRouteUITests` — passed (`7/7`)

## Remaining Gaps

- No hosted CI runner currently enforces the simulator matrix on every change
- Notification delivery and app lifecycle behavior still need a final on-device smoke pass
- Phase 22 will need one closing cross-domain UAT run across bread, starter, kefir, and knowledge filters/tips

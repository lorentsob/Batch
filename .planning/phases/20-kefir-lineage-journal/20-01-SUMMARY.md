---
phase: 20-kefir-lineage-journal
plan: 01
status: complete
---

## Summary

Delivered the first Phase 20 execution slice by adding a durable kefir event model, wiring automatic event capture into the existing batch mutation flows, and replacing placeholder lineage copy with readable source/derived context across the kefir surfaces. The kefir vertical now has real provenance and history foundations without changing its batch-first, action-first workflow.

### Changes

- **`Levain/Models/KefirEvent.swift`**: Added the new persisted `KefirEvent` model plus typed event kinds for creation, derivation, renewal, management updates, storage changes, reactivation, archive, and manual notes.
- **`Levain/Persistence/LevainSchema.swift`**, **`LevainTests/PersistenceMigrationTests.swift`**, and **`LevainTests/TestSupport/DomainFixtures.swift`**: Introduced additive schema `LevainSchemaV4`, extended migration coverage for the new event entity, and added fixtures for event-focused tests.
- **`Levain/Services/KefirEventRecorder.swift`**: Centralized kefir event creation so the vertical records one consistent typed history grammar instead of scattering ad-hoc writes across views.
- **`Levain/Features/Kefir/KefirBatchEditorView.swift`**, **`Levain/Features/Kefir/KefirBatchManageSheet.swift`**, and **`Levain/Features/Kefir/KefirBatchDetailView.swift`**: Wired automatic event recording into create, derive, renew, manage/save, reactivate, archive, and manual-note creation paths while preserving notification resync behavior.
- **`Levain/Models/KefirBatch.swift`**, **`Levain/Features/Kefir/KefirBatchPresentation.swift`**, **`Levain/Features/Kefir/KefirBatchCardView.swift`**, **`Levain/Features/Kefir/KefirBatchListView.swift`**, and **`Levain/Features/Kefir/KefirBatchDetailView.swift`**: Replaced the generic derivation placeholder with named source lineage, derived-child counts, and readable provenance summaries on batch list/detail surfaces.
- **`LevainTests/KefirEventTests.swift`**: Added focused tests for typed lineage events, renew/manage storage transitions, reactivation/archive events, and manual note persistence.
- **`Levain.xcodeproj/project.pbxproj`**: Registered the new model, service, and test files in the correct targets.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- Unit tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KefirEventTests` — **4/4 passed**
- Migration tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/PersistenceMigrationTests` — **14/14 passed**
- Note: the plan’s original `iPhone 17 Pro` simulator destination is not available in this workspace, so verification ran on the available `iPhone 15 Pro` simulator (`iOS 26.4`).
- Phase 20 now has its lineage/history foundation; the next planned execution wave is `20-02` for journal/history surfaces.

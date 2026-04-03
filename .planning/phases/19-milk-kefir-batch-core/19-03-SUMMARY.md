---
phase: 19-milk-kefir-batch-core
plan: 03
status: complete
---

## Summary

Shipped the first operational milk kefir lifecycle: users can now create the very first batch without any culture prerequisite, manage an existing batch directly from detail, derive a new batch from an old one, and archive completed batches without leaving the main flow.

### Changes

- **`Levain/Models/KefirBatch.swift`**: Added persisted lifecycle mutations for renew, reactivate, storage/routine updates, freezer reactivation planning, and archive so the kefir vertical now changes real data instead of placeholder copy.
- **`Levain/Features/Kefir/KefirBatchEditorView.swift`** (new): Added the shared create/derive batch editor used for first-batch creation and lineage-aware derived batches, with only the operational fields needed now and no culture-first requirement.
- **`Levain/Features/Kefir/KefirBatchManageSheet.swift`** (new): Added the lightweight manage sheet for quick operational updates such as manage-now/reactivate-now, storage mode changes, routine edits, and optional freezer reactivation dates.
- **`Levain/Features/Preparations/PreparationsView.swift`** and **`Levain/Features/Kefir/KefirHubView.swift`**: Replaced the deferred creation placeholders with the real batch editor so `Preparazioni` quick actions, the kefir root card, and the kefir empty state all funnel into the same first-batch flow and open the saved batch directly.
- **`Levain/Features/Kefir/KefirBatchDetailView.swift`**: Turned the detail quick actions into real persisted operations for renew, derive, state/storage management, and archive; also moved the actions block higher in the detail layout and hardened the primary CTA accessibility identifier for stable UI coverage.
- **`Levain/Features/Kefir/KefirBatchPresentation.swift`**: Removed placeholder-only kefir action scaffolding now that the detail view executes real operations.
- **`LevainUITests/KefirFlowUITests.swift`**: Expanded the kefir UI suite to cover empty-state first-batch creation, direct creation from `Preparazioni`, seeded derive flow, seeded archive flow, and more stable navigation waits across the full vertical.
- **`Levain.xcodeproj/project.pbxproj`**: Registered the new editor/manage files in the app target.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- UI tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KefirFlowUITests` — **7/7 passed**
- The kefir vertical is now usable for real batch-first work; reminder defaults and `Oggi`/notification entry remain the final Phase `19-04` gap.

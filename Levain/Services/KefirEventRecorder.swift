import Foundation
import SwiftData

enum KefirEventRecorder {
    struct Snapshot: Equatable {
        let storageMode: KefirStorageMode
        let expectedRoutineHours: Int
        let plannedReactivationAt: Date?

        init(batch: KefirBatch) {
            self.storageMode = batch.storageMode
            self.expectedRoutineHours = batch.expectedRoutineHours
            self.plannedReactivationAt = batch.plannedReactivationAt
        }
    }

    enum CreationMode {
        case create
        case derive(source: KefirBatch)
    }

    static func recordCreation(
        of batch: KefirBatch,
        mode: CreationMode,
        in context: ModelContext,
        at now: Date = .now
    ) {
        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: .created,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours,
                plannedReactivationAt: batch.plannedReactivationAt
            )
        )

        if case .derive(let source) = mode {
            let differentiationNote = batch.differentiationNote.trimmedNilIfEmpty ?? ""

            context.insert(
                KefirEvent(
                    batchID: batch.id,
                    createdAt: now,
                    kind: .derivedFromBatch,
                    relatedBatchID: source.id,
                    relatedBatchName: source.name,
                    note: differentiationNote,
                    storageMode: batch.storageMode,
                    expectedRoutineHours: batch.expectedRoutineHours,
                    plannedReactivationAt: batch.plannedReactivationAt
                )
            )

            context.insert(
                KefirEvent(
                    batchID: source.id,
                    createdAt: now,
                    kind: .spawnedDerivedBatch,
                    relatedBatchID: batch.id,
                    relatedBatchName: batch.name,
                    note: differentiationNote,
                    storageMode: source.storageMode,
                    expectedRoutineHours: source.expectedRoutineHours,
                    plannedReactivationAt: source.plannedReactivationAt
                )
            )
        }

        recordManualNote(batch.notes, for: batch, in: context, at: now)
    }

    static func recordRenewal(
        of batch: KefirBatch,
        in context: ModelContext,
        at now: Date = .now
    ) {
        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: .renewed,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours,
                plannedReactivationAt: batch.plannedReactivationAt
            )
        )
    }

    static func recordManagementUpdate(
        of batch: KefirBatch,
        previous: Snapshot,
        in context: ModelContext,
        at now: Date = .now
    ) {
        let kind: KefirEventKind = previous.storageMode == batch.storageMode ? .managementUpdated : .storageChanged

        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: kind,
                note: managementNote(from: previous, to: batch),
                previousStorageMode: previous.storageMode == batch.storageMode ? nil : previous.storageMode,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours,
                plannedReactivationAt: batch.plannedReactivationAt
            )
        )
    }

    static func recordReactivation(
        of batch: KefirBatch,
        previous: Snapshot,
        in context: ModelContext,
        at now: Date = .now
    ) {
        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: .reactivated,
                previousStorageMode: previous.storageMode,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours,
                plannedReactivationAt: batch.plannedReactivationAt
            )
        )
    }

    static func recordArchive(
        of batch: KefirBatch,
        in context: ModelContext,
        at now: Date = .now
    ) {
        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: .archived,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours
            )
        )
    }

    static func recordManualNote(
        _ note: String,
        for batch: KefirBatch,
        in context: ModelContext,
        at now: Date = .now
    ) {
        guard let trimmedNote = note.trimmedNilIfEmpty else {
            return
        }

        context.insert(
            KefirEvent(
                batchID: batch.id,
                createdAt: now,
                kind: .noteAdded,
                note: trimmedNote,
                storageMode: batch.storageMode,
                expectedRoutineHours: batch.expectedRoutineHours,
                plannedReactivationAt: batch.plannedReactivationAt
            )
        )
    }

    private static func managementNote(from previous: Snapshot, to batch: KefirBatch) -> String {
        if previous.storageMode != batch.storageMode {
            return "Da \(previous.storageMode.title) a \(batch.storageMode.title)"
        }

        if previous.expectedRoutineHours != batch.expectedRoutineHours {
            return routineSummary(for: batch.storageMode, expectedRoutineHours: batch.expectedRoutineHours)
        }

        if previous.plannedReactivationAt != batch.plannedReactivationAt {
            if batch.plannedReactivationAt != nil {
                return "Riattivazione pianificata"
            }
            if previous.plannedReactivationAt != nil {
                return "Riattivazione rimossa"
            }
        }

        return ""
    }

    private static func routineSummary(for storageMode: KefirStorageMode, expectedRoutineHours: Int) -> String {
        switch storageMode {
        case .roomTemperature:
            return "Routine aggiornata a \(expectedRoutineHours) ore"
        case .fridge, .freezer:
            return "Routine aggiornata a \(max(expectedRoutineHours / 24, 1)) giorni"
        }
    }
}

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

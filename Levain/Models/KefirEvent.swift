import Foundation
import SwiftData

enum KefirEventKind: String, CaseIterable, Codable, Identifiable {
    case created
    case derivedFromBatch = "derived_from_batch"
    case spawnedDerivedBatch = "spawned_derived_batch"
    case renewed
    case managementUpdated = "management_updated"
    case storageChanged = "storage_changed"
    case reactivated
    case archived
    case noteAdded = "note_added"

    var id: String { rawValue }
}

@Model
final class KefirEvent {
    @Attribute(.unique) var id: UUID
    var batchID: UUID
    var createdAt: Date
    var kindRaw: String
    var relatedBatchID: UUID?
    var relatedBatchName: String?
    var note: String
    var previousStorageModeRaw: String?
    var storageModeRaw: String?
    var expectedRoutineHours: Int?
    var plannedReactivationAt: Date?

    init(
        id: UUID = UUID(),
        batchID: UUID,
        createdAt: Date = .now,
        kind: KefirEventKind,
        relatedBatchID: UUID? = nil,
        relatedBatchName: String? = nil,
        note: String = "",
        previousStorageMode: KefirStorageMode? = nil,
        storageMode: KefirStorageMode? = nil,
        expectedRoutineHours: Int? = nil,
        plannedReactivationAt: Date? = nil
    ) {
        self.id = id
        self.batchID = batchID
        self.createdAt = createdAt
        self.kindRaw = kind.rawValue
        self.relatedBatchID = relatedBatchID
        self.relatedBatchName = relatedBatchName?.trimmedNilIfEmpty
        self.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        self.previousStorageModeRaw = previousStorageMode?.rawValue
        self.storageModeRaw = storageMode?.rawValue
        self.expectedRoutineHours = expectedRoutineHours
        self.plannedReactivationAt = plannedReactivationAt
    }
}

extension KefirEvent {
    static var timelineDescriptor: FetchDescriptor<KefirEvent> {
        FetchDescriptor(
            sortBy: [SortDescriptor(\KefirEvent.createdAt, order: .reverse)]
        )
    }

    var kind: KefirEventKind {
        KefirEventKind(rawValue: kindRaw) ?? .created
    }

    var previousStorageMode: KefirStorageMode? {
        previousStorageModeRaw.flatMap(KefirStorageMode.init(rawValue:))
    }

    var storageMode: KefirStorageMode? {
        storageModeRaw.flatMap(KefirStorageMode.init(rawValue:))
    }

    static func descriptor(for batchID: UUID) -> FetchDescriptor<KefirEvent> {
        let predicate = #Predicate<KefirEvent> { event in
            event.batchID == batchID
        }

        return FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\KefirEvent.createdAt, order: .reverse)]
        )
    }
}

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

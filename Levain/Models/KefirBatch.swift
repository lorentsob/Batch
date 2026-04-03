import Foundation
import SwiftData

@Model
final class KefirBatch {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var lastManagedAt: Date
    var expectedRoutineHours: Int
    var storageModeRaw: String
    var alertsEnabled: Bool
    var sourceBatchId: UUID?
    var useLabel: String
    var notes: String
    var differentiationNote: String
    var plannedReactivationAt: Date?
    var archivedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        lastManagedAt: Date = .now,
        expectedRoutineHours: Int? = nil,
        storageMode: KefirStorageMode = .roomTemperature,
        alertsEnabled: Bool = true,
        sourceBatchId: UUID? = nil,
        useLabel: String = "",
        notes: String = "",
        differentiationNote: String = "",
        plannedReactivationAt: Date? = nil,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.lastManagedAt = lastManagedAt
        self.expectedRoutineHours = max(expectedRoutineHours ?? storageMode.defaultRoutineHours, 1)
        self.storageModeRaw = storageMode.rawValue
        self.alertsEnabled = alertsEnabled
        self.sourceBatchId = sourceBatchId
        self.useLabel = useLabel
        self.notes = notes
        self.differentiationNote = differentiationNote
        self.plannedReactivationAt = plannedReactivationAt
        self.archivedAt = archivedAt
    }

    var storageMode: KefirStorageMode {
        get { KefirStorageMode(rawValue: storageModeRaw) ?? .roomTemperature }
        set { storageModeRaw = newValue.rawValue }
    }

    var isArchived: Bool {
        archivedAt != nil
    }

    var supportsAutomaticAlerts: Bool {
        alertsEnabled && nextManagementAt != nil && !isArchived
    }

    var nextManagementAt: Date? {
        guard !isArchived else { return nil }

        switch storageMode {
        case .roomTemperature, .fridge:
            return Calendar.current.date(
                byAdding: .hour,
                value: max(expectedRoutineHours, 1),
                to: lastManagedAt
            ) ?? lastManagedAt
        case .freezer:
            return plannedReactivationAt
        }
    }

    var warningStartsAt: Date? {
        guard let dueAt = nextManagementAt,
              let warningLead = warningLeadTime(until: dueAt) else {
            return nil
        }
        return dueAt.addingTimeInterval(-warningLead)
    }

    var dueNowStartsAt: Date? {
        guard let dueAt = nextManagementAt,
              let warningLead = warningLeadTime(until: dueAt) else {
            return nil
        }
        let dueNowLead = min(storageMode.defaultDueNowLeadTime, warningLead)
        return dueAt.addingTimeInterval(-dueNowLead)
    }

    var derivedState: KefirBatchState {
        derivedState(at: .now)
    }

    func derivedState(at now: Date) -> KefirBatchState {
        if isArchived {
            return .archived
        }

        if storageMode == .freezer, plannedReactivationAt == nil {
            return .pausedFreezer
        }

        guard let dueAt = nextManagementAt else {
            return restingState
        }

        if now >= dueAt {
            return .overdue
        }

        if let dueNowStartsAt, now >= dueNowStartsAt {
            return .dueNow
        }

        if let warningStartsAt, now >= warningStartsAt {
            return .dueSoon
        }

        return restingState
    }

    var primaryAction: KefirPrimaryAction {
        primaryActionSuggestion(at: .now)
    }

    func primaryActionSuggestion(at now: Date) -> KefirPrimaryAction {
        switch derivedState(at: now) {
        case .dueSoon, .dueNow, .overdue:
            return storageMode == .freezer ? .reactivate : .renew
        case .active, .pausedFridge, .pausedFreezer:
            return .manage
        case .archived:
            return .open
        }
    }

    private var restingState: KefirBatchState {
        switch storageMode {
        case .roomTemperature:
            .active
        case .fridge:
            .pausedFridge
        case .freezer:
            .pausedFreezer
        }
    }

    private func warningLeadTime(until dueAt: Date) -> TimeInterval? {
        guard let baseLead = storageMode.defaultWarningLeadTime else {
            return nil
        }

        let totalInterval = max(dueAt.timeIntervalSince(lastManagedAt), 0)
        guard totalInterval > 0 else {
            return nil
        }

        if totalInterval > baseLead {
            return baseLead
        }

        return max(totalInterval / 2, 15 * 60)
    }

    func renew(at now: Date = .now) {
        lastManagedAt = now
        if storageMode == .freezer {
            plannedReactivationAt = nil
        }
    }

    func reactivate(at now: Date = .now) {
        storageMode = .roomTemperature
        expectedRoutineHours = KefirStorageMode.roomTemperature.defaultRoutineHours
        plannedReactivationAt = nil
        lastManagedAt = now
    }

    func applyManagementUpdate(
        storageMode newStorageMode: KefirStorageMode,
        expectedRoutineHours newExpectedRoutineHours: Int? = nil,
        plannedReactivationAt newPlannedReactivationAt: Date? = nil,
        at now: Date = .now
    ) {
        let didChangeStorage = storageMode != newStorageMode
        storageMode = newStorageMode

        if didChangeStorage {
            expectedRoutineHours = newStorageMode.defaultRoutineHours
        } else if let newExpectedRoutineHours {
            expectedRoutineHours = max(newExpectedRoutineHours, 1)
        }

        if newStorageMode == .freezer {
            plannedReactivationAt = newPlannedReactivationAt
        } else {
            plannedReactivationAt = nil
        }

        lastManagedAt = now
    }

    func archive(at now: Date = .now) {
        archivedAt = now
        plannedReactivationAt = nil
    }

    func sourceBatch(in batches: [KefirBatch]) -> KefirBatch? {
        guard let sourceBatchId else {
            return nil
        }

        return batches.first { $0.id == sourceBatchId }
    }

    func derivedBatches(in batches: [KefirBatch]) -> [KefirBatch] {
        batches
            .filter { $0.sourceBatchId == id }
            .sorted { lhs, rhs in
                if lhs.lastManagedAt != rhs.lastManagedAt {
                    return lhs.lastManagedAt > rhs.lastManagedAt
                }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }
}

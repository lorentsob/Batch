import Foundation
import SwiftData

@Model
final class BakeStep {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int
    var typeRaw: String
    var nameOverride: String
    var descriptionText: String
    var plannedStart: Date
    var plannedDurationMinutes: Int
    var flexibleWindowStart: Date?
    var flexibleWindowEnd: Date?
    var actualStart: Date?
    var actualEnd: Date?
    var reminderOffsetMinutes: Int
    var temperatureRange: String
    var volumeTarget: String
    var statusRaw: String
    var notes: String
    var photoURI: String
    var bake: Bake?

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        type: BakeStepType,
        nameOverride: String,
        descriptionText: String = "",
        plannedStart: Date,
        plannedDurationMinutes: Int,
        flexibleWindowStart: Date? = nil,
        flexibleWindowEnd: Date? = nil,
        actualStart: Date? = nil,
        actualEnd: Date? = nil,
        reminderOffsetMinutes: Int = 0,
        temperatureRange: String = "",
        volumeTarget: String = "",
        status: StepStatus = .pending,
        notes: String = "",
        photoURI: String = "",
        bake: Bake? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.typeRaw = type.rawValue
        self.nameOverride = nameOverride
        self.descriptionText = descriptionText
        self.plannedStart = plannedStart
        self.plannedDurationMinutes = plannedDurationMinutes
        self.flexibleWindowStart = flexibleWindowStart
        self.flexibleWindowEnd = flexibleWindowEnd
        self.actualStart = actualStart
        self.actualEnd = actualEnd
        self.reminderOffsetMinutes = reminderOffsetMinutes
        self.temperatureRange = temperatureRange
        self.volumeTarget = volumeTarget
        self.statusRaw = status.rawValue
        self.notes = notes
        self.photoURI = photoURI
        self.bake = bake
    }

    var type: BakeStepType {
        get { BakeStepType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var status: StepStatus {
        get { StepStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var plannedEnd: Date {
        plannedStart.adding(minutes: plannedDurationMinutes)
    }

    var displayName: String {
        nameOverride.isEmpty ? type.title : nameOverride
    }

    var isTerminal: Bool {
        [.done, .skipped].contains(status)
    }

    var isRunning: Bool {
        status == .running
    }

    var isPending: Bool {
        status == .pending
    }

    func currentProgress(now: Date = .now) -> Double {
        guard status == .running, let start = actualStart else { return 0 }
        let duration = Double(plannedDurationMinutes * 60)
        guard duration > 0 else { return 1.0 }
        let elapsed = now.timeIntervalSince(start)
        return min(max(elapsed / duration, 0), 1.0)
    }

    func isOverdue(now: Date = .now) -> Bool {
        guard status == .pending || status == .running else { return false }
        return plannedEnd < now
    }

    func start(at date: Date = .now) {
        status = .running
        actualStart = date
    }

    func complete(at date: Date = .now) {
        status = .done
        actualEnd = date
        if actualStart == nil {
            actualStart = plannedStart
        }
    }

    func skip() {
        status = .skipped
        actualEnd = .now
    }
}


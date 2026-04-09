import Foundation
import SwiftData

@Model
final class BakeStep {
    enum TimerPhase: Hashable {
        case upcoming
        case running
        case overdue
        case completed
    }

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
    /// JSON-encoded [String] of ingredient lines for this step (e.g. "500 g farina").
    /// nil or empty JSON means no ingredients to display.
    var ingredientsPayload: String?
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
        ingredients: [String] = [],
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
        self.ingredientsPayload = ingredients.isEmpty ? nil : (try? JSONEncoder().encode(ingredients)).flatMap { String(data: $0, encoding: .utf8) }
        self.bake = bake
    }

    /// Decoded ingredient lines for this step. Empty array if none.
    var stepIngredients: [String] {
        guard let raw = ingredientsPayload, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let items = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return items
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
        referenceStart.adding(minutes: plannedDurationMinutes)
    }

    var referenceStart: Date {
        actualStart ?? plannedStart
    }

    var displayName: String {
        if nameOverride == "Starter pronto" { return "Rinfresca starter" }
        return nameOverride.isEmpty ? type.title : nameOverride
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

    var isWindowBased: Bool {
        [.proof, .coldRetard].contains(type)
    }

    var windowStart: Date {
        guard isWindowBased else { return plannedStart }
        return flexibleWindowStart ?? plannedStart
    }

    var windowEnd: Date {
        guard isWindowBased else { return plannedEnd }
        return flexibleWindowEnd ?? plannedEnd
    }

    var requiresSequenceOverrideBeforeStart: Bool {
        guard status == .pending, let bake else { return false }
        return bake.sortedSteps.contains { step in
            step.orderIndex < orderIndex && step.isTerminal == false
        }
    }

    var startedOutOfOrder: Bool {
        guard let actualStart, let bake else { return false }
        return bake.sortedSteps.contains { step in
            guard step.orderIndex < orderIndex else { return false }
            if step.actualStart == nil, step.actualEnd == nil {
                return true
            }

            let priorStart = step.actualStart ?? .distantPast
            let priorEnd = step.actualEnd ?? .distantPast
            return max(priorStart, priorEnd) > actualStart
        }
    }

    func hasWindowOpened(now: Date = .now) -> Bool {
        guard isWindowBased else { return true }
        return now >= windowStart
    }

    func shouldShowCompactWindowState(now: Date = .now) -> Bool {
        isWindowBased && status == .running && hasWindowOpened(now: now) == false
    }

    func isOperationallyUrgent(now: Date = .now) -> Bool {
        guard status == .pending || status == .running else { return false }

        if isWindowBased && status == .running {
            return hasWindowOpened(now: now)
        }

        return status == .running || isOverdue(now: now)
    }

    func elapsedMinutes(now: Date = .now) -> Int {
        max(0, Int(now.timeIntervalSince(referenceStart)) / 60)
    }

    func remainingMinutes(now: Date = .now) -> Int {
        max(plannedDurationMinutes - elapsedMinutes(now: now), 0)
    }

    func overrunMinutes(now: Date = .now) -> Int {
        max(elapsedMinutes(now: now) - plannedDurationMinutes, 0)
    }

    func startsInMinutes(now: Date = .now) -> Int {
        max(Int(plannedStart.timeIntervalSince(now)) / 60, 0)
    }

    func progressValue(now: Date = .now) -> Double {
        let duration = Double(max(plannedDurationMinutes, 1))
        return min(max(Double(elapsedMinutes(now: now)) / duration, 0), 1)
    }

    func timerPhase(now: Date = .now) -> TimerPhase {
        if isTerminal { return .completed }
        if isOverdue(now: now) { return .overdue }
        if status == .running { return .running }
        return .upcoming
    }

    func currentProgress(now: Date = .now) -> Double {
        progressValue(now: now)
    }

    func isOverdue(now: Date = .now) -> Bool {
        guard status == .pending || status == .running else { return false }
        return windowEnd < now
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

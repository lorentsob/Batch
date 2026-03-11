import Foundation
import SwiftData

@Model
final class Starter {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var hydration: Double
    var flourMix: String
    var floursPayload: Data?
    var containerWeight: Double
    var storageModeRaw: String
    var refreshIntervalDays: Int
    var remindersEnabled: Bool
    var lastRefresh: Date
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \StarterRefresh.starter)
    var refreshes: [StarterRefresh]

    @Relationship(inverse: \Bake.starter)
    var bakes: [Bake]

    init(
        id: UUID = UUID(),
        name: String,
        type: StarterType,
        hydration: Double = 100,
        flourMix: String = "",
        flours: [FlourSelection] = [],
        containerWeight: Double = 0,
        storageMode: StorageMode = .fridge,
        refreshIntervalDays: Int = 7,
        remindersEnabled: Bool = true,
        lastRefresh: Date = .now,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.hydration = hydration
        self.flourMix = flourMix
        self.floursPayload = Starter.encode(flours: flours)
        self.containerWeight = containerWeight
        self.storageModeRaw = storageMode.rawValue
        self.refreshIntervalDays = refreshIntervalDays
        self.remindersEnabled = remindersEnabled
        self.lastRefresh = lastRefresh
        self.notes = notes
        self.refreshes = []
        self.bakes = []
    }

    var type: StarterType {
        get { StarterType(rawValue: typeRaw) ?? .mixed }
        set { typeRaw = newValue.rawValue }
    }

    var storageMode: StorageMode {
        get { StorageMode(rawValue: storageModeRaw) ?? .fridge }
        set { storageModeRaw = newValue.rawValue }
    }

    var selectedFlours: [FlourSelection] {
        get { Starter.decode(flours: floursPayload) }
        set { floursPayload = Starter.encode(flours: newValue) }
    }

    var nextDueDate: Date {
        Calendar.current.date(byAdding: .day, value: refreshIntervalDays, to: lastRefresh.startOfDay) ?? lastRefresh
    }

    func dueState(now: Date = .now) -> StarterDueState {
        let today = now.startOfDay
        let dueDay = nextDueDate.startOfDay
        if dueDay < today { return .overdue }
        if dueDay == today { return .dueToday }
        return .ok
    }

    private static func encode(flours: [FlourSelection]) -> Data {
        guard let data = try? JSONEncoder().encode(flours) else { return Data() }
        return data
    }

    private static func decode(flours payload: Data?) -> [FlourSelection] {
        guard let payload = payload, !payload.isEmpty,
              let flours = try? JSONDecoder().decode([FlourSelection].self, from: payload) else {
            return []
        }
        return flours
    }
}


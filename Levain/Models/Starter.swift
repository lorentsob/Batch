import Foundation
import SwiftData

@Model
final class Starter {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var hydration: Double
    var flourMix: String
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
}


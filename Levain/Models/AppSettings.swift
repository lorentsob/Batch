import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var didSeedSampleData: Bool = false
    var didSeedSystemFormulas: Bool = false
    var lastNotificationSync: Date?
    var hasRequestedNotificationPermission: Bool = false
    var isBakeEnabled: Bool = true
    var isStarterEnabled: Bool = true
    var isKefirEnabled: Bool = true

    init(
        id: UUID = UUID(),
        didSeedSampleData: Bool = false,
        didSeedSystemFormulas: Bool = false,
        lastNotificationSync: Date? = nil,
        hasRequestedNotificationPermission: Bool = false,
        isBakeEnabled: Bool = true,
        isStarterEnabled: Bool = true,
        isKefirEnabled: Bool = true
    ) {
        self.id = id
        self.didSeedSampleData = didSeedSampleData
        self.didSeedSystemFormulas = didSeedSystemFormulas
        self.lastNotificationSync = lastNotificationSync
        self.hasRequestedNotificationPermission = hasRequestedNotificationPermission
        self.isBakeEnabled = isBakeEnabled
        self.isStarterEnabled = isStarterEnabled
        self.isKefirEnabled = isKefirEnabled
    }
}


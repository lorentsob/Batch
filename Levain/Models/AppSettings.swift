import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var didSeedSampleData: Bool
    var lastNotificationSync: Date?
    var hasRequestedNotificationPermission: Bool

    init(
        id: UUID = UUID(),
        didSeedSampleData: Bool = false,
        lastNotificationSync: Date? = nil,
        hasRequestedNotificationPermission: Bool = false
    ) {
        self.id = id
        self.didSeedSampleData = didSeedSampleData
        self.lastNotificationSync = lastNotificationSync
        self.hasRequestedNotificationPermission = hasRequestedNotificationPermission
    }
}


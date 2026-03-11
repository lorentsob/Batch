import Foundation
import SwiftData
import UserNotifications

@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var pendingURL: URL?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorizationIfNeeded(settings: AppSettings?) async {
        guard settings?.hasRequestedNotificationPermission != true else { return }
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        settings?.hasRequestedNotificationPermission = true
    }

    func resyncAll(using modelContext: ModelContext) async {
        let bakes = (try? modelContext.fetch(FetchDescriptor<Bake>())) ?? []
        let starters = (try? modelContext.fetch(FetchDescriptor<Starter>())) ?? []
        for bake in bakes { await syncNotifications(for: bake) }
        for starter in starters { await syncNotifications(for: starter) }
    }

    func syncNotifications(for bake: Bake) async {
        let oldIdentifiers = bake.steps.map { "bake-\(bake.id.uuidString)-\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: oldIdentifiers)

        let reminders = BakeReminderPlanner.planReminders(for: bake)
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo["route"] = reminder.route

            try? await UNUserNotificationCenter.current().add(
                UNNotificationRequest(
                    identifier: reminder.identifier,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate),
                        repeats: false
                    )
                )
            )
        }
    }

    func syncNotifications(for starter: Starter) async {
        let identifiers = [dueIdentifier(starter.id), followUpIdentifier(starter.id)]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)

        let reminders = StarterReminderPlanner.planReminders(for: starter)
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo["route"] = reminder.route

            try? await UNUserNotificationCenter.current().add(
                UNNotificationRequest(
                    identifier: reminder.identifier,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(
                        dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate),
                        repeats: false
                    )
                )
            )
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let route = response.notification.request.content.userInfo["route"] as? String,
              let url = URL(string: route) else { return }
        await MainActor.run { pendingURL = url }
    }

    private func dueIdentifier(_ id: UUID) -> String { "starter-due-\(id.uuidString)" }
    private func followUpIdentifier(_ id: UUID) -> String { "starter-followup-\(id.uuidString)" }
}


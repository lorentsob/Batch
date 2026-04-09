import Foundation
import SwiftData
import UserNotifications

private struct NotificationRequestPayload: Sendable {
    let identifier: String
    let title: String
    let body: String
    let route: String
    let fireDate: Date
}

private struct NotificationSyncPlan: Sendable {
    let identifiersToRemove: [String]
    let requests: [NotificationRequestPayload]
}

private enum NotificationScheduler {
    @MainActor
    static func apply(_ plans: [NotificationSyncPlan]) async {
        let center = UNUserNotificationCenter.current()
        let identifiersToRemove = plans.flatMap(\.identifiersToRemove)

        if identifiersToRemove.isEmpty == false {
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }

        for plan in plans {
            for request in plan.requests {
                let content = UNMutableNotificationContent()
                content.title = request.title
                content.body = request.body
                content.sound = .default
                content.userInfo["route"] = request.route

                try? await center.add(
                    UNNotificationRequest(
                        identifier: request.identifier,
                        content: content,
                        trigger: UNCalendarNotificationTrigger(
                            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: request.fireDate),
                            repeats: false
                        )
                    )
                )
            }
        }
    }
}

@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    enum AuthorizationState: Equatable {
        case authorized
        case denied
        case notDetermined
    }

    @Published var pendingURL: URL?
    @Published private(set) var authorizationState: AuthorizationState = .notDetermined

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    @discardableResult
    func requestAuthorizationIfNeeded(settings: AppSettings?) async -> AuthorizationState {
        if AppLaunchOptions.shouldForceNotificationsDenied {
            authorizationState = .denied
            settings?.hasRequestedNotificationPermission = true
            return .denied
        }

        let center = UNUserNotificationCenter.current()
        let currentStatus = await Self.fetchAuthorizationStatus(center)
        if currentStatus == .denied {
            authorizationState = .denied
            settings?.hasRequestedNotificationPermission = true
            return .denied
        }

        if settings?.hasRequestedNotificationPermission != true {
            let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
            settings?.hasRequestedNotificationPermission = true
            if granted == false {
                let updatedStatus = await Self.fetchAuthorizationStatus(center)
                authorizationState = updatedStatus == .denied ? .denied : .notDetermined
                return authorizationState
            }
        }

        let refreshedStatus = await Self.fetchAuthorizationStatus(center)
        switch refreshedStatus {
        case .authorized, .provisional, .ephemeral:
            authorizationState = .authorized
        case .denied:
            authorizationState = .denied
        case .notDetermined:
            authorizationState = .notDetermined
        @unknown default:
            authorizationState = .notDetermined
        }

        return authorizationState
    }

    /// Fetches the authorization status from a nonisolated context,
    /// returning only the Sendable enum value to avoid crossing isolation boundaries.
    private nonisolated static func fetchAuthorizationStatus(_ center: UNUserNotificationCenter) async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func resyncAll(using modelContext: ModelContext) async {
        let bakes = (try? modelContext.fetch(FetchDescriptor<Bake>())) ?? []
        let starters = (try? modelContext.fetch(FetchDescriptor<Starter>())) ?? []
        let kefirBatches = (try? modelContext.fetch(FetchDescriptor<KefirBatch>())) ?? []

        let plans =
            bakes.map { makeSyncPlan(for: $0) } +
            starters.map { makeSyncPlan(for: $0) } +
            kefirBatches.map { makeSyncPlan(for: $0) }
        await NotificationScheduler.apply(plans)
    }

    func syncNotifications(forBake bakeID: UUID, in context: ModelContext) async {
        let descriptor = FetchDescriptor<Bake>(predicate: #Predicate { $0.id == bakeID })
        guard let bake = (try? context.fetch(descriptor))?.first else { return }
        await NotificationScheduler.apply([makeSyncPlan(for: bake)])
    }

    func syncNotifications(forStarter starterID: UUID, in context: ModelContext) async {
        let descriptor = FetchDescriptor<Starter>(predicate: #Predicate { $0.id == starterID })
        guard let starter = (try? context.fetch(descriptor))?.first else { return }
        await NotificationScheduler.apply([makeSyncPlan(for: starter)])
    }

    func syncNotifications(forKefirBatch batchID: UUID, in context: ModelContext) async {
        let descriptor = FetchDescriptor<KefirBatch>(predicate: #Predicate { $0.id == batchID })
        guard let batch = (try? context.fetch(descriptor))?.first else { return }
        await NotificationScheduler.apply([makeSyncPlan(for: batch)])
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

    func scheduleFridgeReminder(for refresh: StarterRefresh, starterName: String) async {
        let fireDate = refresh.dateTime.adding(minutes: 180) // 3 hours after refresh
        guard fireDate > Date.now else { return }
        guard let route = fridgeReminderRoute(for: refresh) else {
            assertionFailure("Unable to schedule fridge reminder without a real starter route")
            await cancelFridgeReminder(for: refresh)
            return
        }

        let plan = NotificationSyncPlan(
            identifiersToRemove: [],
            requests: [
                NotificationRequestPayload(
                    identifier: fridgeReminderIdentifier(refresh.id),
                    title: starterName,
                    body: "Sono passate 3 ore dal rinfresco. Vuoi mettere lo starter in frigo?",
                    route: route,
                    fireDate: fireDate
                )
            ]
        )
        await NotificationScheduler.apply([plan])
    }

    func cancelFridgeReminder(for refresh: StarterRefresh) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [fridgeReminderIdentifier(refresh.id)])
    }

    private func fridgeReminderIdentifier(_ id: UUID) -> String { "refresh-fridge-\(id.uuidString)" }
    private func dueIdentifier(_ id: UUID) -> String { "starter-due-\(id.uuidString)" }
    private func followUpIdentifier(_ id: UUID) -> String { "starter-followup-\(id.uuidString)" }

    func fridgeReminderRoute(for refresh: StarterRefresh) -> String? {
        guard let starterID = refresh.starter?.id else { return nil }
        return AppRouter.DeepLink.starter(id: starterID)
    }

    private func makeSyncPlan(for bake: Bake) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: BakeReminderPlanner.identifiers(for: bake),
            requests: BakeReminderPlanner.planReminders(for: bake).map { reminder in
                NotificationRequestPayload(
                    identifier: reminder.identifier,
                    title: reminder.title,
                    body: reminder.body,
                    route: reminder.route,
                    fireDate: reminder.fireDate
                )
            }
        )
    }

    private func makeSyncPlan(for starter: Starter) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: [dueIdentifier(starter.id), followUpIdentifier(starter.id)],
            requests: StarterReminderPlanner.planReminders(for: starter).map { reminder in
                NotificationRequestPayload(
                    identifier: reminder.identifier,
                    title: reminder.title,
                    body: reminder.body,
                    route: reminder.route,
                    fireDate: reminder.fireDate
                )
            }
        )
    }

    private func makeSyncPlan(for batch: KefirBatch) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: KefirReminderPlanner.identifiers(for: batch),
            requests: KefirReminderPlanner.planReminders(for: batch).map { reminder in
                NotificationRequestPayload(
                    identifier: reminder.identifier,
                    title: reminder.title,
                    body: reminder.body,
                    route: reminder.route,
                    fireDate: reminder.fireDate
                )
            }
        )
    }
}

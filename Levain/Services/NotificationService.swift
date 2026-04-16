import Foundation
import SwiftData
import UserNotifications

struct NotificationRequestPayload: Sendable, Equatable {
    let identifier: String
    let title: String
    let body: String
    let route: String
    let fireDate: Date
}

struct NotificationSyncPlan: Sendable, Equatable {
    let identifiersToRemove: [String]
    let requests: [NotificationRequestPayload]
}

enum NotificationPlanningDefaults {
    static let overdueReminderHour = 19
    static let overdueReminderMinute = 0
    static let overdueWindowDays = 7
    static let maxPendingRequests = 60
}

enum RollingOverdueReminderPlanner {
    static func reminderDates(
        overdueSince: Date,
        now: Date = .now,
        windowDays: Int = NotificationPlanningDefaults.overdueWindowDays
    ) -> [Date] {
        guard windowDays > 0 else { return [] }

        let windowDates = identifierDates(now: now, windowDays: windowDays)
        guard let windowEnd = windowDates.last else { return [] }

        let firstEligibleDate = max(firstReminderDate(after: overdueSince), firstReminderDate(after: now))
        guard firstEligibleDate <= windowEnd else { return [] }

        return windowDates.filter { $0 >= firstEligibleDate }
    }

    static func identifierDates(
        now: Date = .now,
        windowDays: Int = NotificationPlanningDefaults.overdueWindowDays
    ) -> [Date] {
        guard windowDays > 0 else { return [] }

        let firstFutureReminder = firstReminderDate(after: now)
        return (0..<windowDays).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: firstFutureReminder)
        }
    }

    static func identifierSuffix(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d%02d%02d", year, month, day)
    }

    private static func firstReminderDate(after reference: Date) -> Date {
        let sameDayReminder = reference.settingTime(
            hour: NotificationPlanningDefaults.overdueReminderHour,
            minute: NotificationPlanningDefaults.overdueReminderMinute
        )

        if sameDayReminder > reference {
            return sameDayReminder
        }

        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: reference.startOfDay) ?? reference
        return nextDay.settingTime(
            hour: NotificationPlanningDefaults.overdueReminderHour,
            minute: NotificationPlanningDefaults.overdueReminderMinute
        )
    }
}

enum NotificationPlanBuilder {
    static func buildGlobalPlan(
        bakes: [Bake],
        starters: [Starter],
        kefirBatches: [KefirBatch],
        now: Date = .now
    ) -> NotificationSyncPlan {
        let plans =
            bakes.map { makePlan(for: $0, now: now) } +
            starters.map { makePlan(for: $0, now: now) } +
            kefirBatches.map { makePlan(for: $0, now: now) }

        return merge(plans: plans, now: now)
    }

    static func merge(plans: [NotificationSyncPlan], now: Date = .now) -> NotificationSyncPlan {
        let identifiersToRemove = Array(Set(plans.flatMap(\.identifiersToRemove))).sorted()

        let sortedRequests = plans
            .flatMap(\.requests)
            .filter { $0.fireDate > now }
            .sorted {
                if $0.fireDate == $1.fireDate {
                    return $0.identifier < $1.identifier
                }
                return $0.fireDate < $1.fireDate
            }

        var seenIdentifiers = Set<String>()
        var requests: [NotificationRequestPayload] = []
        requests.reserveCapacity(min(sortedRequests.count, NotificationPlanningDefaults.maxPendingRequests))

        for request in sortedRequests where requests.count < NotificationPlanningDefaults.maxPendingRequests {
            guard seenIdentifiers.insert(request.identifier).inserted else { continue }
            requests.append(request)
        }

        return NotificationSyncPlan(
            identifiersToRemove: identifiersToRemove,
            requests: requests
        )
    }

    private static func makePlan(for bake: Bake, now: Date) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: BakeReminderPlanner.identifiers(for: bake, now: now),
            requests: BakeReminderPlanner.planReminders(for: bake, now: now).map { reminder in
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

    private static func makePlan(for starter: Starter, now: Date) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: StarterReminderPlanner.identifiers(for: starter, now: now),
            requests: StarterReminderPlanner.planReminders(for: starter, now: now).map { reminder in
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

    private static func makePlan(for batch: KefirBatch, now: Date) -> NotificationSyncPlan {
        NotificationSyncPlan(
            identifiersToRemove: KefirReminderPlanner.identifiers(for: batch, now: now),
            requests: KefirReminderPlanner.planReminders(for: batch, now: now).map { reminder in
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

        let plan = NotificationPlanBuilder.buildGlobalPlan(
            bakes: bakes,
            starters: starters,
            kefirBatches: kefirBatches
        )
        await NotificationScheduler.apply([plan])
    }

    func syncNotifications(forBake _: UUID, in context: ModelContext) async {
        await resyncAll(using: context)
    }

    func syncNotifications(forStarter _: UUID, in context: ModelContext) async {
        await resyncAll(using: context)
    }

    func syncNotifications(forKefirBatch _: UUID, in context: ModelContext) async {
        await resyncAll(using: context)
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

    func fridgeReminderRoute(for refresh: StarterRefresh) -> String? {
        guard let starterID = refresh.starter?.id else { return nil }
        return AppRouter.DeepLink.starter(id: starterID)
    }
}

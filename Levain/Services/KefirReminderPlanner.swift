import Foundation

struct KefirReminderRequest: Equatable {
    let identifier: String
    let fireDate: Date
    let title: String
    let body: String
    let route: String
}

enum KefirReminderPlanner {
    enum Phase: String, CaseIterable {
        case warning
        case due
    }

    static func planReminders(for batch: KefirBatch, now: Date = .now) -> [KefirReminderRequest] {
        guard batch.alertsEnabled, batch.isArchived == false else { return [] }
        guard let dueAt = batch.nextManagementAt else { return [] }

        let route = AppRouter.DeepLink.kefirBatch(id: batch.id)
        var reminders: [KefirReminderRequest] = []

        if let warningAt = batch.warningStartsAt, warningAt > now {
            reminders.append(
                KefirReminderRequest(
                    identifier: identifier(for: batch, phase: .warning),
                    fireDate: warningAt,
                    title: batch.name,
                    body: warningBody(for: batch),
                    route: route
                )
            )
        }

        if dueAt > now {
            reminders.append(
                KefirReminderRequest(
                    identifier: identifier(for: batch, phase: .due),
                    fireDate: dueAt,
                    title: batch.name,
                    body: dueBody(for: batch),
                    route: route
                )
            )
        }

        reminders.append(contentsOf:
            RollingOverdueReminderPlanner.reminderDates(overdueSince: dueAt, now: now).map { fireDate in
                KefirReminderRequest(
                    identifier: overdueIdentifier(for: batch, on: fireDate),
                    fireDate: fireDate,
                    title: batch.name,
                    body: overdueBody(for: batch),
                    route: route
                )
            }
        )

        return reminders
    }

    static func identifiers(for batch: KefirBatch, now: Date = .now) -> [String] {
        Phase.allCases.map { identifier(for: batch, phase: $0) } +
        RollingOverdueReminderPlanner.identifierDates(now: now).map { overdueIdentifier(for: batch, on: $0) }
    }

    private static func identifier(for batch: KefirBatch, phase: Phase) -> String {
        "kefir-\(phase.rawValue)-\(batch.id.uuidString)"
    }

    private static func warningBody(for batch: KefirBatch) -> String {
        switch batch.storageMode {
        case .roomTemperature:
            return "Tra poco sarà il momento di rinnovare il batch."
        case .fridge:
            return "Domani dovrai controllare il batch in frigo."
        case .freezer:
            return "Tra poco sarà il momento di riattivare il batch."
        }
    }

    private static func dueBody(for batch: KefirBatch) -> String {
        switch batch.storageMode {
        case .roomTemperature:
            return "È il momento di rinnovare il batch."
        case .fridge:
            return "È il momento di controllare il batch in frigo."
        case .freezer:
            return "È il momento di riattivare il batch."
        }
    }

    private static func overdueBody(for batch: KefirBatch) -> String {
        switch batch.storageMode {
        case .roomTemperature:
            return "Non hai ancora rinnovato \(batch.name)."
        case .fridge:
            return "Non hai ancora controllato \(batch.name)."
        case .freezer:
            return "Non hai ancora riattivato \(batch.name)."
        }
    }

    private static func overdueIdentifier(for batch: KefirBatch, on fireDate: Date) -> String {
        "kefir-overdue-\(batch.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: fireDate))"
    }
}

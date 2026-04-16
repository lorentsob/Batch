import Foundation

struct StarterReminderRequest: Equatable {
    let identifier: String
    let fireDate: Date
    let title: String
    let body: String
    let route: String
}

enum StarterReminderPlanner {
    static func planReminders(for starter: Starter, now: Date = .now) -> [StarterReminderRequest] {
        guard starter.remindersEnabled, starter.isArchived == false else { return [] }

        let due = starter.nextDueDate.settingTime(hour: 9, minute: 0)
        let route = AppRouter.DeepLink.starter(id: starter.id)
        let overdueSince = (Calendar.current.date(byAdding: .day, value: 1, to: starter.nextDueDate.startOfDay) ?? starter.nextDueDate)
            .startOfDay

        var reminders: [StarterReminderRequest] = []

        if due > now {
            reminders.append(
                StarterReminderRequest(
                    identifier: dueIdentifier(for: starter),
                    fireDate: due,
                    title: starter.name,
                    body: "Oggi è previsto un rinfresco. Apri lo starter per registrarlo.",
                    route: route
                )
            )
        }

        reminders.append(contentsOf:
            RollingOverdueReminderPlanner.reminderDates(overdueSince: overdueSince, now: now).map { fireDate in
                StarterReminderRequest(
                    identifier: overdueIdentifier(for: starter, on: fireDate),
                    fireDate: fireDate,
                    title: starter.name,
                    body: "Non hai ancora rinfrescato \(starter.name).",
                    route: route
                )
            }
        )

        return reminders
    }

    static func identifiers(for starter: Starter, now: Date = .now) -> [String] {
        [dueIdentifier(for: starter), legacyFollowUpIdentifier(for: starter)] +
        RollingOverdueReminderPlanner.identifierDates(now: now).map { overdueIdentifier(for: starter, on: $0) }
    }

    private static func dueIdentifier(for starter: Starter) -> String {
        "starter-due-\(starter.id.uuidString)"
    }

    private static func legacyFollowUpIdentifier(for starter: Starter) -> String {
        "starter-followup-\(starter.id.uuidString)"
    }

    private static func overdueIdentifier(for starter: Starter, on fireDate: Date) -> String {
        "starter-overdue-\(starter.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: fireDate))"
    }
}

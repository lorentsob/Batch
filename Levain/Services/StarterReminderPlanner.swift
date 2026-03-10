import Foundation

struct StarterReminderRequest: Equatable {
    let identifier: String
    let fireDate: Date
    let title: String
    let body: String
    let route: String
}

enum StarterReminderPlanner {
    static func planReminders(for starter: Starter) -> [StarterReminderRequest] {
        guard starter.remindersEnabled else { return [] }

        let due = starter.nextDueDate.settingTime(hour: 9, minute: 0)
        let followUp = due.adding(minutes: 24 * 60)

        let route = AppRouter.DeepLink.starter(id: starter.id)

        let dueRequest = StarterReminderRequest(
            identifier: "starter-due-\(starter.id.uuidString)",
            fireDate: due,
            title: starter.name,
            body: "Rinfresco previsto oggi.",
            route: route
        )

        let followUpRequest = StarterReminderRequest(
            identifier: "starter-followup-\(starter.id.uuidString)",
            fireDate: followUp,
            title: starter.name,
            body: "Ancora nessun rinfresco registrato.",
            route: route
        )

        return [dueRequest, followUpRequest]
    }
}

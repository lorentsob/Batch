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
            body: "Oggi è previsto un rinfresco. Apri lo starter per registrarlo.",
            route: route
        )

        let followUpRequest = StarterReminderRequest(
            identifier: "starter-followup-\(starter.id.uuidString)",
            fireDate: followUp,
            title: starter.name,
            body: "Non hai ancora registrato il rinfresco di oggi. Apri lo starter per farlo adesso.",
            route: route
        )

        return [dueRequest, followUpRequest]
    }
}

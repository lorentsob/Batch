import Foundation

struct BakeReminder: Equatable {
    let identifier: String
    let title: String
    let body: String
    let route: String
    let fireDate: Date
}

enum BakeReminderPlanner {
    static func planReminders(for bake: Bake, now: Date = .now) -> [BakeReminder] {
        var reminders: [BakeReminder] = []
        
        for step in bake.sortedSteps where step.isTerminal == false {
            let fireDate = step.plannedStart.adding(minutes: -step.reminderOffsetMinutes)
            guard fireDate > now else { continue }
            
            let reminder = BakeReminder(
                identifier: "bake-\(bake.id.uuidString)-\(step.id.uuidString)",
                title: "\(step.displayName) · \(bake.name)",
                body: step.status == .running ? "Lo step è in corso." : "È il momento di controllare questo passaggio.",
                route: AppRouter.DeepLink.bake(id: bake.id),
                fireDate: fireDate
            )
            reminders.append(reminder)
        }
        
        return reminders
    }
}

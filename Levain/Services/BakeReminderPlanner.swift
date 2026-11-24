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
        guard bake.derivedStatus != .cancelled, bake.derivedStatus != .completed else {
            return []
        }

        var reminders: [BakeReminder] = []
        if let activeStep = bake.activeStep, activeStep.isOverdue(now: now) {
            reminders.append(contentsOf: overdueReminders(for: bake, step: activeStep, now: now))
        }

        for step in bake.sortedSteps where step.isTerminal == false {
            if step.isWindowBased, step.status == .running {
                reminders.append(contentsOf: windowReminders(for: bake, step: step, now: now))
                continue
            }

            let fireDate = step.plannedStart.adding(minutes: -step.reminderOffsetMinutes)
            guard fireDate > now else { continue }

            reminders.append(
                BakeReminder(
                    identifier: identifier(for: bake, step: step, phase: .start),
                    title: "\(step.displayName) · \(bake.name)",
                    body: step.status == .running ? "Questa fase è in corso. Aprila per completarla." : "È il momento della prossima fase.",
                    route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                    fireDate: fireDate
                )
            )
        }

        return reminders
    }

    static func identifiers(for bake: Bake, now: Date = .now) -> [String] {
        bake.steps.flatMap { step in
            ReminderPhase.allCases.map { identifier(for: bake, step: step, phase: $0) } +
            RollingOverdueReminderPlanner.identifierDates(now: now).map { overdueIdentifier(for: bake, step: step, on: $0) }
        }
    }

    private static func windowReminders(for bake: Bake, step: BakeStep, now: Date) -> [BakeReminder] {
        var reminders: [BakeReminder] = []

        if step.windowStart > now {
            reminders.append(
                BakeReminder(
                    identifier: identifier(for: bake, step: step, phase: .start),
                    title: "\(step.displayName) · \(bake.name)",
                    body: "Il tuo impasto è pronto per la fase successiva. Aprilo per continuare.",
                    route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                    fireDate: step.windowStart
                )
            )
        }

        if step.windowEnd > now {
            reminders.append(
                BakeReminder(
                    identifier: identifier(for: bake, step: step, phase: .windowClose),
                    title: "\(step.displayName) · \(bake.name)",
                    body: "È il momento di completare questa fase.",
                    route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                    fireDate: step.windowEnd
                )
            )
        }

        return reminders
    }

    private static func overdueReminders(for bake: Bake, step: BakeStep, now: Date) -> [BakeReminder] {
        RollingOverdueReminderPlanner.reminderDates(overdueSince: step.windowEnd, now: now).map { fireDate in
            BakeReminder(
                identifier: overdueIdentifier(for: bake, step: step, on: fireDate),
                title: "\(step.displayName) · \(bake.name)",
                body: "Non hai ancora completato \(step.displayName) di \(bake.name).",
                route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                fireDate: fireDate
            )
        }
    }

    private enum ReminderPhase: String, CaseIterable {
        case start
        case windowClose
    }

    private static func identifier(for bake: Bake, step: BakeStep, phase: ReminderPhase) -> String {
        "bake-\(phase.rawValue)-\(bake.id.uuidString)-\(step.id.uuidString)"
    }

    private static func overdueIdentifier(for bake: Bake, step: BakeStep, on fireDate: Date) -> String {
        "bake-overdue-\(bake.id.uuidString)-\(step.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: fireDate))"
    }
}

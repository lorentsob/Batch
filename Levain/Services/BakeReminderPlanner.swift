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
                    body: step.status == .running ? "Questo passaggio è in corso. Apri l'impasto per aggiornarlo." : "È il momento di intervenire su questo passaggio. Apri l'impasto per continuare.",
                    route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                    fireDate: fireDate
                )
            )
        }

        return reminders
    }

    static func identifiers(for bake: Bake) -> [String] {
        bake.steps.flatMap { step in
            ReminderPhase.allCases.map { identifier(for: bake, step: step, phase: $0) }
        }
    }

    private static func windowReminders(for bake: Bake, step: BakeStep, now: Date) -> [BakeReminder] {
        var reminders: [BakeReminder] = []

        if step.windowStart > now {
            reminders.append(
                BakeReminder(
                    identifier: identifier(for: bake, step: step, phase: .start),
                    title: "\(step.displayName) · \(bake.name)",
                    body: "Il tuo impasto è pronto per il prossimo passaggio. Aprilo per continuare.",
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
                    body: "La finestra utile sta per chiudersi. Apri l'impasto se devi intervenire ora.",
                    route: AppRouter.DeepLink.bake(id: bake.id, stepID: step.id),
                    fireDate: step.windowEnd
                )
            )
        }

        return reminders
    }

    private enum ReminderPhase: String, CaseIterable {
        case start
        case windowClose
    }

    private static func identifier(for bake: Bake, step: BakeStep, phase: ReminderPhase) -> String {
        "bake-\(phase.rawValue)-\(bake.id.uuidString)-\(step.id.uuidString)"
    }
}

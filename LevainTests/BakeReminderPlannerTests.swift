import Foundation
import Testing
@testable import Levain

@Suite("Bake Reminder Planner Tests")
struct BakeReminderPlannerTests {
    @Test("Terminal steps do not generate reminders")
    func testTerminalStepsSkipped() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(target: now.addingTimeInterval(3600))

        let doneStep = BakeStep(orderIndex: 0, type: .mix, nameOverride: "Mix", plannedStart: now.addingTimeInterval(100), plannedDurationMinutes: 30)
        doneStep.status = .done

        let skippedStep = BakeStep(orderIndex: 1, type: .bulk, nameOverride: "Bulk", plannedStart: now.addingTimeInterval(200), plannedDurationMinutes: 30)
        skippedStep.status = .skipped
        skippedStep.bake = bake
        doneStep.bake = bake
        bake.steps = [doneStep, skippedStep]

        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.isEmpty)
    }

    @Test("Past fire dates do not generate reminders")
    func testPastFireDatesSkipped() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(target: now.addingTimeInterval(3600))

        let pastStep = BakeStep(orderIndex: 0, type: .bulk, nameOverride: "Bulk", plannedStart: now.addingTimeInterval(-100), plannedDurationMinutes: 30)
        pastStep.status = .running
        pastStep.bake = bake
        bake.steps = [pastStep]

        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.isEmpty)
    }

    @Test("Reminders generated correctly with deep-link step payloads")
    func testRemindersGeneratedAndOffsetsApplied() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(name: "My Bread", target: now.addingTimeInterval(3600))

        let pendingStep = BakeStep(
            orderIndex: 0,
            type: .shape,
            nameOverride: "Shape",
            plannedStart: now.addingTimeInterval(3600),
            plannedDurationMinutes: 30,
            reminderOffsetMinutes: 15
        )
        pendingStep.status = .pending
        pendingStep.bake = bake
        bake.steps = [pendingStep]

        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.count == 1)

        if let reminder = reminders.first {
            #expect(reminder.title == "Shape · My Bread")
            #expect(reminder.body == "È il momento di controllare questo passaggio.")
            #expect(reminder.route == "levain://bake/\(bake.id.uuidString)?step=\(pendingStep.id.uuidString)")
            #expect(reminder.fireDate == now.addingTimeInterval(2700))
            #expect(reminder.identifier == "bake-start-\(bake.id.uuidString)-\(pendingStep.id.uuidString)")
        }
    }

    @Test("Window-based running steps generate open and close reminders")
    func testWindowBasedRunningStepReminders() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(name: "My Bread", target: now.addingTimeInterval(3600))

        let runningStep = BakeStep(
            orderIndex: 0,
            type: .coldRetard,
            nameOverride: "Cold retard",
            plannedStart: now.addingTimeInterval(-3600),
            plannedDurationMinutes: 180,
            flexibleWindowStart: now.addingTimeInterval(1800),
            flexibleWindowEnd: now.addingTimeInterval(3600),
            actualStart: now.addingTimeInterval(-3600)
        )
        runningStep.status = .running
        runningStep.bake = bake
        bake.steps = [runningStep]

        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.count == 2)
        #expect(reminders[0].body == "Il tuo impasto è pronto per la prossima azione.")
        #expect(reminders[1].body == "La finestra si sta chiudendo.")
    }
}

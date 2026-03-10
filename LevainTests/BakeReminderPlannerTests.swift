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
    
    @Test("Reminders generated correctly with offsets")
    func testRemindersGeneratedAndOffsetsApplied() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(name: "My Bread", target: now.addingTimeInterval(3600))
        
        // plannedStart is now + 60 mins, offset is 15 mins -> fireDate should be now + 45 mins
        let pendingStep = BakeStep(orderIndex: 0, type: .shape, nameOverride: "Shape", plannedStart: now.addingTimeInterval(3600), plannedDurationMinutes: 30, reminderOffsetMinutes: 15)
        pendingStep.status = .pending
        pendingStep.bake = bake
        
        bake.steps = [pendingStep]
        
        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.count == 1)
        
        if let reminder = reminders.first {
            #expect(reminder.title == "Shape · My Bread")
            #expect(reminder.body == "È il momento di controllare questo passaggio.")
            #expect(reminder.route == "levain://bake/\(bake.id.uuidString)")
            #expect(reminder.fireDate == now.addingTimeInterval(2700)) // 45 * 60
            #expect(reminder.identifier == "bake-\(bake.id.uuidString)-\(pendingStep.id.uuidString)")
        }
    }
    
    @Test("Running steps get running body text")
    func testRunningStepBody() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(name: "My Bread", target: now.addingTimeInterval(3600))
        
        let runningStep = BakeStep(orderIndex: 0, type: .shape, nameOverride: "Shape", plannedStart: now.addingTimeInterval(3600), plannedDurationMinutes: 30)
        runningStep.status = .running
        runningStep.bake = bake
        bake.steps = [runningStep]
        
        let reminders = BakeReminderPlanner.planReminders(for: bake, now: now)
        #expect(reminders.count == 1)
        #expect(reminders.first?.body == "Lo step è in corso.")
    }
}

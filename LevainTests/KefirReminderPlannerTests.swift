import Foundation
import Testing
@testable import Levain

@Suite("Kefir Reminder Planner")
struct KefirReminderPlannerTests {
    @Test("Room-temperature batch schedules warning and due reminders on the daily cadence")
    func testRoomTemperatureReminderPlan() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let batch = DomainFixtures.makeKefirBatch(
            name: "Batch cucina",
            storageMode: .roomTemperature,
            lastManagedAt: now
        )

        let reminders = KefirReminderPlanner.planReminders(for: batch, now: now)

        #expect(reminders.count == 8)
        #expect(reminders[0].fireDate == now.addingTimeInterval(20 * 60 * 60))
        #expect(reminders[1].fireDate == now.addingTimeInterval(24 * 60 * 60))
        #expect(reminders[0].body == "Tra poco sarà il momento di rinnovare il batch.")
        #expect(reminders[1].body == "È il momento di rinnovare il batch.")
        #expect(reminders[0].route == AppRouter.DeepLink.kefirBatch(id: batch.id))
        #expect(reminders[2].identifier == "kefir-overdue-\(batch.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: now.startOfDay.adding(minutes: 24 * 60).settingTime(hour: 19, minute: 0)))")
        #expect(reminders[2].body == "Non hai ancora rinnovato \(batch.name).")
        #expect(reminders[2].fireDate == now.startOfDay.adding(minutes: 24 * 60).settingTime(hour: 19, minute: 0))
    }

    @Test("Fridge batch schedules next-day warning and due reminders on the weekly cadence")
    func testFridgeReminderPlan() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let batch = DomainFixtures.makeKefirBatch(
            name: "Backup frigo",
            storageMode: .fridge,
            lastManagedAt: now
        )

        let reminders = KefirReminderPlanner.planReminders(for: batch, now: now)

        #expect(reminders.count == 2)
        #expect(reminders[0].fireDate == now.addingTimeInterval(6 * 24 * 60 * 60))
        #expect(reminders[1].fireDate == now.addingTimeInterval(7 * 24 * 60 * 60))
        #expect(reminders[0].body == "Domani dovrai controllare il batch in frigo.")
        #expect(reminders[1].body == "È il momento di controllare il batch in frigo.")
    }

    @Test("Freezer batch without planned reactivation does not schedule reminders")
    func testFreezerWithoutReactivationHasNoReminders() {
        let now = Date.fixedNow
        let batch = DomainFixtures.makeKefirBatch(
            storageMode: .freezer,
            lastManagedAt: now.addingTimeInterval(-(14 * 24 * 60 * 60))
        )

        let reminders = KefirReminderPlanner.planReminders(for: batch, now: now)

        #expect(reminders.isEmpty)
    }

    @Test("Planned freezer reactivation schedules warning and due reminders")
    func testPlannedFreezerReactivationReminderPlan() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let dueAt = now.addingTimeInterval(5 * 24 * 60 * 60)
        let batch = DomainFixtures.makeKefirBatch(
            name: "Scorta freezer",
            storageMode: .freezer,
            lastManagedAt: now.addingTimeInterval(-(14 * 24 * 60 * 60)),
            plannedReactivationAt: dueAt
        )

        let reminders = KefirReminderPlanner.planReminders(for: batch, now: now)

        #expect(reminders.count == 4)
        #expect(reminders[0].fireDate == dueAt.addingTimeInterval(-(24 * 60 * 60)))
        #expect(reminders[1].fireDate == dueAt)
        #expect(reminders[0].body == "Tra poco sarà il momento di riattivare il batch.")
        #expect(reminders[1].body == "È il momento di riattivare il batch.")
        #expect(reminders[2].body == "Non hai ancora riattivato \(batch.name).")
        #expect(reminders[2].fireDate == dueAt.settingTime(hour: 19, minute: 0))
    }

    @Test("Archived or alerts-disabled batches do not schedule reminders")
    func testArchivedOrAlertsDisabledBatchesReturnNoReminders() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let archived = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now,
            archivedAt: now.addingTimeInterval(-60)
        )
        let silenced = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now,
            alertsEnabled: false
        )

        #expect(KefirReminderPlanner.planReminders(for: archived, now: now).isEmpty)
        #expect(KefirReminderPlanner.planReminders(for: silenced, now: now).isEmpty)
        #expect(KefirReminderPlanner.identifiers(for: silenced, now: now).count == 2 + NotificationPlanningDefaults.overdueWindowDays)
    }
}

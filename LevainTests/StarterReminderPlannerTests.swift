import XCTest
@testable import Levain

final class StarterReminderPlannerTests: XCTestCase {
    func testRemindersDisabledReturnsEmpty() {
        let starter = DomainFixtures.makeStarter()
        starter.remindersEnabled = false

        let requests = StarterReminderPlanner.planReminders(for: starter)
        XCTAssertTrue(requests.isEmpty)
    }

    func testRemindersEnabledReturnsDueAndFollowUp() {
        let today = Date.fixedNow
        let starter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: today
        )
        starter.remindersEnabled = true

        let requests = StarterReminderPlanner.planReminders(for: starter)
        XCTAssertEqual(requests.count, 2)

        let due = requests[0]
        XCTAssertEqual(due.identifier, "starter-due-\(starter.id.uuidString)")
        XCTAssertEqual(due.title, starter.name)
        XCTAssertEqual(due.body, "Oggi è previsto un rinfresco. Apri lo starter per registrarlo.")
        let nextDueDate = Calendar.current.date(byAdding: .day, value: 7, to: today.startOfDay)!
        XCTAssertEqual(due.fireDate, nextDueDate.settingTime(hour: 9, minute: 0))

        let followUp = requests[1]
        XCTAssertEqual(followUp.identifier, "starter-followup-\(starter.id.uuidString)")
        XCTAssertEqual(followUp.title, starter.name)
        XCTAssertEqual(followUp.body, "Non hai ancora registrato il rinfresco di oggi. Apri lo starter per farlo adesso.")
        XCTAssertEqual(followUp.fireDate, nextDueDate.settingTime(hour: 9, minute: 0).adding(minutes: 24 * 60))
    }
}

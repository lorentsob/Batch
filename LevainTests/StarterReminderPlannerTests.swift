import XCTest
@testable import Levain

final class StarterReminderPlannerTests: XCTestCase {
    func testRemindersDisabledReturnsEmpty() {
        let starter = DomainFixtures.makeStarter()
        starter.remindersEnabled = false

        let requests = StarterReminderPlanner.planReminders(for: starter, now: .fixedNow)
        XCTAssertTrue(requests.isEmpty)
    }

    func testDueReminderStaysAtNineAndOverdueSeriesStartsTheDayAfter() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let starter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: now.adding(minutes: -(7 * 24 * 60))
        )
        starter.remindersEnabled = true

        let requests = StarterReminderPlanner.planReminders(for: starter, now: now)
        XCTAssertEqual(requests.count, 7)

        let due = requests[0]
        XCTAssertEqual(due.identifier, "starter-due-\(starter.id.uuidString)")
        XCTAssertEqual(due.title, starter.name)
        XCTAssertEqual(due.body, "Oggi è previsto un rinfresco. Apri lo starter per registrarlo.")
        let nextDueDate = Calendar.current.date(byAdding: .day, value: 7, to: starter.lastRefresh.startOfDay)!
        XCTAssertEqual(due.fireDate, nextDueDate.settingTime(hour: 9, minute: 0))

        let overdue = Array(requests.dropFirst())
        XCTAssertEqual(overdue.count, 6)
        XCTAssertEqual(overdue.first?.identifier, "starter-overdue-\(starter.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: now.startOfDay.adding(minutes: 24 * 60).settingTime(hour: 19, minute: 0)))")
        XCTAssertEqual(overdue.first?.title, starter.name)
        XCTAssertEqual(overdue.first?.body, "Non hai ancora rinfrescato \(starter.name).")
        XCTAssertEqual(overdue.first?.fireDate, now.startOfDay.adding(minutes: 24 * 60).settingTime(hour: 19, minute: 0))
        XCTAssertEqual(overdue.last?.fireDate, now.startOfDay.adding(minutes: 6 * 24 * 60).settingTime(hour: 19, minute: 0))
    }

    func testAlreadyOverdueStarterSchedulesTodayAtSevenPm() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 10, minute: 0)
        let starter = DomainFixtures.makeStarter(
            name: "Madre attiva",
            refreshIntervalDays: 1,
            lastRefresh: now.adding(minutes: -(2 * 24 * 60))
        )

        let requests = StarterReminderPlanner.planReminders(for: starter, now: now)

        XCTAssertEqual(requests.first?.identifier, "starter-overdue-\(starter.id.uuidString)-\(RollingOverdueReminderPlanner.identifierSuffix(for: now.settingTime(hour: 19, minute: 0)))")
        XCTAssertEqual(requests.first?.fireDate, now.settingTime(hour: 19, minute: 0))
        XCTAssertEqual(requests.count, NotificationPlanningDefaults.overdueWindowDays)
    }

    func testArchivedStarterReturnsNoRequestsButIdentifiersStillCoverLegacyAndWindow() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 10, minute: 0)
        let starter = DomainFixtures.makeStarter(refreshIntervalDays: 1, lastRefresh: now.adding(minutes: -(2 * 24 * 60)))
        starter.archive()

        XCTAssertTrue(StarterReminderPlanner.planReminders(for: starter, now: now).isEmpty)

        let identifiers = StarterReminderPlanner.identifiers(for: starter, now: now)
        XCTAssertTrue(identifiers.contains("starter-due-\(starter.id.uuidString)"))
        XCTAssertTrue(identifiers.contains("starter-followup-\(starter.id.uuidString)"))
        XCTAssertEqual(
            identifiers.filter { $0.contains("starter-overdue-\(starter.id.uuidString)-") }.count,
            NotificationPlanningDefaults.overdueWindowDays
        )
    }
}

final class NotificationPlanBuilderTests: XCTestCase {
    func testMergeSortsDeduplicatesAndCapsBudget() {
        let now = Date.fixedNow.startOfDay.settingTime(hour: 8, minute: 0)
        let duplicateIdentifier = "duplicate-id"

        let plan = NotificationPlanBuilder.merge(
            plans: [
                NotificationSyncPlan(
                    identifiersToRemove: ["b", "a"],
                    requests: [
                        NotificationRequestPayload(
                            identifier: duplicateIdentifier,
                            title: "Later duplicate",
                            body: "",
                            route: "levain://starter/1",
                            fireDate: now.settingTime(hour: 12, minute: 0)
                        ),
                        NotificationRequestPayload(
                            identifier: "late-unique",
                            title: "Late",
                            body: "",
                            route: "levain://starter/2",
                            fireDate: now.settingTime(hour: 18, minute: 0)
                        )
                    ]
                ),
                NotificationSyncPlan(
                    identifiersToRemove: ["a", "c"],
                    requests: [
                        NotificationRequestPayload(
                            identifier: duplicateIdentifier,
                            title: "Earlier duplicate",
                            body: "",
                            route: "levain://starter/3",
                            fireDate: now.settingTime(hour: 9, minute: 0)
                        )
                    ] +
                    (0..<NotificationPlanningDefaults.maxPendingRequests).map { index in
                        NotificationRequestPayload(
                            identifier: "req-\(index)",
                            title: "Req \(index)",
                            body: "",
                            route: "levain://starter/\(index)",
                            fireDate: now.adding(minutes: 60 + index)
                        )
                    }
                )
            ],
            now: now
        )

        XCTAssertEqual(plan.identifiersToRemove, ["a", "b", "c"])
        XCTAssertEqual(plan.requests.count, NotificationPlanningDefaults.maxPendingRequests)
        XCTAssertEqual(plan.requests.first?.identifier, duplicateIdentifier)
        XCTAssertEqual(plan.requests.first?.title, "Earlier duplicate")
        XCTAssertFalse(plan.requests.contains(where: { $0.identifier == "late-unique" }))
        XCTAssertEqual(Set(plan.requests.map(\.identifier)).count, plan.requests.count)
    }
}

import XCTest
@testable import Levain

final class StarterTests: XCTestCase {
    func testDueStateTransitions() {
        let now = Date.fixedNow

        // Less than refresh interval, OK
        let okStarter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: now.adding(minutes: -5 * 24 * 60)
        )
        XCTAssertEqual(okStarter.dueState(now: now), StarterDueState.ok)

        // Exactly at interval, due today
        let dueStarter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: now.adding(minutes: -7 * 24 * 60)
        )
        XCTAssertEqual(dueStarter.dueState(now: now), StarterDueState.dueToday)

        // Past interval, overdue
        let overdueStarter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: now.adding(minutes: -8 * 24 * 60)
        )
        XCTAssertEqual(overdueStarter.dueState(now: now), StarterDueState.overdue)
    }

    func testNextDueDateCalculation() {
        let now = Date.fixedNow

        let starter = DomainFixtures.makeStarter(
            refreshIntervalDays: 7,
            lastRefresh: now
        )

        let nextDue = starter.nextDueDate
        XCTAssertEqual(nextDue, Calendar.current.date(byAdding: .day, value: 7, to: now.startOfDay)!)
    }
}

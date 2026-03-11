import Testing
import Foundation
@testable import Levain

@Suite("Today Agenda Builder")
struct TodayAgendaBuilderTests {

    @Test("Agenda groups one operational item per bake into the correct sections")
    func testAgendaSectionGrouping() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        let runningBake = DomainFixtures.makeBake(name: "Running bake", target: now.addingTimeInterval(3600 * 24))
        let runningStep = BakeStep(
            orderIndex: 0,
            type: .autolysis,
            nameOverride: "Running",
            plannedStart: now.addingTimeInterval(-3600),
            plannedDurationMinutes: 120,
            actualStart: now.addingTimeInterval(-3600),
            bake: runningBake
        )
        runningStep.status = .running
        runningBake.steps = [runningStep]

        let overdueBake = DomainFixtures.makeBake(name: "Overdue bake", target: now.addingTimeInterval(3600 * 24))
        let overdueStep = BakeStep(
            orderIndex: 0,
            type: .mix,
            nameOverride: "Overdue",
            plannedStart: now.addingTimeInterval(-7200),
            plannedDurationMinutes: 60,
            bake: overdueBake
        )
        overdueBake.steps = [overdueStep]

        let upcomingBake = DomainFixtures.makeBake(name: "Upcoming bake", target: now.addingTimeInterval(3600 * 24))
        let upcomingStep = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Upcoming",
            plannedStart: now.addingTimeInterval(3600),
            plannedDurationMinutes: 30,
            bake: upcomingBake
        )
        upcomingBake.steps = [upcomingStep]

        let laterBake = DomainFixtures.makeBake(name: "Later bake", target: now.addingTimeInterval(3600 * 48))
        let laterStep = BakeStep(
            orderIndex: 0,
            type: .shape,
            nameOverride: "Later",
            plannedStart: now.addingTimeInterval(3600 * 25),
            plannedDurationMinutes: 30,
            bake: laterBake
        )
        laterBake.steps = [laterStep]

        let starter = DomainFixtures.makeStarter(
            name: "Starter",
            refreshIntervalDays: 7,
            lastRefresh: now.addingTimeInterval(-3600 * 24 * 7)
        )

        let agenda = TodayAgendaBuilder.build(
            bakes: [runningBake, overdueBake, upcomingBake, laterBake],
            starters: [starter],
            now: now
        )

        #expect(agenda[.now]?.count == 2)
        #expect(agenda[.upcoming]?.count == 1)
        #expect(agenda[.later]?.count == 1)
        #expect(agenda[.starter]?.count == 1)

        let nowSummaries = agenda[.now]?.compactMap(\.bakeSummary) ?? []
        #expect(nowSummaries.contains(where: { $0.stepName == "Running" && $0.timerPhase == .running }))
        #expect(nowSummaries.contains(where: { $0.stepName == "Overdue" && $0.timerPhase == .overdue }))

        let upcomingSummary = agenda[.upcoming]?.first?.bakeSummary
        #expect(upcomingSummary?.stepName == "Upcoming")
        #expect(upcomingSummary?.primaryActionTitle == "Avvia step")

        let laterSummary = agenda[.later]?.first?.bakeSummary
        #expect(laterSummary?.stepName == "Later")
    }

    @Test("Agenda sorts bake items by the active step start date within sections")
    func testAgendaSorting() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        let firstBake = DomainFixtures.makeBake(name: "First bake", target: now.addingTimeInterval(3600 * 24))
        let firstStep = BakeStep(
            orderIndex: 0,
            type: .mix,
            nameOverride: "First",
            plannedStart: now.addingTimeInterval(3600),
            plannedDurationMinutes: 30,
            bake: firstBake
        )
        firstBake.steps = [firstStep]

        let secondBake = DomainFixtures.makeBake(name: "Second bake", target: now.addingTimeInterval(3600 * 24))
        let secondStep = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Second",
            plannedStart: now.addingTimeInterval(1800),
            plannedDurationMinutes: 30,
            bake: secondBake
        )
        secondBake.steps = [secondStep]

        let agenda = TodayAgendaBuilder.build(bakes: [firstBake, secondBake], starters: [], now: now)
        let upcoming = agenda[.upcoming]?.compactMap(\.bakeSummary) ?? []

        #expect(upcoming.count == 2)
        #expect(upcoming[0].stepName == "Second")
        #expect(upcoming[1].stepName == "First")
    }

    @Test("Agenda excludes cancelled and completed bakes")
    func testAgendaExcludesTerminalBakes() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        let completedBake = DomainFixtures.makeBake(name: "Completed", target: now.addingTimeInterval(3600 * 24))
        completedBake.sortedSteps.forEach { $0.complete(at: now) }

        let cancelledBake = DomainFixtures.makeBake(name: "Cancelled", target: now.addingTimeInterval(3600 * 24))
        cancelledBake.isCancelled = true

        let agenda = TodayAgendaBuilder.build(bakes: [completedBake, cancelledBake], starters: [], now: now)

        #expect(agenda.values.allSatisfy { $0.isEmpty })
    }
}

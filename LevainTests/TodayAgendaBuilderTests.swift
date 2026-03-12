import Testing
import Foundation
@testable import Levain

@Suite("Today Agenda Builder")
struct TodayAgendaBuilderTests {
    @Test("Agenda separates urgent work, today's schedule, and tomorrow preview")
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

        let tomorrowBake = DomainFixtures.makeBake(name: "Tomorrow bake", target: now.addingTimeInterval(3600 * 48))
        let tomorrowStep = BakeStep(
            orderIndex: 0,
            type: .shape,
            nameOverride: "Tomorrow",
            plannedStart: now.addingTimeInterval(3600 * 25),
            plannedDurationMinutes: 30,
            bake: tomorrowBake
        )
        tomorrowBake.steps = [tomorrowStep]

        let laterBake = DomainFixtures.makeBake(name: "Later bake", target: now.addingTimeInterval(3600 * 72))
        let laterStep = BakeStep(
            orderIndex: 0,
            type: .proof,
            nameOverride: "Later",
            plannedStart: now.addingTimeInterval(3600 * 50),
            plannedDurationMinutes: 30,
            flexibleWindowStart: now.addingTimeInterval(3600 * 50 + 1800),
            flexibleWindowEnd: now.addingTimeInterval(3600 * 52),
            bake: laterBake
        )
        laterBake.steps = [laterStep]

        let overdueStarter = DomainFixtures.makeStarter(
            name: "Starter overdue",
            refreshIntervalDays: 7,
            lastRefresh: now.addingTimeInterval(-3600 * 24 * 8)
        )

        let dueTodayStarter = DomainFixtures.makeStarter(
            name: "Starter today",
            refreshIntervalDays: 7,
            lastRefresh: now.addingTimeInterval(-3600 * 24 * 7)
        )

        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [runningBake, overdueBake, upcomingBake, tomorrowBake, laterBake],
            starters: [overdueStarter, dueTodayStarter],
            hasPersistedData: true,
            now: now
        )

        #expect(snapshot.emptyState == .actionable)
        #expect(snapshot.sections[.urgent]?.count == 3)
        #expect(snapshot.sections[.scheduled]?.count == 2)
        #expect(snapshot.sections[.tomorrow]?.count == 1)
        #expect(snapshot.futurePreview?.title == "Tomorrow bake")
    }

    @Test("Agenda returns first launch state when there is no persisted data")
    func testFirstLaunchState() {
        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [],
            starters: [],
            hasPersistedData: false,
            now: .fixedNow
        )

        #expect(snapshot.emptyState == .firstLaunch)
        #expect(snapshot.futurePreview == nil)
    }

    @Test("Agenda returns all-clear state when data exists but nothing remains to do or preview")
    func testAllClearState() {
        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [],
            starters: [],
            hasPersistedData: true,
            now: .fixedNow
        )

        #expect(snapshot.emptyState == .allClear)
    }

    @Test("Agenda returns future-only state with the next future preview")
    func testFutureOnlyPreview() {
        let now = Date.fixedNow
        let futureStarter = DomainFixtures.makeStarter(
            name: "Starter futuro",
            refreshIntervalDays: 7,
            lastRefresh: now
        )

        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [],
            starters: [futureStarter],
            hasPersistedData: true,
            now: now
        )

        #expect(snapshot.emptyState == .futureOnly)
        #expect(snapshot.futurePreview?.title == "Starter futuro")
    }

    @Test("Window-based running steps stay scheduled until their window opens")
    func testWindowStepStaysScheduledUntilWindowOpen() {
        let now = Date.fixedNow
        let bake = DomainFixtures.makeBake(name: "Cold retard", target: now.addingTimeInterval(3600 * 24))
        let step = BakeStep(
            orderIndex: 0,
            type: .coldRetard,
            nameOverride: "Appretto frigo",
            plannedStart: now.addingTimeInterval(-3600),
            plannedDurationMinutes: 60,
            flexibleWindowStart: now.addingTimeInterval(3600),
            flexibleWindowEnd: now.addingTimeInterval(7200),
            actualStart: now.addingTimeInterval(-3600),
            bake: bake
        )
        step.status = .running
        bake.steps = [step]

        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [bake],
            starters: [],
            hasPersistedData: true,
            now: now
        )

        let scheduled = snapshot.sections[.scheduled]?.first?.bakeSummary
        #expect(snapshot.sections[.urgent]?.isEmpty ?? true)
        #expect(scheduled?.presentationStyle == .compactWindow)
    }

    @Test("Tomorrow preview is limited to two items")
    func testTomorrowPreviewLimit() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        let firstBake = DomainFixtures.makeBake(name: "Tomorrow one", target: now.addingTimeInterval(3600 * 48))
        firstBake.steps = [
            BakeStep(
                orderIndex: 0,
                type: .mix,
                nameOverride: "First tomorrow",
                plannedStart: now.addingTimeInterval(3600 * 24 + 600),
                plannedDurationMinutes: 30,
                bake: firstBake
            )
        ]

        let secondBake = DomainFixtures.makeBake(name: "Tomorrow two", target: now.addingTimeInterval(3600 * 48))
        secondBake.steps = [
            BakeStep(
                orderIndex: 0,
                type: .bulk,
                nameOverride: "Second tomorrow",
                plannedStart: now.addingTimeInterval(3600 * 24 + 1200),
                plannedDurationMinutes: 30,
                bake: secondBake
            )
        ]

        let thirdBake = DomainFixtures.makeBake(name: "Tomorrow three", target: now.addingTimeInterval(3600 * 48))
        thirdBake.steps = [
            BakeStep(
                orderIndex: 0,
                type: .shape,
                nameOverride: "Third tomorrow",
                plannedStart: now.addingTimeInterval(3600 * 24 + 1800),
                plannedDurationMinutes: 30,
                bake: thirdBake
            )
        ]

        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [thirdBake, secondBake, firstBake],
            starters: [],
            hasPersistedData: true,
            now: now
        )

        let tomorrow = snapshot.sections[.tomorrow]?.compactMap(\.bakeSummary) ?? []
        #expect(tomorrow.count == 2)
        #expect(tomorrow[0].stepName == "First tomorrow")
        #expect(tomorrow[1].stepName == "Second tomorrow")
    }

    @Test("Agenda excludes cancelled and completed bakes")
    func testAgendaExcludesTerminalBakes() {
        let now = Date(timeIntervalSince1970: 1_000_000)

        let completedBake = DomainFixtures.makeBake(name: "Completed", target: now.addingTimeInterval(3600 * 24))
        completedBake.sortedSteps.forEach { $0.complete(at: now) }

        let cancelledBake = DomainFixtures.makeBake(name: "Cancelled", target: now.addingTimeInterval(3600 * 24))
        cancelledBake.isCancelled = true

        let snapshot = TodayAgendaBuilder.buildSnapshot(
            bakes: [completedBake, cancelledBake],
            starters: [],
            hasPersistedData: true,
            now: now
        )

        #expect(snapshot.sections.values.allSatisfy { $0.isEmpty })
        #expect(snapshot.emptyState == .allClear)
    }
}

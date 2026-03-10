import XCTest
@testable import Levain

final class BakeSchedulerTests: XCTestCase {
    func testScheduleGenerationWorksBackwardFromTargetTime() {
        let formula = RecipeFormula(
            name: "Formula test",
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 700,
            saltWeight: 20,
            inoculationPercent: 20,
            defaultSteps: [
                FormulaStepTemplate(type: .mix, name: "Impasto", durationMinutes: 30),
                FormulaStepTemplate(type: .bulk, name: "Bulk", durationMinutes: 180),
                FormulaStepTemplate(type: .bake, name: "Cottura", durationMinutes: 45)
            ]
        )

        let target = Date(timeIntervalSince1970: 10_000)
        let bake = BakeScheduler.generateBake(
            name: "Test bake",
            targetBakeDateTime: target,
            formula: formula
        )

        XCTAssertEqual(bake.sortedSteps.count, 3)
        XCTAssertEqual(bake.sortedSteps[2].plannedEnd, target)
        XCTAssertEqual(bake.sortedSteps[1].plannedEnd, bake.sortedSteps[2].plannedStart)
        XCTAssertEqual(bake.sortedSteps[0].plannedEnd, bake.sortedSteps[1].plannedStart)
    }

    func testShiftTimelineAffectsOnlyFutureIncompleteSteps() {
        let formula = RecipeFormula(
            name: "Shift",
            type: .countryLoaf,
            totalFlourWeight: 800,
            totalWaterWeight: 560,
            saltWeight: 18,
            inoculationPercent: 18
        )
        let bake = BakeScheduler.generateBake(
            name: "Shift bake",
            targetBakeDateTime: Date(timeIntervalSince1970: 20_000),
            formula: formula
        )
        let first = bake.sortedSteps[0]
        let second = bake.sortedSteps[1]
        let third = bake.sortedSteps[2]
        second.complete(at: second.plannedEnd)

        let originalFirst = first.plannedStart
        let originalSecond = second.plannedStart
        let originalThird = third.plannedStart

        BakeScheduler.shiftFutureSteps(in: bake, after: first, by: 30)

        XCTAssertEqual(first.plannedStart, originalFirst)
        XCTAssertEqual(second.plannedStart, originalSecond)
        XCTAssertEqual(third.plannedStart, originalThird.adding(minutes: 30))
    }

    func testDerivedStatuses() {
        let formula = RecipeFormula(
            name: "Status",
            type: .countryLoaf,
            totalFlourWeight: 500,
            totalWaterWeight: 350,
            saltWeight: 10,
            inoculationPercent: 15
        )
        let bake = BakeScheduler.generateBake(
            name: "Status bake",
            targetBakeDateTime: .now,
            formula: formula
        )
        XCTAssertEqual(bake.derivedStatus, .planned)

        bake.sortedSteps.first?.start()
        XCTAssertEqual(bake.derivedStatus, .inProgress)

        bake.sortedSteps.forEach { $0.complete() }
        XCTAssertEqual(bake.derivedStatus, .completed)
    }

    func testStarterDueState() {
        let starter = Starter(
            name: "Starter",
            type: .wheat,
            refreshIntervalDays: 5,
            lastRefresh: Date(timeIntervalSince1970: 0)
        )
        let now = Date(timeIntervalSince1970: 6 * 24 * 60 * 60)
        XCTAssertEqual(starter.dueState(now: now), .overdue)
    }
}

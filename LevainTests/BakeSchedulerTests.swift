import XCTest
@testable import Levain

final class BakeSchedulerTests: XCTestCase {
    
    // MARK: - Schedule Generation
    
    func testScheduleGenerationWorksBackwardFromTargetTime() {
        let formula = DomainFixtures.makeFormula(steps: [
            FormulaStepTemplate(type: .mix, name: "S1", durationMinutes: 60),
            FormulaStepTemplate(type: .bulk, name: "S2", durationMinutes: 120),
            FormulaStepTemplate(type: .bake, name: "S3", durationMinutes: 30)
        ])
        
        let target = Date(timeIntervalSince1970: 100_000)
        let bake = BakeScheduler.generateBake(name: "Test", targetBakeDateTime: target, formula: formula)
        
        let steps = bake.sortedSteps
        XCTAssertEqual(steps.count, 3)
        
        // S3: 100k - 30m to 100k
        XCTAssertEqual(steps[2].plannedEnd, target)
        XCTAssertEqual(steps[2].plannedStart, target.adding(minutes: -30))
        
        // S2: End at S3.Start, duration 120
        XCTAssertEqual(steps[1].plannedEnd, steps[2].plannedStart)
        XCTAssertEqual(steps[1].plannedStart, steps[2].plannedStart.adding(minutes: -120))
        
        // S1: End at S2.Start, duration 60
        XCTAssertEqual(steps[0].plannedEnd, steps[1].plannedStart)
        XCTAssertEqual(steps[0].plannedStart, steps[1].plannedStart.adding(minutes: -60))
    }

    func testEmptyBakeNameFallsBackToFormulaName() {
        let formula = DomainFixtures.makeFormula(name: "Pane Base")

        let bake = BakeScheduler.generateBake(
            name: "",
            targetBakeDateTime: .fixedNow.adding(minutes: 60),
            formula: formula
        )

        XCTAssertEqual(bake.name, "Pane Base")
    }

    func testWindowBasedStepUsesOpeningAndClosingWindow() {
        let formula = DomainFixtures.makeFormula(steps: [
            FormulaStepTemplate(type: .mix, name: "Impasto", durationMinutes: 30),
            FormulaStepTemplate(type: .proof, name: "Appretto", durationMinutes: 120, reminderOffsetMinutes: 20)
        ])

        let bake = BakeScheduler.generateBake(
            name: "Window bake",
            targetBakeDateTime: .fixedNow.adding(minutes: 240),
            formula: formula
        )

        guard let proof = bake.sortedSteps.last else {
            return XCTFail("Expected proof step")
        }

        XCTAssertTrue(proof.isWindowBased)
        XCTAssertEqual(proof.windowStart, proof.plannedEnd)
        XCTAssertEqual(proof.windowEnd, proof.plannedEnd.adding(minutes: 60))
    }
    
    // MARK: - Timeline Shifting
    
    func testShiftTimelineAffectsOnlyFutureIncompleteSteps() {
        let bake = DomainFixtures.makeBake()
        XCTAssertGreaterThan(bake.sortedSteps.count, 3)
        
        let steps = bake.sortedSteps
        let first = steps[0]
        let second = steps[1]

        // Prima del shift, completiamo il SECONDO step (che è dopo l'ancora "first")
        second.complete(at: second.plannedEnd)
        
        let originalStarts = steps.map { $0.plannedStart }
        let originalTarget = bake.targetBakeDateTime
        
        // Shiftiamo DOPO il primo step (quindi dal secondo in poi)
        // Regola: solo step INCOMPLETE dopo l'ancora vengono spostati.
        // Il secondo è nell'indice dopo il primo, ma è GIÀ completato, quindi NON deve spostarsi.
        // Il terzo e successivi sono incompleti, quindi DEVONO spostarsi.
        BakeScheduler.shiftFutureSteps(in: bake, after: first, by: 60)
        
        XCTAssertEqual(steps[0].plannedStart, originalStarts[0], "L'ancora non deve spostarsi")
        XCTAssertEqual(steps[1].plannedStart, originalStarts[1], "Lo step già completato non deve spostarsi")
        XCTAssertEqual(steps[2].plannedStart, originalStarts[2].adding(minutes: 60), "Lo step incompleto futuro deve spostarsi")
        
        XCTAssertEqual(bake.targetBakeDateTime, originalTarget.adding(minutes: 60), "Il tempo target del bake deve aggiornarsi")
    }

    /// Fasi non a finestra in corso: lo shift deve allungare/accorciare `plannedDurationMinutes` così timer e "Fine" si aggiornano.
    func testShiftExtendsRunningNonWindowStepDuration() {
        let formula = DomainFixtures.makeFormula(steps: [
            FormulaStepTemplate(type: .bulk, name: "Bulk", durationMinutes: 120),
            FormulaStepTemplate(type: .bake, name: "Bake", durationMinutes: 30)
        ])
        let target = Date.fixedNow.adding(minutes: 400)
        let bake = BakeScheduler.generateBake(name: "T", targetBakeDateTime: target, formula: formula)
        let bulk = bake.sortedSteps[0]
        bulk.start(at: Date.fixedNow)

        let originalEnd = bulk.plannedEnd
        let originalDuration = bulk.plannedDurationMinutes

        BakeScheduler.shiftFutureSteps(in: bake, after: bulk, by: 15, now: .fixedNow)

        XCTAssertEqual(bulk.plannedDurationMinutes, originalDuration + 15)
        XCTAssertEqual(bulk.plannedEnd, originalEnd.adding(minutes: 15))
    }

    func testShiftCannotReduceRunningStepBelowElapsedTime() {
        let formula = DomainFixtures.makeFormula(steps: [
            FormulaStepTemplate(type: .bulk, name: "Bulk", durationMinutes: 60),
            FormulaStepTemplate(type: .bake, name: "Bake", durationMinutes: 30)
        ])
        let bake = BakeScheduler.generateBake(
            name: "T",
            targetBakeDateTime: Date.fixedNow.adding(minutes: 400),
            formula: formula
        )
        let bulk = bake.sortedSteps[0]
        bulk.start(at: Date.fixedNow.adding(minutes: -40))

        BakeScheduler.shiftFutureSteps(in: bake, after: bulk, by: -30, now: .fixedNow)

        XCTAssertEqual(bulk.plannedDurationMinutes, 40, "La durata non scende sotto il tempo già trascorso")
    }
    
    // MARK: - Derived Progression Helpers
    
    func testBakeProgressAndStepCounts() {
        let bake = DomainFixtures.makeBake()
        XCTAssertEqual(bake.totalStepCount, bake.sortedSteps.count)
        XCTAssertEqual(bake.completedStepCount, 0)
        XCTAssertEqual(bake.progress, 0.0)
        
        bake.sortedSteps[0].complete()
        XCTAssertEqual(bake.completedStepCount, 1)
        XCTAssertEqual(bake.progress, 1.0 / Double(bake.totalStepCount), accuracy: 0.01)
        
        bake.sortedSteps.forEach { $0.complete() }
        XCTAssertEqual(bake.progress, 1.0)
    }
    
    func testBakeStepRunningProgress() {
        let now = Date.fixedNow
        let step = BakeStep(orderIndex: 0, type: .bulk, nameOverride: "Bulk", plannedStart: now, plannedDurationMinutes: 60)
        
        // Non avviato
        XCTAssertEqual(step.currentProgress(now: now), 0.0)
        
        // Avviato ora
        step.start(at: now)
        XCTAssertEqual(step.currentProgress(now: now), 0.0)
        
        // Passati 30 minuti
        let halfWay = now.adding(minutes: 30)
        XCTAssertEqual(step.currentProgress(now: halfWay), 0.5, accuracy: 0.01)
        
        // Passati 60 minuti
        let finishedTime = now.adding(minutes: 60)
        XCTAssertEqual(step.currentProgress(now: finishedTime), 1.0, accuracy: 0.01)
        
        // Passati 90 minuti (cap al 100%)
        let overdueTime = now.adding(minutes: 90)
        XCTAssertEqual(step.currentProgress(now: overdueTime), 1.0, accuracy: 0.01)
    }

    func testTimerHelpersForRunningStepBeforeEnd() {
        let now = Date.fixedNow
        let start = now.adding(minutes: -25)
        let step = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Bulk",
            plannedStart: start,
            plannedDurationMinutes: 60,
            actualStart: start
        )
        step.status = .running

        XCTAssertEqual(step.elapsedMinutes(now: now), 25)
        XCTAssertEqual(step.remainingMinutes(now: now), 35)
        XCTAssertEqual(step.overrunMinutes(now: now), 0)
        XCTAssertEqual(step.timerPhase(now: now), .running)
        XCTAssertEqual(step.progressValue(now: now), 25.0 / 60.0, accuracy: 0.01)
    }

    func testTimerHelpersAtExactPlannedEnd() {
        let start = Date.fixedNow.adding(minutes: -60)
        let now = Date.fixedNow
        let step = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Bulk",
            plannedStart: start,
            plannedDurationMinutes: 60,
            actualStart: start
        )
        step.status = .running

        XCTAssertEqual(step.elapsedMinutes(now: now), 60)
        XCTAssertEqual(step.remainingMinutes(now: now), 0)
        XCTAssertEqual(step.overrunMinutes(now: now), 0)
        XCTAssertEqual(step.progressValue(now: now), 1.0, accuracy: 0.01)
    }

    func testTimerHelpersForOverdueRunningStep() {
        let start = Date.fixedNow.adding(minutes: -90)
        let now = Date.fixedNow
        let step = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Bulk",
            plannedStart: start,
            plannedDurationMinutes: 60,
            actualStart: start
        )
        step.status = .running

        XCTAssertEqual(step.remainingMinutes(now: now), 0)
        XCTAssertEqual(step.overrunMinutes(now: now), 30)
        XCTAssertEqual(step.timerPhase(now: now), .overdue)
        XCTAssertEqual(step.progressValue(now: now), 1.0, accuracy: 0.01)
    }

    func testProgressValueRemainsClampedWhenElapsedExceedsDuration() {
        let start = Date.fixedNow.adding(minutes: -180)
        let now = Date.fixedNow
        let step = BakeStep(
            orderIndex: 0,
            type: .bulk,
            nameOverride: "Bulk",
            plannedStart: start,
            plannedDurationMinutes: 45,
            actualStart: start
        )
        step.status = .running

        XCTAssertEqual(step.progressValue(now: now), 1.0, accuracy: 0.01)
    }

    func testWindowBasedOverdueUsesWindowEnd() {
        let now = Date.fixedNow
        let step = BakeStep(
            orderIndex: 0,
            type: .coldRetard,
            nameOverride: "Cold retard",
            plannedStart: now.adding(minutes: -180),
            plannedDurationMinutes: 60,
            flexibleWindowStart: now.adding(minutes: -30),
            flexibleWindowEnd: now.adding(minutes: 30),
            actualStart: now.adding(minutes: -180)
        )
        step.status = .running

        XCTAssertFalse(step.isOverdue(now: now))
        XCTAssertTrue(step.isOperationallyUrgent(now: now))
    }

    func testStepStartedOutOfOrderIsDetectedAfterExplicitOverride() {
        let bake = DomainFixtures.makeBake()
        let second = bake.sortedSteps[1]

        XCTAssertTrue(second.requiresSequenceOverrideBeforeStart)
        second.start(at: .fixedNow)

        XCTAssertTrue(second.startedOutOfOrder)
    }
    
    // MARK: - Bake Status Derivation
    
    func testDerivedBakeStatusFlow() {
        let bake = DomainFixtures.makeBake()
        XCTAssertEqual(bake.derivedStatus, .planned)
        
        bake.sortedSteps[0].start()
        XCTAssertEqual(bake.derivedStatus, .inProgress)
        
        bake.sortedSteps[0].complete()
        XCTAssertEqual(bake.derivedStatus, .inProgress, "Deve essere in progress se ci sono altri step da fare")
        
        bake.sortedSteps.forEach { $0.complete() }
        XCTAssertEqual(bake.derivedStatus, .completed)
        
        bake.isCancelled = true
        XCTAssertEqual(bake.derivedStatus, .cancelled)
    }
    
    // MARK: - Overdue Derivation
    
    func testStepOverdueLogic() {
        let now = Date.fixedNow
        let start = now.adding(minutes: -120)
        let duration = 60
        // Planned end: now - 60 (quindi nel passato)
        
        let step = BakeStep(orderIndex: 0, type: .bulk, nameOverride: "LATE", plannedStart: start, plannedDurationMinutes: duration)
        
        XCTAssertTrue(step.isOverdue(now: now))
        
        step.complete(at: now)
        XCTAssertFalse(step.isOverdue(now: now), "Uno step completato non è mai overdue")
    }
    
    // MARK: - Starter Due State
    
    func testStarterDueStateDerivation() {
        let now = Date.fixedNow // 1_000_000
        
        // 1. OK: rinfrescato da poco
        let starterOk = DomainFixtures.makeStarter(refreshIntervalDays: 7, lastRefresh: now.adding(minutes: -24 * 60))
        XCTAssertEqual(starterOk.dueState(now: now), .ok)
        
        // 2. DUE TODAY
        let starterDue = DomainFixtures.makeStarter(refreshIntervalDays: 1, lastRefresh: now.adding(minutes: -24 * 60))
        XCTAssertEqual(starterDue.dueState(now: now), .dueToday)
        
        // 3. OVERDUE
        let starterOverdue = DomainFixtures.makeStarter(refreshIntervalDays: 1, lastRefresh: now.adding(minutes: -48 * 60))
        XCTAssertEqual(starterOverdue.dueState(now: now), .overdue)
    }
}

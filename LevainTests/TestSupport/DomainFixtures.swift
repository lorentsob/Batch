import Foundation
@testable import Levain

enum DomainFixtures {
    static func makeFormula(
        name: String = "Test Formula",
        steps: [FormulaStepTemplate] = FormulaStepTemplate.defaultBreadSteps
    ) -> RecipeFormula {
        RecipeFormula(
            name: name,
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20,
            defaultSteps: steps
        )
    }

    static func makeStarter(
        name: String = "Test Starter",
        refreshIntervalDays: Int = 7,
        lastRefresh: Date = .now
    ) -> Starter {
        Starter(
            name: name,
            type: .wheat,
            refreshIntervalDays: refreshIntervalDays,
            lastRefresh: lastRefresh
        )
    }

    static func makeBake(
        name: String = "Test Bake",
        target: Date = Date(timeIntervalSince1970: 100_000),
        formula: RecipeFormula? = nil
    ) -> Bake {
        let actualFormula = formula ?? makeFormula()
        return BakeScheduler.generateBake(
            name: name,
            targetBakeDateTime: target,
            formula: actualFormula
        )
    }

    static func makeKefirBatch(
        name: String = "Batch kefir principale",
        storageMode: KefirStorageMode = .roomTemperature,
        lastManagedAt: Date = .now,
        expectedRoutineHours: Int? = nil,
        sourceBatchId: UUID? = nil,
        useLabel: String = "",
        notes: String = "",
        differentiationNote: String = "",
        plannedReactivationAt: Date? = nil,
        archivedAt: Date? = nil,
        alertsEnabled: Bool = true
    ) -> KefirBatch {
        KefirBatch(
            name: name,
            createdAt: lastManagedAt,
            lastManagedAt: lastManagedAt,
            expectedRoutineHours: expectedRoutineHours,
            storageMode: storageMode,
            alertsEnabled: alertsEnabled,
            sourceBatchId: sourceBatchId,
            useLabel: useLabel,
            notes: notes,
            differentiationNote: differentiationNote,
            plannedReactivationAt: plannedReactivationAt,
            archivedAt: archivedAt
        )
    }

    static func makeKefirEvent(
        batchID: UUID = UUID(),
        createdAt: Date = .now,
        kind: KefirEventKind = .created,
        relatedBatchID: UUID? = nil,
        relatedBatchName: String? = nil,
        note: String = "",
        previousStorageMode: KefirStorageMode? = nil,
        storageMode: KefirStorageMode? = nil,
        expectedRoutineHours: Int? = nil,
        plannedReactivationAt: Date? = nil
    ) -> KefirEvent {
        KefirEvent(
            batchID: batchID,
            createdAt: createdAt,
            kind: kind,
            relatedBatchID: relatedBatchID,
            relatedBatchName: relatedBatchName,
            note: note,
            previousStorageMode: previousStorageMode,
            storageMode: storageMode,
            expectedRoutineHours: expectedRoutineHours,
            plannedReactivationAt: plannedReactivationAt
        )
    }
}

extension Date {
    static var fixedNow: Date {
        Date(timeIntervalSince1970: 1_000_000)
    }
}

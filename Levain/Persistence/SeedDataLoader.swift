import Foundation
import SwiftData

/// Manages the insertion of representative sample content used for internal
/// testing and demos.
enum SeedDataLoader {
    private enum SeededKefirIDs {
        static let mainBatch = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        static let breakfastBatch = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        static let fridgeBatch = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        static let freezerBatch = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
        static let archivedDerivedBatch = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
    }

    enum Scenario: String {
        case operational
        case futureOnly
        case allClear

        static func current() -> Scenario {
            Scenario(rawValue: AppLaunchOptions.seedScenario) ?? .operational
        }
    }

    static func ensureSeedData(in context: ModelContext, scenario: Scenario = .operational) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        guard settings.didSeedSampleData == false else { return }
        try insertSampleContent(in: context, settings: settings, scenario: scenario)
    }

    // MARK: - System formulas

    /// Loads system_formulas.json and persists each formula as a `RecipeFormula` with
    /// `isSystemFormula = true`. Idempotent: skipped if the flag is already set.
    static func ensureSystemFormulas(in context: ModelContext) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        guard settings.didSeedSystemFormulas == false else { return }

        let systemFormulas = SystemFormulaLoader.loadSystemFormulas()
        let existingIDs: Set<UUID> = try {
            let descriptor = FetchDescriptor<RecipeFormula>()
            return Set(try context.fetch(descriptor).map(\.id))
        }()

        for sf in systemFormulas where !existingIDs.contains(sf.id) {
            let formula = RecipeFormula(
                id: sf.id,
                name: sf.name,
                type: sf.type,
                totalFlourWeight: sf.totalFlourWeight,
                totalWaterWeight: sf.totalWaterWeight,
                saltWeight: sf.saltWeight,
                inoculationPercent: sf.inoculationPercent,
                servings: sf.servings,
                notes: sf.notes,
                flourMix: sf.flourMix,
                yeastType: sf.yeastType,
                flours: sf.flours,
                defaultSteps: sf.defaultSteps,
                ingredients: sf.ingredients,
                procedure: sf.procedure,
                bakingInstructions: sf.bakingInstructions,
                isSystemFormula: true,
                isModifiedFromDefault: false
            )
            context.insert(formula)
        }

        settings.didSeedSystemFormulas = true
        try context.save()
    }

    static func resetAndSeed(in context: ModelContext, scenario: Scenario = .operational) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        settings.didSeedSampleData = false
        try insertSampleContent(in: context, settings: settings, scenario: scenario)
    }

    private static func insertSampleContent(in context: ModelContext, settings: AppSettings, scenario: Scenario) throws {
        switch scenario {
        case .operational:
            try insertOperationalScenario(in: context)
        case .futureOnly:
            try insertFutureOnlyScenario(in: context)
        case .allClear:
            try insertAllClearScenario(in: context)
        }

        settings.didSeedSampleData = true
        try context.save()
    }

    private static func insertOperationalScenario(in context: ModelContext) throws {
        let starter = Starter(
            name: "Lievito Madre (Semola)",
            type: .semolina,
            hydration: 100,
            flourMix: "100% semola rimacinata",
            containerWeight: 280,
            storageMode: .fridge,
            refreshIntervalDays: 5,
            lastRefresh: .now.adding(minutes: -5 * 24 * 60),
            notes: "Vigoroso, ottimo per pane e focacce."
        )
        context.insert(starter)

        let refresh1 = StarterRefresh(
            dateTime: .now.adding(minutes: -7 * 24 * 60),
            flourWeight: 100,
            waterWeight: 100,
            starterWeightUsed: 50,
            ratioText: "1:2:2",
            notes: "Rinfresco di mantenimento.",
            starter: starter
        )
        let refresh2 = StarterRefresh(
            dateTime: .now.adding(minutes: -5 * 24 * 60),
            flourWeight: 80,
            waterWeight: 80,
            starterWeightUsed: 20,
            ratioText: "1:4:4",
            notes: "Rinfresco pre-bake.",
            starter: starter
        )
        context.insert(refresh1)
        context.insert(refresh2)

        let formulaPane = RecipeFormula(
            name: "Pane di Campagna",
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20,
            servings: 2,
            notes: "La formula classica per ogni giorno.",
            flourMix: "70% Tipo 1, 30% Integrale"
        )

        let formulaFocaccia = RecipeFormula(
            name: "Focaccia Idratata",
            type: .focaccia,
            totalFlourWeight: 500,
            totalWaterWeight: 400,
            saltWeight: 12,
            inoculationPercent: 15,
            servings: 1,
            notes: "Molto soffice, richiede teglia ben oliata.",
            flourMix: "100% Farina 0"
        )
        context.insert(formulaPane)
        context.insert(formulaFocaccia)

        let bake = BakeScheduler.generateBake(
            name: "Infornata del weekend",
            targetBakeDateTime: .now.adding(minutes: 120),
            formula: formulaPane,
            starter: starter,
            notes: "Provare pieghe più delicate."
        )
        context.insert(bake)

        if let first = bake.sortedSteps.first {
            first.complete(at: .now.adding(minutes: -360))
        }
        if bake.sortedSteps.count > 1 {
            bake.sortedSteps[1].complete(at: .now.adding(minutes: -300))
        }

        bake.steps.forEach { context.insert($0) }

        let mainBatch = KefirBatch(
            id: SeededKefirIDs.mainBatch,
            name: "Batch kefir cucina",
            createdAt: .now.adding(minutes: -18 * 24 * 60),
            lastManagedAt: .now.adding(minutes: -22 * 60),
            expectedRoutineHours: 24,
            storageMode: .roomTemperature,
            useLabel: "Routine quotidiana",
            notes: "Lotto principale sul piano cucina.",
            differentiationNote: "Più acido del solito"
        )

        let breakfastBatch = KefirBatch(
            id: SeededKefirIDs.breakfastBatch,
            name: "Batch kefir colazione",
            createdAt: .now.adding(minutes: -8 * 60),
            lastManagedAt: .now.adding(minutes: -8 * 60),
            expectedRoutineHours: 24,
            storageMode: .roomTemperature,
            sourceBatchId: mainBatch.id,
            useLabel: "Per la colazione",
            notes: "Più delicato, pronto per smoothie.",
            differentiationNote: "Latte intero e fermentazione più corta"
        )

        let fridgeBatch = KefirBatch(
            id: SeededKefirIDs.fridgeBatch,
            name: "Backup frigo",
            createdAt: .now.adding(minutes: -3 * 24 * 60),
            lastManagedAt: .now.adding(minutes: -3 * 24 * 60),
            expectedRoutineHours: 7 * 24,
            storageMode: .fridge,
            useLabel: "Scorta lenta",
            notes: "Serve come batch di sicurezza."
        )

        let freezerBatch = KefirBatch(
            id: SeededKefirIDs.freezerBatch,
            name: "Scorta freezer",
            createdAt: .now.adding(minutes: -14 * 24 * 60),
            lastManagedAt: .now.adding(minutes: -14 * 24 * 60),
            expectedRoutineHours: 7 * 24,
            storageMode: .freezer,
            alertsEnabled: false,
            useLabel: "Pausa lunga",
            notes: "Da riattivare prima del prossimo cambio di routine.",
            plannedReactivationAt: .now.adding(minutes: 5 * 24 * 60)
        )

        let archivedDerivedBatch = KefirBatch(
            id: SeededKefirIDs.archivedDerivedBatch,
            name: "Batch test derivato",
            createdAt: .now.adding(minutes: -9 * 24 * 60),
            lastManagedAt: .now.adding(minutes: -9 * 24 * 60),
            expectedRoutineHours: 24,
            storageMode: .roomTemperature,
            sourceBatchId: mainBatch.id,
            useLabel: "Test differenza latte",
            notes: "Esperimento chiuso dopo due cicli.",
            differentiationNote: "Più cremoso, meno frizzante",
            archivedAt: .now.adding(minutes: -2 * 24 * 60)
        )

        [mainBatch, breakfastBatch, fridgeBatch, freezerBatch, archivedDerivedBatch]
            .forEach(context.insert)

        insertOperationalKefirHistory(
            in: context,
            mainBatch: mainBatch,
            breakfastBatch: breakfastBatch,
            fridgeBatch: fridgeBatch,
            freezerBatch: freezerBatch,
            archivedDerivedBatch: archivedDerivedBatch
        )
    }

    private static func insertFutureOnlyScenario(in context: ModelContext) throws {
        let starter = Starter(
            name: "Starter programma weekend",
            type: .wheat,
            hydration: 100,
            refreshIntervalDays: 7,
            lastRefresh: .now,
            notes: "Da rinfrescare più avanti."
        )
        let formula = RecipeFormula(
            name: "Pane weekend",
            type: .pane,
            totalFlourWeight: 900,
            totalWaterWeight: 680,
            saltWeight: 18,
            inoculationPercent: 18,
            servings: 2
        )
        context.insert(starter)
        context.insert(formula)
    }

    private static func insertAllClearScenario(in context: ModelContext) throws {
        let formula = RecipeFormula(
            name: "Base neutra",
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 720,
            saltWeight: 20,
            inoculationPercent: 20,
            servings: 2,
            notes: "Solo ricetta salvata, nessun lavoro in agenda."
        )
        context.insert(formula)
    }

    private static func insertOperationalKefirHistory(
        in context: ModelContext,
        mainBatch: KefirBatch,
        breakfastBatch: KefirBatch,
        fridgeBatch: KefirBatch,
        freezerBatch: KefirBatch,
        archivedDerivedBatch: KefirBatch
    ) {
        let mainSpawnBreakfastNote = breakfastBatch.differentiationNote
        let mainSpawnArchiveNote = archivedDerivedBatch.differentiationNote

        let events = [
            KefirEvent(
                batchID: mainBatch.id,
                createdAt: mainBatch.createdAt,
                kind: .created,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: mainBatch.id,
                createdAt: mainBatch.createdAt.addingTimeInterval(30 * 60),
                kind: .noteAdded,
                note: mainBatch.notes,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: mainBatch.id,
                createdAt: archivedDerivedBatch.createdAt,
                kind: .spawnedDerivedBatch,
                relatedBatchID: archivedDerivedBatch.id,
                relatedBatchName: archivedDerivedBatch.name,
                note: mainSpawnArchiveNote,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: mainBatch.id,
                createdAt: breakfastBatch.createdAt,
                kind: .spawnedDerivedBatch,
                relatedBatchID: breakfastBatch.id,
                relatedBatchName: breakfastBatch.name,
                note: mainSpawnBreakfastNote,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: mainBatch.id,
                createdAt: mainBatch.lastManagedAt,
                kind: .renewed,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),

            KefirEvent(
                batchID: breakfastBatch.id,
                createdAt: breakfastBatch.createdAt,
                kind: .created,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: breakfastBatch.id,
                createdAt: breakfastBatch.createdAt,
                kind: .derivedFromBatch,
                relatedBatchID: mainBatch.id,
                relatedBatchName: mainBatch.name,
                note: mainSpawnBreakfastNote,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: breakfastBatch.id,
                createdAt: breakfastBatch.createdAt.addingTimeInterval(15 * 60),
                kind: .noteAdded,
                note: breakfastBatch.notes,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),

            KefirEvent(
                batchID: fridgeBatch.id,
                createdAt: fridgeBatch.createdAt,
                kind: .created,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: fridgeBatch.id,
                createdAt: fridgeBatch.createdAt.addingTimeInterval(24 * 60 * 60),
                kind: .renewed,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: fridgeBatch.id,
                createdAt: fridgeBatch.lastManagedAt,
                kind: .storageChanged,
                note: "Da Temperatura ambiente a Frigo",
                previousStorageMode: .roomTemperature,
                storageMode: .fridge,
                expectedRoutineHours: fridgeBatch.expectedRoutineHours
            ),
            KefirEvent(
                batchID: fridgeBatch.id,
                createdAt: fridgeBatch.lastManagedAt.addingTimeInterval(10 * 60),
                kind: .noteAdded,
                note: fridgeBatch.notes,
                storageMode: .fridge,
                expectedRoutineHours: fridgeBatch.expectedRoutineHours
            ),

            KefirEvent(
                batchID: freezerBatch.id,
                createdAt: freezerBatch.createdAt,
                kind: .created,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: freezerBatch.id,
                createdAt: freezerBatch.createdAt.addingTimeInterval(48 * 60 * 60),
                kind: .renewed,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: freezerBatch.id,
                createdAt: freezerBatch.lastManagedAt,
                kind: .storageChanged,
                note: "Riattivazione pianificata",
                previousStorageMode: .roomTemperature,
                storageMode: .freezer,
                expectedRoutineHours: freezerBatch.expectedRoutineHours,
                plannedReactivationAt: freezerBatch.plannedReactivationAt
            ),
            KefirEvent(
                batchID: freezerBatch.id,
                createdAt: freezerBatch.lastManagedAt.addingTimeInterval(10 * 60),
                kind: .noteAdded,
                note: freezerBatch.notes,
                storageMode: .freezer,
                expectedRoutineHours: freezerBatch.expectedRoutineHours,
                plannedReactivationAt: freezerBatch.plannedReactivationAt
            ),

            KefirEvent(
                batchID: archivedDerivedBatch.id,
                createdAt: archivedDerivedBatch.createdAt,
                kind: .created,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: archivedDerivedBatch.id,
                createdAt: archivedDerivedBatch.createdAt,
                kind: .derivedFromBatch,
                relatedBatchID: mainBatch.id,
                relatedBatchName: mainBatch.name,
                note: mainSpawnArchiveNote,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: archivedDerivedBatch.id,
                createdAt: archivedDerivedBatch.createdAt.addingTimeInterval(15 * 60),
                kind: .noteAdded,
                note: archivedDerivedBatch.notes,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: archivedDerivedBatch.id,
                createdAt: archivedDerivedBatch.createdAt.addingTimeInterval(24 * 60 * 60),
                kind: .renewed,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            ),
            KefirEvent(
                batchID: archivedDerivedBatch.id,
                createdAt: archivedDerivedBatch.archivedAt ?? archivedDerivedBatch.lastManagedAt,
                kind: .archived,
                storageMode: .roomTemperature,
                expectedRoutineHours: 24
            )
        ]

        events.forEach(context.insert)
    }
}

import Foundation
import SwiftData

struct BackupPayloadV1: Codable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var exportedAt: Date
    var starters: [StarterRecord]
    var starterRefreshes: [StarterRefreshRecord]
    var recipeFormulas: [RecipeFormulaRecord]
    var bakes: [BakeRecord]
    var bakeSteps: [BakeStepRecord]

    struct StarterRecord: Codable {
        var id: UUID
        var name: String
        var typeRaw: String
        var hydration: Double
        var flourMix: String
        var flours: [FlourSelection]
        var containerWeight: Double
        var storageModeRaw: String
        var refreshIntervalDays: Int
        var remindersEnabled: Bool
        var lastRefresh: Date
        var notes: String
    }

    struct StarterRefreshRecord: Codable {
        var id: UUID
        var dateTime: Date
        var flourWeight: Double
        var waterWeight: Double
        var starterWeightUsed: Double
        var ratioText: String
        var putInFridgeAt: Date?
        var notes: String
        var ambientTemp: Double
        var photoURI: String
        var starterID: UUID?
    }

    struct RecipeFormulaRecord: Codable {
        var id: UUID
        var name: String
        var typeRaw: String
        var totalFlourWeight: Double
        var totalWaterWeight: Double
        var saltWeight: Double
        var inoculationPercent: Double
        var servings: Int
        var notes: String
        var flourMix: String
        var yeastTypeRaw: String?
        var flours: [FlourSelection]
        var defaultSteps: [FormulaStepTemplate]
    }

    struct BakeRecord: Codable {
        var id: UUID
        var name: String
        var typeRaw: String
        var dateCreated: Date
        var targetBakeDateTime: Date
        var inoculationPercent: Double
        var totalFlourWeight: Double
        var totalWaterWeight: Double
        var totalDoughWeight: Double
        var hydrationPercent: Double
        var servings: Int
        var notes: String
        var isCancelled: Bool
        var formulaID: UUID?
        var starterID: UUID?
    }

    struct BakeStepRecord: Codable {
        var id: UUID
        var orderIndex: Int
        var typeRaw: String
        var nameOverride: String
        var descriptionText: String
        var plannedStart: Date
        var plannedDurationMinutes: Int
        var flexibleWindowStart: Date?
        var flexibleWindowEnd: Date?
        var actualStart: Date?
        var actualEnd: Date?
        var reminderOffsetMinutes: Int
        var temperatureRange: String
        var volumeTarget: String
        var statusRaw: String
        var notes: String
        var photoURI: String
        var bakeID: UUID?
    }
}

enum BackupService {
    enum BackupError: LocalizedError, Equatable {
        case invalidPayload
        case unsupportedSchemaVersion(Int)

        var errorDescription: String? {
            switch self {
            case .invalidPayload:
                return "Il file selezionato non contiene un backup Levain valido."
            case let .unsupportedSchemaVersion(version):
                return "Questo backup usa una versione non supportata (\(version))."
            }
        }
    }

    static func exportData(using modelContext: ModelContext) throws -> Data {
        let payload = BackupPayloadV1(
            schemaVersion: BackupPayloadV1.currentSchemaVersion,
            exportedAt: .now,
            starters: try modelContext.fetch(FetchDescriptor<Starter>())
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                .map { BackupPayloadV1.StarterRecord(starter: $0) },
            starterRefreshes: try modelContext.fetch(FetchDescriptor<StarterRefresh>())
                .sorted { $0.dateTime < $1.dateTime }
                .map { BackupPayloadV1.StarterRefreshRecord(refresh: $0) },
            recipeFormulas: try modelContext.fetch(FetchDescriptor<RecipeFormula>())
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                .map { BackupPayloadV1.RecipeFormulaRecord(formula: $0) },
            bakes: try modelContext.fetch(FetchDescriptor<Bake>())
                .sorted { $0.targetBakeDateTime < $1.targetBakeDateTime }
                .map { BackupPayloadV1.BakeRecord(bake: $0) },
            bakeSteps: try modelContext.fetch(FetchDescriptor<BakeStep>())
                .sorted {
                    if $0.plannedStart == $1.plannedStart {
                        return $0.orderIndex < $1.orderIndex
                    }
                    return $0.plannedStart < $1.plannedStart
                }
                .map { BackupPayloadV1.BakeStepRecord(step: $0) }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    static func restore(from data: Data, into modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let payload: BackupPayloadV1
        do {
            payload = try decoder.decode(BackupPayloadV1.self, from: data)
        } catch {
            throw BackupError.invalidPayload
        }

        guard payload.schemaVersion == BackupPayloadV1.currentSchemaVersion else {
            throw BackupError.unsupportedSchemaVersion(payload.schemaVersion)
        }

        try clearUserData(in: modelContext)

        let startersByID = try restoreStarters(from: payload.starters, into: modelContext)
        let formulasByID = try restoreRecipeFormulas(from: payload.recipeFormulas, into: modelContext)
        let bakesByID = try restoreBakes(
            from: payload.bakes,
            startersByID: startersByID,
            formulasByID: formulasByID,
            into: modelContext
        )
        try restoreStarterRefreshes(
            from: payload.starterRefreshes,
            startersByID: startersByID,
            into: modelContext
        )
        try restoreBakeSteps(
            from: payload.bakeSteps,
            bakesByID: bakesByID,
            into: modelContext
        )

        if let settings = try modelContext.fetch(FetchDescriptor<AppSettings>()).first {
            settings.didSeedSampleData = false
        }

        try modelContext.save()
    }

    private static func clearUserData(in modelContext: ModelContext) throws {
        for step in try modelContext.fetch(FetchDescriptor<BakeStep>()) {
            modelContext.delete(step)
        }
        for bake in try modelContext.fetch(FetchDescriptor<Bake>()) {
            modelContext.delete(bake)
        }
        for refresh in try modelContext.fetch(FetchDescriptor<StarterRefresh>()) {
            modelContext.delete(refresh)
        }
        for formula in try modelContext.fetch(FetchDescriptor<RecipeFormula>()) {
            modelContext.delete(formula)
        }
        for starter in try modelContext.fetch(FetchDescriptor<Starter>()) {
            modelContext.delete(starter)
        }

        try modelContext.save()
    }

    private static func restoreStarters(
        from records: [BackupPayloadV1.StarterRecord],
        into modelContext: ModelContext
    ) throws -> [UUID: Starter] {
        var startersByID: [UUID: Starter] = [:]

        for record in records {
            let starter = Starter(
                id: record.id,
                name: record.name,
                type: StarterType(rawValue: record.typeRaw) ?? .mixed,
                hydration: record.hydration,
                flourMix: record.flourMix,
                flours: record.flours,
                containerWeight: record.containerWeight,
                storageMode: StorageMode(rawValue: record.storageModeRaw) ?? .fridge,
                refreshIntervalDays: record.refreshIntervalDays,
                remindersEnabled: record.remindersEnabled,
                lastRefresh: record.lastRefresh,
                notes: record.notes
            )
            modelContext.insert(starter)
            startersByID[record.id] = starter
        }

        return startersByID
    }

    private static func restoreRecipeFormulas(
        from records: [BackupPayloadV1.RecipeFormulaRecord],
        into modelContext: ModelContext
    ) throws -> [UUID: RecipeFormula] {
        var formulasByID: [UUID: RecipeFormula] = [:]

        for record in records {
            let formula = RecipeFormula(
                id: record.id,
                name: record.name,
                type: RecipeCategory(rawValue: record.typeRaw) ?? .custom,
                totalFlourWeight: record.totalFlourWeight,
                totalWaterWeight: record.totalWaterWeight,
                saltWeight: record.saltWeight,
                inoculationPercent: record.inoculationPercent,
                servings: record.servings,
                notes: record.notes,
                flourMix: record.flourMix,
                yeastType: YeastType(rawValue: record.yeastTypeRaw ?? "") ?? .sourdough,
                flours: record.flours,
                defaultSteps: record.defaultSteps
            )
            modelContext.insert(formula)
            formulasByID[record.id] = formula
        }

        return formulasByID
    }

    private static func restoreBakes(
        from records: [BackupPayloadV1.BakeRecord],
        startersByID: [UUID: Starter],
        formulasByID: [UUID: RecipeFormula],
        into modelContext: ModelContext
    ) throws -> [UUID: Bake] {
        var bakesByID: [UUID: Bake] = [:]

        for record in records {
            let bake = Bake(
                id: record.id,
                name: record.name,
                type: RecipeCategory(rawValue: record.typeRaw) ?? .custom,
                targetBakeDateTime: record.targetBakeDateTime,
                formula: record.formulaID.flatMap { formulasByID[$0] },
                starter: record.starterID.flatMap { startersByID[$0] },
                inoculationPercent: record.inoculationPercent,
                totalFlourWeight: record.totalFlourWeight,
                totalWaterWeight: record.totalWaterWeight,
                totalDoughWeight: record.totalDoughWeight,
                hydrationPercent: record.hydrationPercent,
                servings: record.servings,
                notes: record.notes
            )
            bake.dateCreated = record.dateCreated
            bake.isCancelled = record.isCancelled
            modelContext.insert(bake)
            bakesByID[record.id] = bake
        }

        return bakesByID
    }

    private static func restoreStarterRefreshes(
        from records: [BackupPayloadV1.StarterRefreshRecord],
        startersByID: [UUID: Starter],
        into modelContext: ModelContext
    ) throws {
        for record in records {
            let refresh = StarterRefresh(
                id: record.id,
                dateTime: record.dateTime,
                flourWeight: record.flourWeight,
                waterWeight: record.waterWeight,
                starterWeightUsed: record.starterWeightUsed,
                ratioText: record.ratioText,
                putInFridgeAt: record.putInFridgeAt,
                notes: record.notes,
                ambientTemp: record.ambientTemp,
                photoURI: record.photoURI,
                starter: record.starterID.flatMap { startersByID[$0] }
            )
            modelContext.insert(refresh)
        }
    }

    private static func restoreBakeSteps(
        from records: [BackupPayloadV1.BakeStepRecord],
        bakesByID: [UUID: Bake],
        into modelContext: ModelContext
    ) throws {
        for record in records {
            let step = BakeStep(
                id: record.id,
                orderIndex: record.orderIndex,
                type: BakeStepType(rawValue: record.typeRaw) ?? .custom,
                nameOverride: record.nameOverride,
                descriptionText: record.descriptionText,
                plannedStart: record.plannedStart,
                plannedDurationMinutes: record.plannedDurationMinutes,
                flexibleWindowStart: record.flexibleWindowStart,
                flexibleWindowEnd: record.flexibleWindowEnd,
                actualStart: record.actualStart,
                actualEnd: record.actualEnd,
                reminderOffsetMinutes: record.reminderOffsetMinutes,
                temperatureRange: record.temperatureRange,
                volumeTarget: record.volumeTarget,
                status: StepStatus(rawValue: record.statusRaw) ?? .pending,
                notes: record.notes,
                photoURI: record.photoURI,
                bake: record.bakeID.flatMap { bakesByID[$0] }
            )
            modelContext.insert(step)
        }
    }
}

private extension BackupPayloadV1.StarterRecord {
    init(starter: Starter) {
        id = starter.id
        name = starter.name
        typeRaw = starter.typeRaw
        hydration = starter.hydration
        flourMix = starter.flourMix
        flours = starter.selectedFlours
        containerWeight = starter.containerWeight
        storageModeRaw = starter.storageModeRaw
        refreshIntervalDays = starter.refreshIntervalDays
        remindersEnabled = starter.remindersEnabled
        lastRefresh = starter.lastRefresh
        notes = starter.notes
    }
}

private extension BackupPayloadV1.StarterRefreshRecord {
    init(refresh: StarterRefresh) {
        id = refresh.id
        dateTime = refresh.dateTime
        flourWeight = refresh.flourWeight
        waterWeight = refresh.waterWeight
        starterWeightUsed = refresh.starterWeightUsed
        ratioText = refresh.ratioText
        putInFridgeAt = refresh.putInFridgeAt
        notes = refresh.notes
        ambientTemp = refresh.ambientTemp
        photoURI = refresh.photoURI
        starterID = refresh.starter?.id
    }
}

private extension BackupPayloadV1.RecipeFormulaRecord {
    init(formula: RecipeFormula) {
        id = formula.id
        name = formula.name
        typeRaw = formula.typeRaw
        totalFlourWeight = formula.totalFlourWeight
        totalWaterWeight = formula.totalWaterWeight
        saltWeight = formula.saltWeight
        inoculationPercent = formula.inoculationPercent
        servings = formula.servings
        notes = formula.notes
        flourMix = formula.flourMix
        yeastTypeRaw = formula.yeastTypeRaw
        flours = formula.selectedFlours
        defaultSteps = formula.defaultSteps
    }
}

private extension BackupPayloadV1.BakeRecord {
    init(bake: Bake) {
        id = bake.id
        name = bake.name
        typeRaw = bake.typeRaw
        dateCreated = bake.dateCreated
        targetBakeDateTime = bake.targetBakeDateTime
        inoculationPercent = bake.inoculationPercent
        totalFlourWeight = bake.totalFlourWeight
        totalWaterWeight = bake.totalWaterWeight
        totalDoughWeight = bake.totalDoughWeight
        hydrationPercent = bake.hydrationPercent
        servings = bake.servings
        notes = bake.notes
        isCancelled = bake.isCancelled
        formulaID = bake.formula?.id
        starterID = bake.starter?.id
    }
}

private extension BackupPayloadV1.BakeStepRecord {
    init(step: BakeStep) {
        id = step.id
        orderIndex = step.orderIndex
        typeRaw = step.typeRaw
        nameOverride = step.nameOverride
        descriptionText = step.descriptionText
        plannedStart = step.plannedStart
        plannedDurationMinutes = step.plannedDurationMinutes
        flexibleWindowStart = step.flexibleWindowStart
        flexibleWindowEnd = step.flexibleWindowEnd
        actualStart = step.actualStart
        actualEnd = step.actualEnd
        reminderOffsetMinutes = step.reminderOffsetMinutes
        temperatureRange = step.temperatureRange
        volumeTarget = step.volumeTarget
        statusRaw = step.statusRaw
        notes = step.notes
        photoURI = step.photoURI
        bakeID = step.bake?.id
    }
}

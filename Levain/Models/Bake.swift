import Foundation
import SwiftData

@Model
final class Bake {
    @Attribute(.unique) var id: UUID
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
    var formula: RecipeFormula?
    var starter: Starter?

    @Relationship(deleteRule: .cascade, inverse: \BakeStep.bake)
    var steps: [BakeStep]

    init(
        id: UUID = UUID(),
        name: String,
        type: BakeType,
        targetBakeDateTime: Date,
        formula: RecipeFormula?,
        starter: Starter? = nil,
        inoculationPercent: Double,
        totalFlourWeight: Double,
        totalWaterWeight: Double,
        totalDoughWeight: Double,
        hydrationPercent: Double,
        servings: Int,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.dateCreated = .now
        self.targetBakeDateTime = targetBakeDateTime
        self.formula = formula
        self.starter = starter
        self.inoculationPercent = inoculationPercent
        self.totalFlourWeight = totalFlourWeight
        self.totalWaterWeight = totalWaterWeight
        self.totalDoughWeight = totalDoughWeight
        self.hydrationPercent = hydrationPercent
        self.servings = servings
        self.notes = notes
        self.isCancelled = false
        self.steps = []
    }

    var type: BakeType {
        get { BakeType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var sortedSteps: [BakeStep] {
        steps.sorted { $0.orderIndex < $1.orderIndex }
    }

    var derivedStatus: BakeStatus {
        if isCancelled { return .cancelled }
        if sortedSteps.isEmpty == false && sortedSteps.allSatisfy({ [.done, .skipped].contains($0.status) }) {
            return .completed
        }
        if sortedSteps.contains(where: { $0.status == .running || $0.actualStart != nil }) {
            return .inProgress
        }
        return .planned
    }

    var activeStep: BakeStep? {
        sortedSteps.first(where: { $0.status == .running }) ??
        sortedSteps.first(where: { $0.status == .pending })
    }

    var nextActionableStep: BakeStep? {
        activeStep
    }

    var completedStepCount: Int {
        steps.filter { $0.isTerminal }.count
    }

    var totalStepCount: Int {
        steps.count
    }

    var progress: Double {
        guard totalStepCount > 0 else { return 0 }
        return Double(completedStepCount) / Double(totalStepCount)
    }

    func isOverdue(now: Date = .now) -> Bool {
        activeStep?.isOverdue(now: now) ?? false
    }
}


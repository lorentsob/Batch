import Foundation

enum BakeScheduler {
    static func generateBake(
        name: String,
        targetBakeDateTime: Date,
        formula: RecipeFormula,
        starter: Starter? = nil,
        notes: String = ""
    ) -> Bake {
        formula.recalculateDerivedValues()
        let bake = Bake(
            name: name.isEmpty ? formula.name : name,
            type: formula.type,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: starter,
            inoculationPercent: formula.inoculationPercent,
            totalFlourWeight: formula.totalFlourWeight,
            totalWaterWeight: formula.totalWaterWeight,
            totalDoughWeight: formula.totalDoughWeight,
            hydrationPercent: formula.hydrationPercent,
            servings: formula.servings,
            notes: notes
        )
        let steps = generateSteps(for: bake, from: formula, targetBakeDateTime: targetBakeDateTime)
        bake.steps = steps
        steps.forEach { $0.bake = bake }
        return bake
    }

    static func generateSteps(
        for bake: Bake,
        from formula: RecipeFormula,
        targetBakeDateTime: Date
    ) -> [BakeStep] {
        let templates = formula.defaultSteps
        var cursor = targetBakeDateTime
        var result: [BakeStep] = []

        for index in templates.indices.reversed() {
            let template = templates[index]
            let start = cursor.adding(minutes: -max(template.durationMinutes, 1))
            let isWindowBased = [.proof, .coldRetard].contains(template.type)
            let flexibleWindowStart = isWindowBased ? cursor : start
            let flexibleWindowEnd = isWindowBased
                ? cursor.adding(minutes: max(template.reminderOffsetMinutes, 60))
                : cursor
            let step = BakeStep(
                orderIndex: index,
                type: template.type,
                nameOverride: template.name,
                descriptionText: template.details,
                plannedStart: start,
                plannedDurationMinutes: max(template.durationMinutes, 1),
                flexibleWindowStart: flexibleWindowStart,
                flexibleWindowEnd: flexibleWindowEnd,
                reminderOffsetMinutes: max(template.reminderOffsetMinutes, 0),
                temperatureRange: template.temperatureRange,
                volumeTarget: template.volumeTarget,
                notes: template.notes,
                bake: bake
            )
            result.append(step)
            cursor = start
        }

        return result.sorted { $0.orderIndex < $1.orderIndex }
    }

    static func shiftFutureSteps(in bake: Bake, after anchorStep: BakeStep, by minutes: Int) {
        guard minutes != 0 else { return }
        for step in bake.steps where step.orderIndex > anchorStep.orderIndex && step.isTerminal == false {
            step.plannedStart = step.plannedStart.adding(minutes: minutes)
            step.flexibleWindowStart = step.flexibleWindowStart?.adding(minutes: minutes)
            step.flexibleWindowEnd = step.flexibleWindowEnd?.adding(minutes: minutes)
        }
        bake.targetBakeDateTime = bake.sortedSteps.last?.plannedEnd ?? bake.targetBakeDateTime
    }
}

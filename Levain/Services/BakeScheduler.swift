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
            notes: notes,
            ingredients: formula.ingredients ?? "",
            procedure: formula.procedure ?? "",
            bakingInstructions: formula.bakingInstructions ?? ""
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

        // When the anchor is running, its plannedEnd = actualStart + duration (frozen — not
        // affected by plannedStart). Shifting subsequent steps by `minutes` from their current
        // plannedStart would leave a gap of `minutes` between the hero-card "Fine" and the
        // timeline "Inizio" of the next step.
        //
        // Fix: re-anchor the first subsequent step to plannedEnd + minutes so the gap equals
        // exactly the requested delay. Remaining steps keep their relative offsets.
        let effectiveShift: Int
        if anchorStep.status == .running,
           let firstNext = bake.sortedSteps
               .filter({ $0.orderIndex > anchorStep.orderIndex && !$0.isTerminal })
               .min(by: { $0.orderIndex < $1.orderIndex }) {
            let target = anchorStep.plannedEnd.adding(minutes: minutes)
            effectiveShift = Int(target.timeIntervalSince(firstNext.plannedStart) / 60)
        } else {
            effectiveShift = minutes
        }

        for step in bake.steps where step.isTerminal == false {
            // Always shift only steps strictly after the anchor. The special-case logic above
            // for a running anchor adjusts `effectiveShift` so the first subsequent step is
            // re-anchored to `plannedEnd + minutes` without moving the anchor itself.
            let minIndex = anchorStep.orderIndex + 1
            guard step.orderIndex >= minIndex else { continue }
            step.plannedStart = step.plannedStart.adding(minutes: effectiveShift)
            step.flexibleWindowStart = step.flexibleWindowStart?.adding(minutes: effectiveShift)
            step.flexibleWindowEnd = step.flexibleWindowEnd?.adding(minutes: effectiveShift)
        }
        bake.targetBakeDateTime = bake.sortedSteps.last?.plannedEnd ?? bake.targetBakeDateTime
    }
}

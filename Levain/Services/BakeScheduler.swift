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
                ingredients: template.ingredients,
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
               .filter({ $0.orderIndex > anchorStep.orderIndex && !$0.isTerminal && $0.status == .pending })
               .min(by: { $0.orderIndex < $1.orderIndex }) {
            let target = anchorStep.plannedEnd.adding(minutes: minutes)
            let diffMinutes = target.timeIntervalSince(firstNext.plannedStart) / 60
            effectiveShift = Int(diffMinutes.rounded())
        } else {
            effectiveShift = minutes
        }

        // When the anchor is pending (not yet started), include it in the shift so the
        // hero card reflects the new planned time immediately. Running anchors are excluded
        // because their actual start is already recorded.
        let minIndex = anchorStep.status == .pending
            ? anchorStep.orderIndex
            : anchorStep.orderIndex + 1

        for step in bake.steps where step.isTerminal == false {
            guard step.orderIndex >= minIndex else { continue }
            // Only shift steps that have not started yet; started/completed steps are driven by actual times.
            guard step.status == .pending else { continue }
            step.plannedStart = step.plannedStart.adding(minutes: effectiveShift)
            step.flexibleWindowStart = step.flexibleWindowStart?.adding(minutes: effectiveShift)
            step.flexibleWindowEnd = step.flexibleWindowEnd?.adding(minutes: effectiveShift)
        }

        // When the anchor is running, extend its window so the overdue
        // indicator reflects the shift.  Without this the hero card shows
        // unchanged times (actualStart is frozen) and the user perceives
        // "no effect."  The raw `minutes` value is used (not effectiveShift)
        // because effectiveShift may differ due to gap re-anchoring logic.
        if anchorStep.status == .running {
            anchorStep.flexibleWindowEnd = (anchorStep.flexibleWindowEnd ?? anchorStep.plannedEnd)
                .adding(minutes: minutes)
        }

        bake.targetBakeDateTime = bake.sortedSteps.last?.plannedEnd ?? bake.targetBakeDateTime
    }
}

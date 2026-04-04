import Foundation

enum BakeScheduler {
    static func generateBake(
        name: String,
        targetBakeDateTime: Date,
        formula: RecipeFormula,
        starter: Starter? = nil,
        notes: String = "",
        yeastConversion: YeastConversionResult? = nil
    ) -> Bake {
        formula.recalculateDerivedValues()

        // Quando viene fornita una conversione lievito commerciale, usiamo i suoi valori
        // per farina/acqua/peso totale al posto di quelli della formula originale.
        let flourWeight    = yeastConversion?.newTotalFlourWeight ?? formula.totalFlourWeight
        let waterWeight    = yeastConversion?.newTotalWaterWeight ?? formula.totalWaterWeight
        let hydration      = yeastConversion?.hydrationPercent    ?? formula.hydrationPercent
        let inoculationPct = yeastConversion.map { $0.yeastPercent } ?? formula.inoculationPercent
        let totalDough     = yeastConversion?.totalDoughWeight     ?? formula.totalDoughWeight

        let bake = Bake(
            name: name.isEmpty ? formula.name : name,
            type: formula.type,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: starter,
            inoculationPercent: inoculationPct,
            totalFlourWeight: flourWeight,
            totalWaterWeight: waterWeight,
            totalDoughWeight: totalDough,
            hydrationPercent: hydration,
            servings: formula.servings,
            notes: notes,
            ingredients: formula.ingredients ?? "",
            procedure: formula.procedure ?? "",
            bakingInstructions: formula.bakingInstructions ?? ""
        )
        let steps = generateSteps(
            for: bake,
            from: formula,
            targetBakeDateTime: targetBakeDateTime,
            yeastConversion: yeastConversion
        )
        bake.steps = steps
        steps.forEach { $0.bake = bake }
        return bake
    }

    static func generateSteps(
        for bake: Bake,
        from formula: RecipeFormula,
        targetBakeDateTime: Date,
        yeastConversion: YeastConversionResult? = nil
    ) -> [BakeStep] {
        let templates = formula.defaultSteps
        var cursor = targetBakeDateTime
        var result: [BakeStep] = []

        for index in templates.indices.reversed() {
            let template = templates[index]
            // Se è una conversione lievito commerciale, sostituiamo le durate di bulk e proof
            // con quelle calcolate dal profilo tempi scelto.
            let effectiveDuration: Int
            if let yeastConversion {
                switch template.type {
                case .bulk:
                    effectiveDuration = yeastConversion.bulkDurationMinutes
                case .proof:
                    effectiveDuration = yeastConversion.proofDurationMinutes
                default:
                    effectiveDuration = template.durationMinutes
                }
            } else {
                effectiveDuration = template.durationMinutes
            }
            let start = cursor.adding(minutes: -max(effectiveDuration, 1))
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
                plannedDurationMinutes: max(effectiveDuration, 1),
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

        // L'ancora non si sposta mai: solo gli step FUTURI (con indice maggiore)
        // e ancora incompleti vengono traslati.
        let minIndex = anchorStep.orderIndex + 1

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

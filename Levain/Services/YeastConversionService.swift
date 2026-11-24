import Foundation

/// Risultato del ricalcolo per una cottura con lievito commerciale.
/// Contiene i nuovi valori idratazione/farina/acqua e la quantità di lievito consigliata.
struct YeastConversionResult {
    /// Peso farina totale dopo aver reintegrato la quota farina dello starter
    let newTotalFlourWeight: Double
    /// Peso acqua totale dopo aver reintegrato la quota acqua dello starter
    let newTotalWaterWeight: Double
    /// Grammi di lievito commerciale consigliati per il profilo scelto
    let yeastGrams: Double
    /// Durata bulk fermentation in minuti
    let bulkDurationMinutes: Int
    /// Durata appretto in minuti
    let proofDurationMinutes: Int

    /// Peso base convertito (farina + acqua + lievito). Il sale resta sulla formula.
    var totalDoughWeight: Double { newTotalFlourWeight + newTotalWaterWeight + yeastGrams }

    /// Idratazione effettiva della nuova ricetta (%)
    var hydrationPercent: Double {
        guard newTotalFlourWeight > 0 else { return 0 }
        return (newTotalWaterWeight / newTotalFlourWeight) * 100
    }

    /// Percentuale lievito rispetto alla farina
    var yeastPercent: Double {
        guard newTotalFlourWeight > 0 else { return 0 }
        return (yeastGrams / newTotalFlourWeight) * 100
    }
}

/// Servizio di conversione sourdough → lievito commerciale.
/// Tutta la matematica è derivata dal documento "conversione_lievito_madre_a_lievito_di_birra_con_tempi_v2".
///
/// Regole core:
/// 1. Scomponi lo starter in farina + acqua in base all'idratazione
/// 2. Aggiungi farina/acqua dello starter ai totali della ricetta
/// 3. Calcola grammi di lievito scalati proporzionalmente alla farina (base: 500 g)
/// 4. Usa le durate da YeastProfile
enum YeastConversionService {

    // MARK: - Conversione principale

    /// Converte una ricetta sourdough in una ricetta con lievito commerciale.
    /// - Parameters:
    ///   - formulaFlour: Farina totale della ricetta originale (g)
    ///   - formulaWater: Acqua totale della ricetta originale (g)
    ///   - starterWeight: Peso starter sourdough usato nella ricetta originale (g)
    ///   - starterHydration: Idratazione starter in % (es. 100 per 1:1, 50 per soda)
    ///   - targetYeastType: Tipo di lievito commerciale desiderato
    ///   - profile: Profilo tempi (rapida/media/lenta)
    static func convert(
        formulaFlour: Double,
        formulaWater: Double,
        starterWeight: Double,
        starterHydration: Double,
        targetYeastType: YeastType,
        profile: YeastProfile
    ) -> YeastConversionResult {
        // 1. Scomponi lo starter
        let (starterFlour, starterWater) = decompose(
            starterWeight: starterWeight,
            hydration: starterHydration
        )

        // 2. Nuova ricetta senza starter
        let newFlour = formulaFlour + starterFlour
        let newWater = formulaWater + starterWater

        // 3. Grammi di lievito scalati sulla nuova farina
        let yeastGrams = yeastAmount(
            for: targetYeastType,
            profile: profile,
            flourWeight: newFlour
        )

        return YeastConversionResult(
            newTotalFlourWeight: newFlour,
            newTotalWaterWeight: newWater,
            yeastGrams: yeastGrams,
            bulkDurationMinutes: profile.bulkDurationMinutes,
            proofDurationMinutes: profile.proofDurationMinutes
        )
    }

    // MARK: - Calcoli starter-free (ricette già senza starter)

    /// Calcola solo la quantità di lievito e i tempi per una ricetta che non usa starter.
    static func calculateYeast(
        flourWeight: Double,
        waterWeight: Double = 0,
        targetYeastType: YeastType,
        profile: YeastProfile
    ) -> YeastConversionResult {
        let yeastGrams = yeastAmount(for: targetYeastType, profile: profile, flourWeight: flourWeight)
        return YeastConversionResult(
            newTotalFlourWeight: flourWeight,
            newTotalWaterWeight: waterWeight,
            yeastGrams: yeastGrams,
            bulkDurationMinutes: profile.bulkDurationMinutes,
            proofDurationMinutes: profile.proofDurationMinutes
        )
    }

    // MARK: - Conversioni tra tipi di lievito

    /// Converte grammi da lievito fresco a un altro tipo.
    static func convertFreshYeast(_ freshGrams: Double, to targetType: YeastType) -> Double {
        switch targetType {
        case .freshYeast:   freshGrams
        case .dryYeast:     freshGrams * 0.40      // fresco × 0.40 = secco attivo
        case .instantYeast: freshGrams * 0.33      // fresco × 0.33 = instant
        case .sourdough, .none: freshGrams
        }
    }

    /// Converte grammi da instant a un altro tipo.
    static func convertInstantYeast(_ instantGrams: Double, to targetType: YeastType) -> Double {
        switch targetType {
        case .instantYeast: instantGrams
        case .freshYeast:   instantGrams * 3.0     // instant × 3 = fresco
        case .dryYeast:     instantGrams * 1.25    // instant × 3 × 0.40 = secco
        case .sourdough, .none: instantGrams
        }
    }

    // MARK: - Helpers privati

    /// Scompone lo starter in (farina, acqua) secondo la sua idratazione.
    /// Formula generale: farina = peso / (1 + idratazione/100)
    static func decompose(starterWeight: Double, hydration: Double) -> (flour: Double, water: Double) {
        guard starterWeight > 0, hydration >= 0 else { return (0, 0) }
        let flour = starterWeight / (1 + hydration / 100)
        let water = starterWeight - flour
        return (flour: flour, water: water)
    }

    /// Grammi di lievito per un tipo e profilo dati, scalati sulla farina effettiva.
    private static func yeastAmount(
        for yeastType: YeastType,
        profile: YeastProfile,
        flourWeight: Double
    ) -> Double {
        guard flourWeight > 0 else { return 0 }
        let scale = flourWeight / 500.0
        let baseGrams: Double = switch yeastType {
        case .freshYeast:   profile.freshYeastGramsPer500
        case .dryYeast:     profile.dryYeastGramsPer500
        case .instantYeast: profile.instantYeastGramsPer500
        default:            0
        }
        // Arrotonda a 0.1 g per leggibilità
        return (baseGrams * scale * 10).rounded() / 10
    }
}

enum RecipeYeastAdaptationService {
    static func adaptedFormula(
        from source: RecipeFormula,
        conversion: YeastConversionResult,
        targetYeastType: YeastType,
        profile: YeastProfile
    ) -> RecipeFormula {
        let adapted = source.duplicate(newName: source.name)
        adapted.yeastType = targetYeastType
        adapted.totalFlourWeight = conversion.newTotalFlourWeight
        adapted.totalWaterWeight = conversion.newTotalWaterWeight
        adapted.inoculationPercent = conversion.yeastPercent
        adapted.recalculateDerivedValues()
        adapted.ingredients = adaptedIngredientsPayload(
            source.ingredients ?? "",
            conversion: conversion,
            targetYeastType: targetYeastType
        )
        adapted.procedure = adaptedProcedurePayload(
            source.procedure ?? "",
            formulaName: source.name,
            formulaType: source.type,
            conversion: conversion,
            targetYeastType: targetYeastType
        )
        adapted.defaultSteps = adaptedSteps(
            source.defaultSteps,
            formulaName: source.name,
            formulaType: source.type,
            conversion: conversion,
            targetYeastType: targetYeastType,
            profile: profile
        )
        return adapted
    }

    private static func adaptedIngredientsPayload(
        _ payload: String,
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        guard var sections = decode([IngredientSectionPayload].self, from: payload) else {
            return adaptText(payload, conversion: conversion, targetYeastType: targetYeastType)
        }

        let yeastLine = commercialYeastLine(conversion: conversion, targetYeastType: targetYeastType)
        var replacedYeast = false

        for sectionIndex in sections.indices {
            sections[sectionIndex].title = adaptText(sections[sectionIndex].title, conversion: conversion, targetYeastType: targetYeastType)
            sections[sectionIndex].items = sections[sectionIndex].items.map { item in
                if referencesSourdough(item) {
                    replacedYeast = true
                    return yeastLine
                }
                return adaptText(item, conversion: conversion, targetYeastType: targetYeastType)
            }
        }

        if replacedYeast == false {
            if let impastoIndex = sections.firstIndex(where: { $0.title.localizedCaseInsensitiveContains("impasto") }) {
                sections[impastoIndex].items.append(yeastLine)
            } else if sections.isEmpty == false {
                sections[0].items.append(yeastLine)
            } else {
                sections.append(IngredientSectionPayload(title: "Impasto", items: [yeastLine]))
            }
        }

        return encode(sections) ?? payload
    }

    private static func adaptedProcedurePayload(
        _ payload: String,
        formulaName: String,
        formulaType: RecipeCategory,
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        guard var sections = decode([ProcedureSectionPayload].self, from: payload) else {
            return adaptText(payload, conversion: conversion, targetYeastType: targetYeastType)
        }

        if isPizza(formulaName: formulaName, formulaType: formulaType) {
            sections = sections.compactMap { section in
                let searchable = "\(section.title)\n\(section.content)".lowercased()
                if searchable.contains("starter prep")
                    || searchable.contains("rinfresca")
                    || searchable.contains("tira fuori il lievito madre") {
                    return nil
                }

                var adapted = section
                let title = section.title.lowercased()
                if title.contains("impasto") {
                    adapted.content = pizzaMixDetails(conversion: conversion, targetYeastType: targetYeastType)
                } else if title.contains("bulk") || title.contains("puntata") {
                    adapted.content = pizzaBulkDetails(conversion: conversion)
                } else if title.contains("formatura") || title.contains("staglio") {
                    adapted.content = pizzaShapeDetails(conversion: conversion)
                } else {
                    adapted.content = adaptText(section.content, conversion: conversion, targetYeastType: targetYeastType)
                }
                return adapted
            }
        } else {
            sections = sections.map { section in
                ProcedureSectionPayload(
                    title: adaptText(section.title, conversion: conversion, targetYeastType: targetYeastType),
                    level: section.level,
                    content: adaptText(section.content, conversion: conversion, targetYeastType: targetYeastType)
                )
            }
        }

        return encode(sections) ?? payload
    }

    private static func adaptedSteps(
        _ steps: [FormulaStepTemplate],
        formulaName: String,
        formulaType: RecipeCategory,
        conversion: YeastConversionResult,
        targetYeastType: YeastType,
        profile: YeastProfile
    ) -> [FormulaStepTemplate] {
        let isPizzaFormula = isPizza(formulaName: formulaName, formulaType: formulaType)
        let hasProof = steps.contains { $0.type == .proof }
        var result: [FormulaStepTemplate] = []

        for step in steps {
            if isPizzaFormula, step.type == .shape, hasProof == false {
                result.append(
                    FormulaStepTemplate(
                        id: step.id,
                        type: .shape,
                        name: step.name.isEmpty ? "Formatura" : step.name,
                        details: "- Dividi l'impasto in panetti e forma le palline.",
                        durationMinutes: min(max(step.durationMinutes, 15), 30),
                        reminderOffsetMinutes: step.reminderOffsetMinutes,
                        temperatureRange: step.temperatureRange,
                        volumeTarget: step.volumeTarget,
                        notes: step.notes,
                        ingredients: step.ingredients.map {
                            adaptText($0, conversion: conversion, targetYeastType: targetYeastType)
                        }
                    )
                )
                result.append(
                    FormulaStepTemplate(
                        type: .proof,
                        name: "Appretto",
                        details: pizzaProofDetails(conversion: conversion),
                        durationMinutes: conversion.proofDurationMinutes,
                        reminderOffsetMinutes: 15,
                        temperatureRange: step.temperatureRange,
                        volumeTarget: step.volumeTarget,
                        notes: "Durata adattata al profilo \(profile.shortTitle)."
                    )
                )
                continue
            }

            var adapted = step
            adapted.details = adaptedStepDetails(
                step,
                isPizzaFormula: isPizzaFormula,
                conversion: conversion,
                targetYeastType: targetYeastType
            )
            adapted.ingredients = adaptedStepIngredients(
                step.ingredients,
                conversion: conversion,
                targetYeastType: targetYeastType
            )
            result.append(adapted)
        }

        return result
    }

    private static func adaptedStepDetails(
        _ step: FormulaStepTemplate,
        isPizzaFormula: Bool,
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        guard isPizzaFormula else {
            return adaptText(step.details, conversion: conversion, targetYeastType: targetYeastType)
        }

        switch step.type {
        case .mix:
            return pizzaMixDetails(conversion: conversion, targetYeastType: targetYeastType)
        case .bulk:
            return pizzaBulkDetails(conversion: conversion)
        case .proof:
            return pizzaProofDetails(conversion: conversion)
        default:
            return adaptText(step.details, conversion: conversion, targetYeastType: targetYeastType)
        }
    }

    private static func adaptedStepIngredients(
        _ ingredients: [String],
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> [String] {
        let yeastLine = commercialYeastLine(conversion: conversion, targetYeastType: targetYeastType)
        var replacedYeast = false
        var adapted = ingredients.map { item in
            if referencesSourdough(item) {
                replacedYeast = true
                return yeastLine
            }
            return adaptText(item, conversion: conversion, targetYeastType: targetYeastType)
        }

        if replacedYeast == false, ingredients.contains(where: { $0.localizedCaseInsensitiveContains("farina") }) {
            adapted.append(yeastLine)
        }

        return adapted
    }

    private static func pizzaMixDetails(
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        let yeastLine = commercialYeastLine(conversion: conversion, targetYeastType: targetYeastType)
        return """
        - Sciogli o disperdi \(yeastLine) nell'acqua.
        - Aggiungi la farina.
        - Aggiungi il sale.
        - Aggiungi infine l'olio.
        - Lavora fino a ottenere un impasto liscio e omogeneo.
        """
    }

    private static func pizzaBulkDetails(conversion: YeastConversionResult) -> String {
        """
        - Lascia fermentare l'impasto coperto per circa \(durationLabel(conversion.bulkDurationMinutes)).
        - Fai 2-3 giri di pieghe nella prima parte se l'impasto ha bisogno di struttura.
        - Procedi quando l'impasto e' visibilmente cresciuto e piu' arioso.
        """
    }

    private static func pizzaShapeDetails(conversion: YeastConversionResult) -> String {
        """
        - Dividi l'impasto in panetti e forma le palline.
        - Copri i panetti e lasciali rilassare per l'appretto.
        - Stendi i panetti poco prima del condimento.
        """
    }

    private static func pizzaProofDetails(conversion: YeastConversionResult) -> String {
        """
        - Lascia apprettare i panetti coperti per circa \(durationLabel(conversion.proofDurationMinutes)).
        - Procedi quando i panetti sono rilassati, leggermente gonfi e facili da stendere.
        """
    }

    private static func adaptText(
        _ text: String,
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        text
            .replacingOccurrences(of: "lievito madre già rinfrescato la sera prima", with: commercialYeastLine(conversion: conversion, targetYeastType: targetYeastType), options: .caseInsensitive)
            .replacingOccurrences(of: "lievito madre", with: targetYeastType.ingredientName, options: .caseInsensitive)
            .replacingOccurrences(of: "starter", with: targetYeastType.ingredientName, options: .caseInsensitive)
            .replacingOccurrences(of: "levain", with: targetYeastType.ingredientName, options: .caseInsensitive)
    }

    private static func referencesSourdough(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return lowercased.contains("lievito madre")
            || lowercased.contains("starter")
            || lowercased.contains("levain")
    }

    private static func commercialYeastLine(
        conversion: YeastConversionResult,
        targetYeastType: YeastType
    ) -> String {
        "\(formatGrams(conversion.yeastGrams)) g \(targetYeastType.ingredientName)"
    }

    private static func isPizza(formulaName: String, formulaType: RecipeCategory) -> Bool {
        formulaType == .pizza || formulaName.localizedCaseInsensitiveContains("pizza")
    }

    private static func durationLabel(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours)h" : "\(hours)h \(remainingMinutes)min"
        }
        return "\(minutes) min"
    }

    private static func formatGrams(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if abs(rounded.rounded() - rounded) < 0.01 {
            return "\(Int(rounded.rounded()))"
        }
        return String(format: "%.1f", rounded).replacingOccurrences(of: ".", with: ",")
    }

    private static func decode<T: Decodable>(_ type: T.Type, from payload: String) -> T? {
        guard payload.isEmpty == false, let data = payload.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func encode<T: Encodable>(_ value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

private struct IngredientSectionPayload: Codable {
    var title: String
    var items: [String]
}

private struct ProcedureSectionPayload: Codable {
    var title: String
    var level: Int?
    var content: String
}

private extension YeastType {
    var ingredientName: String {
        switch self {
        case .freshYeast:
            return "lievito di birra fresco"
        case .dryYeast:
            return "lievito di birra secco attivo"
        case .instantYeast:
            return "lievito secco istantaneo"
        case .sourdough:
            return "lievito madre"
        case .none:
            return "nessun lievito"
        }
    }
}

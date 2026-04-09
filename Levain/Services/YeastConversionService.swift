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

    /// Peso totale impasto finale (farina + acqua + sale stimato + lievito)
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
        targetYeastType: YeastType,
        profile: YeastProfile
    ) -> YeastConversionResult {
        let yeastGrams = yeastAmount(for: targetYeastType, profile: profile, flourWeight: flourWeight)
        return YeastConversionResult(
            newTotalFlourWeight: flourWeight,
            newTotalWaterWeight: 0,
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

import Foundation

enum StarterType: String, CaseIterable, Codable, Identifiable {
    case wheat
    case semolina
    case rye
    case mixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wheat: "Grano tenero"
        case .semolina: "Grano duro"
        case .rye: "Segale"
        case .mixed: "Mix"
        }
    }
}

enum StorageMode: String, CaseIterable, Codable, Identifiable {
    case roomTemperature
    case fridge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roomTemperature: "Fuori frigo"
        case .fridge: "Frigo"
        }
    }
}

enum KefirStorageMode: String, CaseIterable, Codable, Identifiable {
    case roomTemperature = "room_temperature"
    case fridge
    case freezer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roomTemperature: "Fuori frigo"
        case .fridge: "Frigo"
        case .freezer: "Freezer"
        }
    }

    var defaultRoutineHours: Int {
        switch self {
        case .roomTemperature: 24
        case .fridge: 7 * 24
        case .freezer: 7 * 24
        }
    }

    var defaultWarningLeadTime: TimeInterval? {
        switch self {
        case .roomTemperature: 4 * 60 * 60
        case .fridge: 24 * 60 * 60
        case .freezer: 24 * 60 * 60
        }
    }

    var defaultDueNowLeadTime: TimeInterval {
        switch self {
        case .roomTemperature: 60 * 60
        case .fridge: 6 * 60 * 60
        case .freezer: 6 * 60 * 60
        }
    }
}

enum KefirBatchState: String, CaseIterable, Codable, Identifiable {
    case active
    case dueSoon = "due_soon"
    case dueNow = "due_now"
    case overdue
    case pausedFridge = "paused_fridge"
    case pausedFreezer = "paused_freezer"
    case archived

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: "Attivo"
        case .dueSoon: "Da rinfrescare a breve"
        case .dueNow: "Da rinfrescare"
        case .overdue: "In ritardo"
        case .pausedFridge: "In frigo"
        case .pausedFreezer: "In freezer"
        case .archived: "Archiviato"
        }
    }

    var isPaused: Bool {
        switch self {
        case .pausedFridge, .pausedFreezer:
            true
        default:
            false
        }
    }
}

enum KefirPrimaryAction: String, CaseIterable, Codable, Identifiable {
    case renew
    case manage
    case reactivate
    case open

    var id: String { rawValue }

    var title: String {
        switch self {
        case .renew: "Rinnova"
        case .manage: "Gestisci"
        case .reactivate: "Riattiva"
        case .open: "Apri"
        }
    }
}

enum RecipeCategory: String, CaseIterable, Codable, Identifiable {
    case pane
    case pizza
    case focaccia
    case grandiLievitati
    case dolci
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pane: "Pane"
        case .pizza: "Pizza"
        case .focaccia: "Focaccia"
        case .grandiLievitati: "Grandi lievitati"
        case .dolci: "Dolci"
        case .custom: "Altro"
        }
    }
}

enum YeastType: String, CaseIterable, Codable, Identifiable {
    case sourdough
    case dryYeast
    case freshYeast
    case instantYeast
    case none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sourdough: "Lievito madre"
        case .dryYeast: "Lievito di birra secco attivo"
        case .freshYeast: "Lievito di birra fresco"
        case .instantYeast: "Lievito secco istantaneo"
        case .none: "Nessun lievito"
        }
    }

    var shortTitle: String {
        switch self {
        case .sourdough: "Madre"
        case .dryYeast: "Lievito"
        case .freshYeast: "Lievito"
        case .instantYeast: "Lievito"
        case .none: "Nessun lievito"
        }
    }

    var isCommercial: Bool {
        switch self {
        case .dryYeast, .freshYeast, .instantYeast: true
        default: false
        }
    }

    /// Tipi selezionabili come lievito commerciale nella creazione cottura
    static var commercialCases: [YeastType] { [.freshYeast, .dryYeast, .instantYeast] }
}

/// Profilo tempi di lievitazione — non persistito, usato solo in fase di creazione cottura
enum YeastProfile: String, CaseIterable, Identifiable {
    case slow
    case medium
    case fast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slow: "Lenta (16–20h)"
        case .medium: "Media (8–12h)"
        case .fast: "Rapida (2–4h)"
        }
    }

    var shortTitle: String {
        switch self {
        case .slow: "Lenta"
        case .medium: "Media"
        case .fast: "Rapida"
        }
    }

    /// Durata bulk fermentation in minuti (midpoint del range)
    var bulkDurationMinutes: Int {
        switch self {
        case .slow: 1080   // 18h
        case .medium: 360  // 6h
        case .fast: 90     // 1.5h
        }
    }

    /// Durata appretto in minuti (midpoint del range)
    var proofDurationMinutes: Int {
        switch self {
        case .slow: 600    // 10h (tipicamente freddo)
        case .medium: 90   // 1.5h
        case .fast: 60     // 1h
        }
    }

    /// Grammi di lievito instant per 500g farina (midpoint del range da documento)
    var instantYeastGramsPer500: Double {
        switch self {
        case .slow: 1.5
        case .medium: 3.0
        case .fast: 6.0
        }
    }

    /// Grammi di lievito fresco per 500g farina (midpoint del range da documento)
    var freshYeastGramsPer500: Double {
        switch self {
        case .slow: 4.75
        case .medium: 9.0
        case .fast: 18.0
        }
    }

    /// Grammi di lievito secco attivo per 500g farina
    var dryYeastGramsPer500: Double {
        // Secco attivo ≈ instant × 1.25 (fresco × 0.40 vs fresco × 0.33)
        switch self {
        case .slow: 1.9
        case .medium: 3.75
        case .fast: 7.5
        }
    }
}

enum FlourCategory: String, CaseIterable, Codable, Identifiable {
    case strong
    case medium
    case weak
    case whole
    case rye
    case semolina
    case special
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .strong: "Manitoba"
        case .medium: "00/0"
        case .weak: "Debole"
        case .whole: "Integrale"
        case .rye: "Segale"
        case .semolina: "Semola"
        case .special: "Spezzata/Multicereale"
        case .custom: "Altro"
        }
    }

    /// Nome compatto senza specifica W — usato nei chip di dettaglio e nelle card
    var shortTitle: String {
        switch self {
        case .strong:    "Manitoba"
        case .medium:    "Bianca"
        case .weak:      "Debole"
        case .whole:     "Integrale"
        case .rye:       "Segale"
        case .semolina:  "Semola"
        case .special:   "Multicereale"
        case .custom:    "Altra"
        }
    }
}

struct FlourSelection: Codable, Identifiable, Hashable {
    var id = UUID()
    var categoryRaw: String
    var customName: String
    var percentage: Double // typically 0-100% of the total flour
    
    var category: FlourCategory {
        get { FlourCategory(rawValue: categoryRaw) ?? .custom }
        set { categoryRaw = newValue.rawValue }
    }
    
    /// Nome completo (con spec W) — usato nell'editor e dove serve precisione
    var displayName: String {
        if category == .custom || !customName.isEmpty {
            return customName.isEmpty ? category.title : customName
        }
        return category.title
    }

    /// Nome compatto senza spec W — usato nei chip di dettaglio e nelle card compact
    var shortDisplayName: String {
        if category == .custom || !customName.isEmpty {
            return customName.isEmpty ? category.shortTitle : customName
        }
        return category.shortTitle
    }
}

enum BakeStepType: String, CaseIterable, Codable, Identifiable {
    case starterRefresh
    case autolysis
    case mix
    case bulk
    case fold
    case preshape
    case benchRest
    case shape
    case proof
    case coldRetard
    case bake
    case cool
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .starterRefresh: "Rinfresco starter"
        case .autolysis: "Autolisi"
        case .mix: "Impasto"
        case .bulk: "Puntata"
        case .fold: "Pieghe"
        case .preshape: "Preforma"
        case .benchRest: "Riposo al banco"
        case .shape: "Formatura"
        case .proof: "Appretto"
        case .coldRetard: "Riposo in frigo"
        case .bake: "Cottura"
        case .cool: "Raffreddamento"
        case .custom: "Fase personalizzata"
        }
    }
}

enum StepStatus: String, CaseIterable, Codable, Identifiable {
    case pending
    case running
    case done
    case skipped

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pending: "Da fare"
        case .running: "In corso"
        case .done: "Completato"
        case .skipped: "Saltato"
        }
    }
}

enum BakeStatus: String, CaseIterable, Codable, Identifiable {
    case planned
    case inProgress
    case completed
    case cancelled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .planned: "Pianificato"
        case .inProgress: "In corso"
        case .completed: "Completato"
        case .cancelled: "Annullato"
        }
    }
}

enum StarterDueState: String, CaseIterable, Codable, Identifiable {
    case ok
    case dueToday
    case overdue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ok: "Ok"
        case .dueToday: "Da rinfrescare oggi"
        case .overdue: "In ritardo"
        }
    }
}

enum KnowledgeCategory: String, CaseIterable, Codable, Identifiable {
    case starter
    case fermentation
    case bakerMath
    case troubleshooting

    var id: String { rawValue }

    var title: String {
        switch self {
        case .starter: "Starter"
        case .fermentation: "Fermentazione"
        case .bakerMath: "Baker's math"
        case .troubleshooting: "Problemi comuni"
        }
    }
}

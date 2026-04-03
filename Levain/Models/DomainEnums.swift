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
        case .dueSoon: "Attenzione"
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
    case none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sourdough: "Lievito madre"
        case .dryYeast: "Lievito di birra secco"
        case .freshYeast: "Lievito di birra fresco"
        case .none: "Nessun lievito"
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
        case .bulk: "Bulk fermentation"
        case .fold: "Pieghe"
        case .preshape: "Preforma"
        case .benchRest: "Bench rest"
        case .shape: "Formatura"
        case .proof: "Appretto"
        case .coldRetard: "Cold retard"
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

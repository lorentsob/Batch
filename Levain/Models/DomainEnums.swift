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
        case .roomTemperature: "Temperatura ambiente"
        case .fridge: "Frigo"
        }
    }
}

enum BakeType: String, CaseIterable, Codable, Identifiable {
    case countryLoaf
    case focaccia
    case panBrioche
    case pizza
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .countryLoaf: "Pagnotta"
        case .focaccia: "Focaccia"
        case .panBrioche: "Pan brioche"
        case .pizza: "Pizza"
        case .custom: "Personalizzato"
        }
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
        case .custom: "Step personalizzato"
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
        case .troubleshooting: "Troubleshooting"
        }
    }
}


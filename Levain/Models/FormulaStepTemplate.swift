import Foundation

struct FormulaStepTemplate: Codable, Hashable, Identifiable {
    var id: UUID
    var typeRaw: String
    var name: String
    var details: String
    var durationMinutes: Int
    var reminderOffsetMinutes: Int
    var temperatureRange: String
    var volumeTarget: String
    var notes: String
    /// Step-specific ingredient lines (e.g. "500 g farina", "400 g acqua").
    /// Empty array means no ingredients are associated with this step.
    var ingredients: [String]

    enum CodingKeys: String, CodingKey {
        case id, typeRaw, name, details, durationMinutes, reminderOffsetMinutes
        case temperatureRange, volumeTarget, notes, ingredients
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        typeRaw = try container.decode(String.self, forKey: .typeRaw)
        name = try container.decode(String.self, forKey: .name)
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        reminderOffsetMinutes = try container.decodeIfPresent(Int.self, forKey: .reminderOffsetMinutes) ?? 0
        temperatureRange = try container.decodeIfPresent(String.self, forKey: .temperatureRange) ?? ""
        volumeTarget = try container.decodeIfPresent(String.self, forKey: .volumeTarget) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients) ?? []
    }

    init(
        id: UUID = UUID(),
        type: BakeStepType,
        name: String,
        details: String = "",
        durationMinutes: Int,
        reminderOffsetMinutes: Int = 0,
        temperatureRange: String = "",
        volumeTarget: String = "",
        notes: String = "",
        ingredients: [String] = []
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.name = name
        self.details = details
        self.durationMinutes = durationMinutes
        self.reminderOffsetMinutes = reminderOffsetMinutes
        self.temperatureRange = temperatureRange
        self.volumeTarget = volumeTarget
        self.notes = notes
        self.ingredients = ingredients
    }

    var type: BakeStepType {
        get { BakeStepType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    static let defaultBreadSteps: [FormulaStepTemplate] = [
        FormulaStepTemplate(type: .starterRefresh, name: "Rinfresca starter", details: "Usa lo starter quando è al picco o quasi", durationMinutes: 120, reminderOffsetMinutes: 15),
        FormulaStepTemplate(type: .autolysis, name: "Autolisi", details: "Farina e acqua a riposo", durationMinutes: 30),
        FormulaStepTemplate(type: .mix, name: "Impasto", details: "Inserisci starter e sale", durationMinutes: 20),
        FormulaStepTemplate(type: .bulk, name: "Bulk fermentation", details: "Con pieghe nella prima fase", durationMinutes: 240, reminderOffsetMinutes: 30, temperatureRange: "24-26 C", volumeTarget: "+40%"),
        FormulaStepTemplate(type: .shape, name: "Formatura", details: "Tensione finale", durationMinutes: 25),
        FormulaStepTemplate(type: .proof, name: "Appretto", details: "Seconda lievitazione", durationMinutes: 120, reminderOffsetMinutes: 20),
        FormulaStepTemplate(type: .bake, name: "Cottura", details: "Forno ben caldo", durationMinutes: 45, reminderOffsetMinutes: 10)
    ]

    static let defaultPizzaSteps: [FormulaStepTemplate] = [
        FormulaStepTemplate(type: .starterRefresh, name: "Rinfresca starter", details: "Usa lo starter quando è al picco o quasi", durationMinutes: 240, reminderOffsetMinutes: 15),
        FormulaStepTemplate(type: .mix, name: "Impasto", details: "Puntamento in massa", durationMinutes: 20),
        FormulaStepTemplate(type: .bulk, name: "Puntata", details: "Lievitazione in massa", durationMinutes: 120, temperatureRange: "24 C"),
        FormulaStepTemplate(type: .shape, name: "Staglio", details: "Formatura dei panetti", durationMinutes: 15),
        FormulaStepTemplate(type: .proof, name: "Appretto", details: "Maturazione in cassetta", durationMinutes: 300, temperatureRange: "20-22 C"),
        FormulaStepTemplate(type: .bake, name: "Cottura", details: "Alte temperature", durationMinutes: 5, reminderOffsetMinutes: 2)
    ]
}


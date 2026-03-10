import SwiftData
import SwiftUI

struct FormulaEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let formula: RecipeFormula?

    @State private var name: String
    @State private var type: BakeType
    @State private var totalFlourWeight: Double
    @State private var totalWaterWeight: Double
    @State private var saltWeight: Double
    @State private var inoculationPercent: Double
    @State private var servings: Int
    @State private var flourMix: String
    @State private var notes: String
    @State private var steps: [FormulaStepTemplate]
    @State private var editingStep: FormulaStepTemplate?

    init(formula: RecipeFormula?) {
        self.formula = formula
        _name = State(initialValue: formula?.name ?? "")
        _type = State(initialValue: formula?.type ?? .countryLoaf)
        _totalFlourWeight = State(initialValue: formula?.totalFlourWeight ?? 1000)
        _totalWaterWeight = State(initialValue: formula?.totalWaterWeight ?? 720)
        _saltWeight = State(initialValue: formula?.saltWeight ?? 22)
        _inoculationPercent = State(initialValue: formula?.inoculationPercent ?? 18)
        _servings = State(initialValue: formula?.servings ?? 2)
        _flourMix = State(initialValue: formula?.flourMix ?? "")
        _notes = State(initialValue: formula?.notes ?? "")
        _steps = State(initialValue: formula?.defaultSteps ?? FormulaStepTemplate.defaultBreadSteps)
    }

    private var formHydrationPercent: Double {
        totalFlourWeight > 0 ? (totalWaterWeight / totalFlourWeight) * 100 : 0
    }
    private var formSaltPercent: Double {
        totalFlourWeight > 0 ? (saltWeight / totalFlourWeight) * 100 : 0
    }
    private var formTotalDoughWeight: Double {
        totalFlourWeight + totalWaterWeight + saltWeight + (totalFlourWeight * inoculationPercent / 100)
    }

    var body: some View {
        Form {
            Section("Identita") {
                TextField("Nome formula", text: $name)
                Picker("Tipo", selection: $type) {
                    ForEach(BakeType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Stepper("Pezzi: \(servings)", value: $servings, in: 1...8)
            }

            Section("Ingredienti") {
                NumericField(title: "Farina totale (g)", value: $totalFlourWeight)
                NumericField(title: "Acqua totale (g)", value: $totalWaterWeight)
                NumericField(title: "Sale (g)", value: $saltWeight)
                NumericField(title: "Inoculo (%)", value: $inoculationPercent)
                TextField("Mix farine", text: $flourMix, axis: .vertical)
            }
            
            Section("Statistiche") {
                HStack {
                    Text("Idratazione")
                    Spacer()
                    Text("\(Int(formHydrationPercent.rounded()))%")
                        .foregroundStyle(Theme.muted)
                }
                HStack {
                    Text("Sale")
                    Spacer()
                    Text("\(String(format: "%.1f", formSaltPercent))%")
                        .foregroundStyle(Theme.muted)
                }
                HStack {
                    Text("Peso impasto")
                    Spacer()
                    Text("\(Int(formTotalDoughWeight.rounded())) g")
                        .foregroundStyle(Theme.muted)
                }
            }

            Section("Step di default") {
                if steps.isEmpty {
                    Text("Aggiungi almeno uno step.")
                        .foregroundStyle(Theme.muted)
                }

                ForEach(steps) { step in
                    Button {
                        editingStep = step
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.name)
                                    .foregroundStyle(Theme.ink)
                                Text("\(step.type.title) · \(DateFormattingService.duration(minutes: step.durationMinutes))")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onMove(perform: moveSteps)
                .onDelete(perform: deleteSteps)

                Button {
                    editingStep = FormulaStepTemplate(
                        type: .custom,
                        name: "Nuovo step",
                        durationMinutes: 20
                    )
                } label: {
                    Label("Aggiungi step", systemImage: "plus")
                }
            }

            Section("Note") {
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(4...8)
            }
        }
        .navigationTitle(formula == nil ? "Nuova formula" : "Modifica formula")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || steps.isEmpty)
            }
        }
        .sheet(item: $editingStep) { step in
            NavigationStack {
                FormulaStepEditorView(step: step) { updatedStep in
                    upsertStep(updatedStep)
                }
            }
        }
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteSteps(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
    }

    private func upsertStep(_ step: FormulaStepTemplate) {
        if let index = steps.firstIndex(where: { $0.id == step.id }) {
            steps[index] = step
        } else {
            steps.append(step)
        }
    }

    private func save() {
        if let formula {
            formula.name = name
            formula.type = type
            formula.totalFlourWeight = totalFlourWeight
            formula.totalWaterWeight = totalWaterWeight
            formula.saltWeight = saltWeight
            formula.inoculationPercent = inoculationPercent
            formula.servings = servings
            formula.flourMix = flourMix
            formula.notes = notes
            formula.defaultSteps = steps
            formula.recalculateDerivedValues()
        } else {
            let newFormula = RecipeFormula(
                name: name,
                type: type,
                totalFlourWeight: totalFlourWeight,
                totalWaterWeight: totalWaterWeight,
                saltWeight: saltWeight,
                inoculationPercent: inoculationPercent,
                servings: servings,
                notes: notes,
                flourMix: flourMix,
                defaultSteps: steps
            )
            modelContext.insert(newFormula)
        }

        try? modelContext.save()
        dismiss()
    }
}

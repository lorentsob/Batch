import SwiftData
import SwiftUI

struct FormulaEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let formula: RecipeFormula?

    @State private var name: String
    @State private var type: RecipeCategory
    @State private var totalFlourWeight: Double
    @State private var totalWaterWeight: Double
    @State private var saltWeight: Double
    @State private var inoculationPercent: Double
    @State private var servings: Int
    @State private var yeastType: YeastType
    @State private var flours: [FlourSelection]
    @State private var notes: String
    @State private var steps: [FormulaStepTemplate]
    @State private var editingStep: FormulaStepTemplate?

    init(formula: RecipeFormula?) {
        self.formula = formula
        _name = State(initialValue: formula?.name ?? "")
        _type = State(initialValue: formula?.type ?? .pane)
        _totalFlourWeight = State(initialValue: formula?.totalFlourWeight ?? 1000)
        _totalWaterWeight = State(initialValue: formula?.totalWaterWeight ?? 720)
        _saltWeight = State(initialValue: formula?.saltWeight ?? 22)
        _inoculationPercent = State(initialValue: formula?.inoculationPercent ?? 18)
        _servings = State(initialValue: formula?.servings ?? 2)
        _yeastType = State(initialValue: formula?.yeastType ?? .sourdough)
        _flours = State(initialValue: formula?.selectedFlours ?? [])
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
            Section("Identità") {
                LabeledContent("Nome della ricetta") {
                    TextField("es. Pane di Segale", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                Picker("Tipo", selection: $type) {
                    ForEach(RecipeCategory.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Stepper("Porzioni: \(servings)", value: $servings, in: 1...12)
                    // Extra trailing inset so the stepper control doesn't kiss the card edge
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 24))
            }

            Section("Ingredienti") {
                NumericField(title: "Farina totale (g)", value: $totalFlourWeight)
                NumericField(title: "Acqua totale (g)", value: $totalWaterWeight)
                NumericField(title: "Sale (g)", value: $saltWeight)
                Picker("Agente lievitante", selection: $yeastType) {
                    ForEach(YeastType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                NumericField(title: "Inoculo/Lievito (%)", value: $inoculationPercent)
            }

            Section("Mix Farine") {
                ForEach($flours) { $flour in
                    NavigationLink(destination: FlourSelectionEditorView(flour: $flour)) {
                        HStack {
                            Text(flour.displayName)
                            Spacer()
                            Text("\(flour.percentage, specifier: "%.1f")%")
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }
                .onDelete { indices in
                    flours.remove(atOffsets: indices)
                }
                Button {
                    flours.append(FlourSelection(categoryRaw: FlourCategory.strong.rawValue, customName: "", percentage: 100))
                } label: {
                    Label("Aggiungi farina", systemImage: "plus")
                }
                
                let sum = flours.reduce(0) { $0 + $1.percentage }
                if sum != 100 && !flours.isEmpty {
                    Text("Attenzione: il totale è \(sum, specifier: "%.1f")% (dovrebbe essere 100%)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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

            Section("Preparazione") {
                if steps.isEmpty {
                    Text("Aggiungi almeno una fase.")
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
                        name: "Nuova fase",
                        durationMinutes: 20
                    )
                } label: {
                    Label("Aggiungi fase", systemImage: "plus")
                }
            }

            Section {
                LabeledContent("Note") {
                    TextField("Dettagli o consigli", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("Note")
            }
        }
        .navigationTitle(formula == nil ? "Nuova ricetta" : "Modifica ricetta")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
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
            formula.yeastType = yeastType
            formula.selectedFlours = flours
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
                flourMix: "",
                yeastType: yeastType,
                flours: flours,
                defaultSteps: steps
            )
            modelContext.insert(newFormula)
        }

        try? modelContext.save()
        dismiss()
    }
}

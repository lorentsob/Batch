import SwiftData
import SwiftUI

struct BakeCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]
    @Query(sort: \Starter.name) private var starters: [Starter]

    let preselectedFormula: RecipeFormula?

    @State private var selectedFormulaID: UUID?
    @State private var selectedStarterID: UUID?
    @State private var name: String
    @State private var targetBakeDateTime: Date
    @State private var notes: String

    init(preselectedFormula: RecipeFormula?) {
        self.preselectedFormula = preselectedFormula
        _selectedFormulaID = State(initialValue: preselectedFormula?.id)
        _selectedStarterID = State(initialValue: nil)
        _name = State(initialValue: preselectedFormula?.name ?? "")
        _targetBakeDateTime = State(initialValue: .now.adding(minutes: 12 * 60))
        _notes = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Formula") {
                    Picker("Formula", selection: $selectedFormulaID) {
                        Text("Seleziona").tag(Optional<UUID>.none)
                        ForEach(formulas) { formula in
                            Text(formula.name).tag(Optional(formula.id))
                        }
                    }
                    .disabled(preselectedFormula != nil)
                    .onChange(of: selectedFormulaID) { _, newID in
                        if let selected = formulas.first(where: { $0.id == newID }), name.isEmpty {
                            name = selected.name
                        }
                    }

                    if let formula = selectedFormula {
                        Text("\(formula.type.title) · \(Int(formula.hydrationPercent.rounded()))% idratazione")
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }
                }

                Section("Pianificazione") {
                    TextField("Nome bake", text: $name)
                    DatePicker("Target cottura", selection: $targetBakeDateTime)
                }

                DisclosureGroup("Avanzate & Starter") {
                    Picker("Starter", selection: $selectedStarterID) {
                        Text("Nessuno").tag(Optional<UUID>.none)
                        ForEach(starters) { starter in
                            Text(starter.name).tag(Optional(starter.id))
                        }
                    }

                    TextField("Note", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Nuovo bake")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crea") { save() }
                        .disabled(selectedFormula == nil || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var selectedFormula: RecipeFormula? {
        formulas.first(where: { $0.id == selectedFormulaID }) ?? preselectedFormula
    }

    private var selectedStarter: Starter? {
        starters.first(where: { $0.id == selectedStarterID })
    }

    private func save() {
        guard let formula = selectedFormula else { return }

        let bake = BakeScheduler.generateBake(
            name: name,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: selectedStarter,
            notes: notes
        )
        modelContext.insert(bake)
        bake.steps.forEach { modelContext.insert($0) }
        try? modelContext.save()

        Task {
            await environment.notificationService.syncNotifications(for: bake)
        }
        
        dismiss()
        router.openBake(bake.id)
    }
}

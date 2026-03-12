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
                Section("Ricetta") {
                    Picker("Ricetta", selection: $selectedFormulaID) {
                        formulaPickerOptions
                    }
                    .accessibilityIdentifier("BakeRecipePicker")
                    .disabled(preselectedFormula != nil)
                    .onChange(of: selectedFormulaID) { _, newID in
                        if let selected = allAvailableFormulas.first(where: { $0.id == newID }), name.isEmpty {
                            name = selected.name
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Template rapidi")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                        Text("Le ricette predefinite restano sempre disponibili anche se non hai ancora salvato formule personalizzate.")
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }

                    if preselectedFormula == nil {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(RecipeTemplates.all) { template in
                                    Button(template.name) {
                                        selectedFormulaID = template.id
                                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            name = template.name
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(selectedFormulaID == template.id ? Theme.accent : Theme.muted)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .accessibilityIdentifier("BakeTemplateScroller")
                    }

                    if let formula = selectedFormula {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(formula.type.title) · \(Int(formula.hydrationPercent.rounded()))% idratazione")
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                            Text("\(formula.yeastType.title) al \(String(format: "%.1f", formula.inoculationPercent))%")
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }

                Section("Pianificazione") {
                    TextField("Nome del bake (opzionale)", text: $name)
                        .accessibilityIdentifier("BakeNameField")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quando vuoi sfornare")
                            .font(.subheadline)
                        DatePicker(
                            "",
                            selection: $targetBakeDateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }
                }

                if let formula = selectedFormula, formula.yeastType == .sourdough {
                    Section("Starter") {
                        Picker("Starter usato", selection: $selectedStarterID) {
                            Text("Nessuno").tag(Optional<UUID>.none)
                            ForEach(starters) { starter in
                                Text(starter.name).tag(Optional(starter.id))
                            }
                        }
                    }
                }

                Section("Avanzate") {
                    TextField("Note aggiuntive", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
        }
        .navigationTitle("Nuovo bake")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crea") { save() }
                        .disabled(selectedFormula == nil)
                }
            }
        }
    }

    private var formulaPickerOptions: some View {
        Group {
            Text("Seleziona").tag(Optional<UUID>.none)

            if formulas.isEmpty == false {
                Section("Le tue ricette") {
                    ForEach(formulas) { formula in
                        Text(formula.name).tag(Optional(formula.id))
                    }
                }
            }

            Section("Template rapidi") {
                ForEach(RecipeTemplates.all) { template in
                    Text(template.name).tag(Optional(template.id))
                }
            }
        }
    }

    private var allAvailableFormulas: [RecipeFormula] {
        formulas + RecipeTemplates.all
    }

    private var selectedFormula: RecipeFormula? {
        allAvailableFormulas.first(where: { $0.id == selectedFormulaID }) ?? preselectedFormula
    }

    private var selectedStarter: Starter? {
        starters.first(where: { $0.id == selectedStarterID })
    }

    private func save() {
        guard let formula = selectedFormula else { return }
        let resolvedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Determine if it's a template (not in SwiftData)
        let isTemplate = RecipeTemplates.all.contains(where: { $0.id == formula.id })

        let bake = BakeScheduler.generateBake(
            name: resolvedName,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: selectedStarter,
            notes: notes
        )
        
        if isTemplate {
            // Decouple from formula so it's not saved to the user's recipe list
            bake.formula = nil
        }

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

import SwiftData
import SwiftUI

struct BakesView: View {
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?
    @State private var showingBakeEditor = false
    @State private var preselectedFormula: RecipeFormula?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Impasti e formule")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Qui gestisci le formule riutilizzabili e i bake in corso o pianificati.")
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 12) {
                        StateBadge(text: "\(bakes.count) bake")
                        StateBadge(text: "\(formulas.count) formule")
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bake")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            preselectedFormula = formulas.first
                            showingBakeEditor = true
                        } label: {
                            Label("Nuovo bake", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.accent)
                        .disabled(formulas.isEmpty)
                    }

                    if bakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun bake pianificato",
                            message: "Crea prima una formula, poi genera un bake con la schedulazione backward.",
                            actionTitle: "Nuova formula"
                        ) {
                            editingFormula = nil
                            showingFormulaEditor = true
                        }
                    } else {
                        ForEach(bakes) { bake in
                            NavigationLink(value: BakesRoute.bake(bake.id)) {
                                SectionCard {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(bake.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.ink)
                                            Text("\(bake.type.title) · target \(DateFormattingService.dayTime(bake.targetBakeDateTime))")
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                            if let step = bake.activeStep {
                                                Text("Prossimo step: \(step.displayName)")
                                                    .font(.footnote)
                                                    .foregroundStyle(Theme.muted)
                                            }
                                        }
                                        Spacer()
                                        StateBadge(text: bake.derivedStatus.title)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Formule")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            editingFormula = nil
                            showingFormulaEditor = true
                        } label: {
                            Label("Nuova formula", systemImage: "square.and.pencil")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent)
                    }

                    if formulas.isEmpty {
                        EmptyStateView(
                            title: "Nessuna formula salvata",
                            message: "Le formule sono la base riutilizzabile da cui generare i bake.",
                            actionTitle: "Crea formula"
                        ) {
                            editingFormula = nil
                            showingFormulaEditor = true
                        }
                    } else {
                        ForEach(formulas) { formula in
                            NavigationLink(value: BakesRoute.formula(formula.id)) {
                                SectionCard {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(formula.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.ink)
                                            Text("\(formula.type.title) · \(Int(formula.hydrationPercent.rounded()))% idratazione")
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                            Text("\(formula.defaultSteps.count) step di default")
                                                .font(.footnote)
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        StateBadge(text: "\(formula.servings) pezz.")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Modifica") {
                                    editingFormula = formula
                                    showingFormulaEditor = true
                                }
                                Button("Nuovo bake") {
                                    preselectedFormula = formula
                                    showingBakeEditor = true
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Impasti")
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: editingFormula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeEditorView(preselectedFormula: preselectedFormula)
            }
        }
    }
}

struct FormulaDetailView: View {
    let formula: RecipeFormula

    @State private var showingEditor = false
    @State private var showingBakeEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text(formula.name)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text(formula.type.title)
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 12) {
                        StateBadge(text: "\(Int(formula.hydrationPercent.rounded()))% idratazione")
                        StateBadge(text: "\(Int(formula.inoculationPercent.rounded()))% inoculo")
                    }
                }

                SectionCard {
                    Text("Baker's math")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    FormulaStatRow(label: "Farina totale", value: "\(Int(formula.totalFlourWeight)) g")
                    FormulaStatRow(label: "Acqua totale", value: "\(Int(formula.totalWaterWeight)) g")
                    FormulaStatRow(label: "Sale", value: "\(Int(formula.saltWeight)) g · \(Int(formula.saltPercent.rounded()))%")
                    FormulaStatRow(label: "Peso impasto", value: "\(Int(formula.totalDoughWeight.rounded())) g")
                    FormulaStatRow(label: "Servings", value: "\(formula.servings)")
                    if formula.flourMix.isEmpty == false {
                        FormulaStatRow(label: "Mix farine", value: formula.flourMix)
                    }
                    if formula.notes.isEmpty == false {
                        FormulaStatRow(label: "Note", value: formula.notes)
                    }
                }

                SectionCard {
                    Text("Step di default")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    ForEach(formula.defaultSteps) { step in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(step.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text(DateFormattingService.duration(minutes: step.durationMinutes))
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                            if step.details.isEmpty == false {
                                Text(step.details)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Formula")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Modifica") {
                    showingEditor = true
                }
                Button("Nuovo bake") {
                    showingBakeEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                FormulaEditorView(formula: formula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeEditorView(preselectedFormula: formula)
            }
        }
    }
}

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

struct FormulaStepEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let initialStep: FormulaStepTemplate
    let onSave: (FormulaStepTemplate) -> Void

    @State private var type: BakeStepType
    @State private var name: String
    @State private var details: String
    @State private var durationMinutes: Int
    @State private var reminderOffsetMinutes: Int
    @State private var temperatureRange: String
    @State private var volumeTarget: String
    @State private var notes: String

    init(step: FormulaStepTemplate, onSave: @escaping (FormulaStepTemplate) -> Void) {
        initialStep = step
        self.onSave = onSave
        _type = State(initialValue: step.type)
        _name = State(initialValue: step.name)
        _details = State(initialValue: step.details)
        _durationMinutes = State(initialValue: step.durationMinutes)
        _reminderOffsetMinutes = State(initialValue: step.reminderOffsetMinutes)
        _temperatureRange = State(initialValue: step.temperatureRange)
        _volumeTarget = State(initialValue: step.volumeTarget)
        _notes = State(initialValue: step.notes)
    }

    var body: some View {
        Form {
            Section("Step") {
                Picker("Tipo", selection: $type) {
                    ForEach(BakeStepType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                TextField("Nome", text: $name)
                TextField("Descrizione", text: $details, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Timing") {
                Stepper("Durata: \(DateFormattingService.duration(minutes: durationMinutes))", value: $durationMinutes, in: 5...24 * 60, step: 5)
                Stepper("Reminder: \(reminderOffsetMinutes) min prima", value: $reminderOffsetMinutes, in: 0...180, step: 5)
            }

            Section("Target qualitativi") {
                TextField("Temperatura", text: $temperatureRange)
                TextField("Target volume", text: $volumeTarget)
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle("Step formula")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") {
                    onSave(
                        FormulaStepTemplate(
                            id: initialStep.id,
                            type: type,
                            name: name,
                            details: details,
                            durationMinutes: durationMinutes,
                            reminderOffsetMinutes: reminderOffsetMinutes,
                            temperatureRange: temperatureRange,
                            volumeTarget: volumeTarget,
                            notes: notes
                        )
                    )
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct BakeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

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
        Form {
            Section("Formula") {
                Picker("Formula", selection: $selectedFormulaID) {
                    Text("Seleziona").tag(Optional<UUID>.none)
                    ForEach(formulas) { formula in
                        Text(formula.name).tag(Optional(formula.id))
                    }
                }
                .disabled(preselectedFormula != nil)

                if let formula = selectedFormula {
                    Text("\(formula.type.title) · \(Int(formula.hydrationPercent.rounded()))% idratazione")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
            }

            Section("Pianificazione") {
                TextField("Nome bake", text: $name)
                DatePicker("Target cottura", selection: $targetBakeDateTime)
                Picker("Starter", selection: $selectedStarterID) {
                    Text("Nessuno").tag(Optional<UUID>.none)
                    ForEach(starters) { starter in
                        Text(starter.name).tag(Optional(starter.id))
                    }
                }
            }

            Section("Note") {
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
                Button("Genera") { save() }
                    .disabled(selectedFormula == nil)
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
    }
}

struct BakeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let bake: Bake

    @State private var shiftingStep: BakeStep?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text(bake.name)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)

                    Text("\(bake.type.title) · target \(DateFormattingService.dayTime(bake.targetBakeDateTime))")
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 12) {
                        StateBadge(text: bake.derivedStatus.title)
                        if let formula = bake.formula {
                            Button {
                                router.openFormula(formula.id)
                            } label: {
                                Text(formula.name)
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.accent)
                        }
                    }

                    if let starter = bake.starter {
                        Button {
                            router.openStarter(starter.id)
                        } label: {
                            Label(starter.name, systemImage: "drop.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.accent)
                    }

                    if bake.notes.isEmpty == false {
                        Text(bake.notes)
                            .foregroundStyle(Theme.muted)
                    }
                }

                ForEach(bake.sortedSteps) { step in
                    SectionCard {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(step.displayName)
                                    .font(.headline)
                                    .foregroundStyle(Theme.ink)
                                Text("\(DateFormattingService.dayTime(step.plannedStart)) · \(DateFormattingService.duration(minutes: step.plannedDurationMinutes))")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                                if step.descriptionText.isEmpty == false {
                                    Text(step.descriptionText)
                                        .font(.footnote)
                                        .foregroundStyle(Theme.muted)
                                }
                            }
                            Spacer()
                            StateBadge(text: stepBadge(step))
                        }

                        if step.status == .running {
                            StepTimerView(step: step)
                        }

                        if step.temperatureRange.isEmpty == false || step.volumeTarget.isEmpty == false {
                            VStack(alignment: .leading, spacing: 6) {
                                if step.temperatureRange.isEmpty == false {
                                    Text("Temperatura: \(step.temperatureRange)")
                                        .font(.footnote)
                                        .foregroundStyle(Theme.muted)
                                }
                                if step.volumeTarget.isEmpty == false {
                                    Text("Target volume: \(step.volumeTarget)")
                                        .font(.footnote)
                                        .foregroundStyle(Theme.muted)
                                }
                            }
                        }

                        HStack {
                            if step.status == .pending {
                                Button("Start") { start(step) }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.accent)
                            } else if step.status == .running {
                                Button("Complete") { complete(step) }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.success)
                            }

                            if step.isTerminal == false {
                                Button("Sposta timeline") {
                                    shiftingStep = step
                                }
                                .buttonStyle(.bordered)
                                .tint(Theme.warning)

                                Button("Salta") { skip(step) }
                                    .buttonStyle(.bordered)
                            }
                        }

                        TipGroupView(items: environment.knowledgeLibrary.tips(for: step.type)) { id in
                            router.openKnowledge(id)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Bake")
        .sheet(item: $shiftingStep) { step in
            NavigationStack {
                ShiftTimelineView(bake: bake, anchorStep: step)
            }
        }
    }

    private func stepBadge(_ step: BakeStep) -> String {
        if step.status == .running { return "In corso" }
        if step.isOverdue() { return "In ritardo" }
        return step.status.title
    }

    private func start(_ step: BakeStep) {
        step.start()
        persistAndSync()
    }

    private func complete(_ step: BakeStep) {
        step.complete()
        persistAndSync()
    }

    private func skip(_ step: BakeStep) {
        step.skip()
        persistAndSync()
    }

    private func persistAndSync() {
        try? modelContext.save()
        Task {
            await environment.notificationService.syncNotifications(for: bake)
        }
    }
}

struct ShiftTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let bake: Bake
    let anchorStep: BakeStep

    @State private var shiftMinutes = 15

    var body: some View {
        Form {
            Section("Step ancora") {
                Text(anchorStep.displayName)
                Text("Sposterai solo gli step futuri non completati.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }

            Section("Offset") {
                Stepper("Shift: \(shiftMinutes) min", value: $shiftMinutes, in: -120...240, step: 5)

                HStack {
                    ForEach([-30, -15, 15, 30, 60], id: \.self) { option in
                        Button(option > 0 ? "+\(option)" : "\(option)") {
                            shiftMinutes = option
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("Shift timeline")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Applica") {
                    BakeScheduler.shiftFutureSteps(in: bake, after: anchorStep, by: shiftMinutes)
                    try? modelContext.save()
                    Task {
                        await environment.notificationService.syncNotifications(for: bake)
                    }
                    dismiss()
                }
            }
        }
    }
}

struct StepTimerView: View {
    let step: BakeStep

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let elapsed = max(0, Int(context.date.timeIntervalSince(step.actualStart ?? step.plannedStart)) / 60)
            let remaining = max(0, step.plannedDurationMinutes - elapsed)

            VStack(alignment: .leading, spacing: 6) {
                Text("Timer attivo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("Trascorso \(DateFormattingService.duration(minutes: elapsed)) · residuo \(DateFormattingService.duration(minutes: remaining))")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.background.opacity(0.8))
            )
        }
    }
}

private struct FormulaStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct NumericField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        TextField(title, value: $value, format: .number)
            .keyboardType(.decimalPad)
    }
}

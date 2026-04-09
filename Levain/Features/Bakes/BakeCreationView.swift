import SwiftData
import SwiftUI

struct BakeCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]
    @Query(filter: #Predicate<Starter> { $0.archivedAt == nil }, sort: \Starter.name) private var starters: [Starter]

    let preselectedFormula: RecipeFormula?
    let shouldPreselectFirstAvailable: Bool
    private let systemFormulas: [SystemFormula]

    @State private var selectedFormulaID: UUID?
    @State private var selectedStarterID: UUID?
    @State private var name: String
    @State private var targetBakeDateTime: Date
    @State private var notes: String
    @State private var showingBakeDatePicker = false
    @State private var showingBakeTimePicker = false

    // Fonte lievito: sourdough (starter) o commerciale
    @State private var useCommercialYeast = false
    @State private var commercialYeastType: YeastType = .instantYeast
    @State private var yeastProfile: YeastProfile = .medium

    init(preselectedFormula: RecipeFormula?, shouldPreselectFirstAvailable: Bool = false) {
        self.preselectedFormula = preselectedFormula
        self.shouldPreselectFirstAvailable = shouldPreselectFirstAvailable
        self.systemFormulas = SystemFormulaLoader.loadSystemFormulas()

        // If should preselect and no user formula provided, use first available (user or system)
        let initialFormulaID: UUID?
        if let preselectedFormula {
            initialFormulaID = preselectedFormula.id
        } else if shouldPreselectFirstAvailable {
            // Will be set in onAppear once formulas query is populated
            initialFormulaID = nil
        } else {
            initialFormulaID = nil
        }

        _selectedFormulaID = State(initialValue: initialFormulaID)
        _selectedStarterID = State(initialValue: nil)
        _name = State(initialValue: preselectedFormula?.name ?? "")
        _targetBakeDateTime = State(initialValue: .now.adding(minutes: 12 * 60))
        _notes = State(initialValue: "")
    }

    var body: some View {
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

                if let formula = selectedFormulaChoice {
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
                TextField("Nome impasto (opzionale)", text: $name)
                    .accessibilityIdentifier("BakeNameField")

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quando vuoi sfornare")
                        .font(.subheadline)

                    HStack(spacing: 10) {
                        Button {
                            showingBakeDatePicker = true
                        } label: {
                            BakeSelectionChip(title: targetBakeDateLabel, systemImage: "calendar")
                        }
                        .buttonStyle(.plain)

                        Button {
                            showingBakeTimePicker = true
                        } label: {
                            BakeSelectionChip(title: targetBakeTimeLabel, systemImage: "clock")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            if selectedFormulaChoice != nil {
                yeastSourceSection
            }

            Section("Avanzate") {
                TextField("Note aggiuntive", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
        .navigationTitle("Nuovo impasto")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Crea") { save() }
                    .disabled(selectedFormulaChoice == nil)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.Surface.app)
        .sheet(isPresented: $showingBakeDatePicker) {
            BakeDatePickerSheet(selection: targetBakeDateBinding)
        }
        .sheet(isPresented: $showingBakeTimePicker) {
            BakeTimePickerSheet(selection: targetBakeTimeBinding)
        }
        .onAppear {
            // Preselect first available formula if requested and nothing is selected
            if shouldPreselectFirstAvailable, selectedFormulaID == nil {
                if let firstFormula = allAvailableFormulas.first {
                    selectedFormulaID = firstFormula.id
                    if name.isEmpty {
                        name = firstFormula.name
                    }
                }
            }
        }
    }

    // MARK: - Yeast source section

    @ViewBuilder
    private var yeastSourceSection: some View {
        let formula = selectedFormulaChoice
        // Mostriamo sempre la sezione fonte lievito.
        // Se la ricetta è già commerciale, blocchiamo sul commerciale.
        let formulaIsCommercial = formula?.yeastType.isCommercial ?? false

        Section {
            // Selettore sourdough vs commerciale (solo se la ricetta è sourdough)
            if !(formulaIsCommercial) {
                Picker("Lievito", selection: $useCommercialYeast) {
                    Text("Lievito madre").tag(false)
                    Text("Commerciali").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: useCommercialYeast) { _, _ in
                    if !useCommercialYeast { selectedStarterID = nil }
                }
            }

            if !useCommercialYeast && !formulaIsCommercial {
                // --- Sourdough: picker starter personali ---
                Picker("Starter usato", selection: $selectedStarterID) {
                    Text("Nessuno").tag(Optional<UUID>.none)
                    ForEach(starters) { starter in
                        Text(starter.name).tag(Optional(starter.id))
                    }
                }
            } else {
                // --- Commerciale: tipo lievito + profilo tempi ---
                Picker("Tipo lievito", selection: $commercialYeastType) {
                    ForEach(YeastType.commercialCases) { type in
                        Text(type.title).tag(type)
                    }
                }

                Picker("Profilo fermentazione", selection: $yeastProfile) {
                    ForEach(YeastProfile.allCases) { profile in
                        Text(profile.title).tag(profile)
                    }
                }
            }
        } header: {
            Text((!useCommercialYeast && !formulaIsCommercial) ? "Starter" : "Lievito di birra")
        }

        // Preview ricalcolo (solo quando si usa lievito commerciale)
        if useCommercialYeast || formulaIsCommercial, let conversion = computedYeastConversion {
            Section("Ricalcolo automatico") {
                YeastConversionPreviewView(
                    conversion: conversion,
                    yeastType: formulaIsCommercial ? (formula?.yeastType ?? commercialYeastType) : commercialYeastType,
                    profile: yeastProfile
                )
            }
        }
    }

    /// Calcola la conversione in tempo reale basandosi sulla formula selezionata e sulle scelte UI.
    private var computedYeastConversion: YeastConversionResult? {
        guard let formula = selectedFormulaChoice else { return nil }
        let isCommercial = useCommercialYeast || formula.yeastType.isCommercial
        guard isCommercial else { return nil }

        let targetType = formula.yeastType.isCommercial ? formula.yeastType : commercialYeastType

        // Se la ricetta è già sourdough (e l'utente vuole commerciale), scomponiamo lo starter
        if formula.yeastType == .sourdough {
            let starterWeight = formula.inoculationPercent / 100 * formula.totalFlourWeight
            // Assumiamo starter al 100% se non abbiamo uno starter selezionato
            let hydration = selectedStarter?.hydration ?? 100.0
            return YeastConversionService.convert(
                formulaFlour: formula.totalFlourWeight,
                formulaWater: formula.totalWaterWeight,
                starterWeight: starterWeight,
                starterHydration: hydration,
                targetYeastType: targetType,
                profile: yeastProfile
            )
        } else {
            // Ricetta già commerciale: calcoliamo solo la quantità lievito per il profilo
            return YeastConversionService.calculateYeast(
                flourWeight: formula.totalFlourWeight,
                targetYeastType: targetType,
                profile: yeastProfile
            )
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

            if systemFormulas.isEmpty == false {
                Section("Tutte le ricette") {
                    ForEach(systemFormulas) { formula in
                        Text(formula.name).tag(Optional(formula.id))
                    }
                }
            }
        }
    }

    private var allAvailableFormulas: [FormulaChoice] {
        formulas.map(FormulaChoice.user) + systemFormulas.map(FormulaChoice.system)
    }

    private var selectedFormulaChoice: FormulaChoice? {
        if let selectedFormulaID {
            if let selected = allAvailableFormulas.first(where: { $0.id == selectedFormulaID }) {
                return selected
            }
            if let preselectedFormula, preselectedFormula.id == selectedFormulaID {
                return .user(preselectedFormula)
            }
            return nil
        }

        return preselectedFormula.map(FormulaChoice.user)
    }

    private var selectedStarter: Starter? {
        starters.first(where: { $0.id == selectedStarterID })
    }

    private var targetBakeDateLabel: String {
        Self.targetDateFormatter.string(from: targetBakeDateTime)
    }

    private var targetBakeTimeLabel: String {
        DateFormattingService.time(targetBakeDateTime)
    }

    private var targetBakeDateBinding: Binding<Date> {
        Binding(
            get: { targetBakeDateTime },
            set: { newValue in
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: targetBakeDateTime)
                targetBakeDateTime = calendar.date(
                    bySettingHour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    second: 0,
                    of: newValue
                ) ?? newValue
            }
        )
    }

    private var targetBakeTimeBinding: Binding<Date> {
        Binding(
            get: { targetBakeDateTime },
            set: { newValue in
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: newValue)
                targetBakeDateTime = calendar.date(
                    bySettingHour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    second: 0,
                    of: targetBakeDateTime
                ) ?? newValue
            }
        )
    }

    private func save() {
        guard let selectedFormulaChoice else { return }
        let resolvedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let formula = selectedFormulaChoice.makeTransientFormula()

        // Apply yeast conversion weights to the transient formula when converting sourdough → commercial
        if let conversion = computedYeastConversion, selectedFormulaChoice.yeastType == .sourdough {
            formula.totalFlourWeight = conversion.newTotalFlourWeight
            formula.totalWaterWeight = conversion.newTotalWaterWeight
            formula.recalculateDerivedValues()
        }

        let bake = BakeScheduler.generateBake(
            name: resolvedName,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: useCommercialYeast ? nil : selectedStarter,
            notes: notes
        )

        if selectedFormulaChoice.isSystem {
            bake.formula = nil
        }

        modelContext.insert(bake)
        bake.steps.forEach { modelContext.insert($0) }
        try? modelContext.save()

        let bakeID = bake.id
        let ctx = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forBake: bakeID, in: ctx)
        }

        dismiss()
        router.openBake(bakeID)
    }
}

private extension BakeCreationView {
    enum FormulaChoice {
        case user(RecipeFormula)
        case system(SystemFormula)

        var id: UUID {
            switch self {
            case let .user(formula):
                formula.id
            case let .system(formula):
                formula.id
            }
        }

        var name: String {
            switch self {
            case let .user(formula):
                formula.name
            case let .system(formula):
                formula.name
            }
        }

        var type: RecipeCategory {
            switch self {
            case let .user(formula):
                formula.type
            case let .system(formula):
                formula.type
            }
        }

        var hydrationPercent: Double {
            switch self {
            case let .user(formula):
                formula.hydrationPercent
            case let .system(formula):
                formula.hydrationPercent
            }
        }

        var totalFlourWeight: Double {
            switch self {
            case let .user(formula):
                formula.totalFlourWeight
            case let .system(formula):
                formula.totalFlourWeight
            }
        }

        var totalWaterWeight: Double {
            switch self {
            case let .user(formula):
                formula.totalWaterWeight
            case let .system(formula):
                formula.totalWaterWeight
            }
        }

        var yeastType: YeastType {
            switch self {
            case let .user(formula):
                formula.yeastType
            case let .system(formula):
                formula.yeastType
            }
        }

        var inoculationPercent: Double {
            switch self {
            case let .user(formula):
                formula.inoculationPercent
            case let .system(formula):
                formula.inoculationPercent
            }
        }

        var isSystem: Bool {
            if case .system = self {
                return true
            }
            return false
        }

        func makeTransientFormula() -> RecipeFormula {
            switch self {
            case let .user(formula):
                formula
            case let .system(formula):
                formula.makeTransientFormula()
            }
        }
    }
}

private extension BakeCreationView {
    static let targetDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "EEE d MMM yyyy"
        return formatter
    }()
}

private struct BakeSelectionChip: View {
    let title: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }
            Text(title)
                .lineLimit(1)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Theme.Control.secondaryForeground)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.Surface.card)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.Control.secondaryBorder, lineWidth: 1.5)
        )
    }
}

private struct BakeDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Date

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("Data", selection: $selection, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Theme.Surface.app.ignoresSafeArea())
            .navigationTitle("Data sfornata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Conferma") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct BakeTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Date

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("Ora", selection: $selection, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Theme.Surface.app.ignoresSafeArea())
            .navigationTitle("Ora sfornata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Conferma") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.38)])
    }
}

// MARK: - Preview ricalcolo lievito commerciale

private struct YeastConversionPreviewView: View {
    let conversion: YeastConversionResult
    let yeastType: YeastType
    let profile: YeastProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            conversionRow(
                icon: "chart.bar.fill",
                label: "Farina totale",
                value: String(format: "%.0f g", conversion.newTotalFlourWeight)
            )
            conversionRow(
                icon: "drop.fill",
                label: "Acqua totale",
                value: String(format: "%.0f g", conversion.newTotalWaterWeight)
            )
            Divider()
            conversionRow(
                icon: "circle.dotted",
                label: "\(yeastType.shortTitle) da aggiungere",
                value: String(format: "%.1f g", conversion.yeastGrams),
                highlight: true
            )
            conversionRow(
                icon: "clock",
                label: "Puntata",
                value: durationLabel(conversion.bulkDurationMinutes)
            )
            conversionRow(
                icon: "moon.zzz",
                label: "Appretto",
                value: durationLabel(conversion.proofDurationMinutes)
            )
            if isRichDough {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                    Text("Impasto ricco: zuccheri e grassi possono allungare i tempi.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }

    private var isRichDough: Bool {
        // La ricetta pan brioche e simili possono avere più farina → approssimazione UI
        conversion.newTotalFlourWeight > 600
    }

    private func durationLabel(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "\(h)h" : "\(h)h \(m)min"
        }
        return "\(minutes) min"
    }

    private func conversionRow(icon: String, label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(highlight ? Theme.accent : Theme.ink)
            Spacer()
            Text(value)
                .font(.subheadline.weight(highlight ? .semibold : .regular))
                .foregroundStyle(highlight ? Theme.accent : Theme.ink)
        }
    }
}

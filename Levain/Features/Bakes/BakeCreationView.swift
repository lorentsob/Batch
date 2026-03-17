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
    let shouldPreselectFirstAvailable: Bool
    private let systemFormulas: [SystemFormula]

    @State private var selectedFormulaID: UUID?
    @State private var selectedStarterID: UUID?
    @State private var name: String
    @State private var targetBakeDateTime: Date
    @State private var notes: String
    @State private var showingBakeDatePicker = false
    @State private var showingBakeTimePicker = false

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
                TextField("Nome del bake (opzionale)", text: $name)
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

            if let formula = selectedFormulaChoice, formula.yeastType == .sourdough {
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
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(Theme.Surface.app, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
        .presentationBackground(Theme.Surface.app)
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
                Section("Template di sistema") {
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

        let bake = BakeScheduler.generateBake(
            name: resolvedName,
            targetBakeDateTime: targetBakeDateTime,
            formula: formula,
            starter: selectedStarter,
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
        Task {
            await environment.notificationService.syncNotifications(for: bakeID, in: ctx)
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
        .presentationBackground(Theme.Surface.app)
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
        .presentationBackground(Theme.Surface.app)
    }
}

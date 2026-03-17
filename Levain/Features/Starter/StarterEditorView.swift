import SwiftUI
import SwiftData

@MainActor
struct StarterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let starter: Starter?

    @State private var name: String
    @State private var hydration: Double
    @State private var flours: [FlourSelection]
    @State private var containerWeight: Double
    @State private var storageMode: StorageMode
    @State private var refreshIntervalDays: Int
    @State private var remindersEnabled: Bool
    @State private var notes: String
    @State private var showingHydrationPicker = false
    @State private var editingFlourID: UUID?

    init(starter: Starter?) {
        self.starter = starter
        _name = State(initialValue: starter?.name ?? "")
        _hydration = State(initialValue: starter?.hydration ?? 100)
        _flours = State(initialValue: starter?.selectedFlours ?? [])
        _containerWeight = State(initialValue: starter?.containerWeight ?? 0)
        _storageMode = State(initialValue: starter?.storageMode ?? .fridge)
        _refreshIntervalDays = State(initialValue: starter?.refreshIntervalDays ?? 7)
        _remindersEnabled = State(initialValue: starter?.remindersEnabled ?? true)
        _notes = State(initialValue: starter?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Identità") {
                LabeledContent("Nome dello starter") {
                    TextField("es. Ciccio", text: $name)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Setup") {
                Button {
                    showingHydrationPicker = true
                } label: {
                    SelectionFormRow(
                        title: "Idratazione (%)",
                        value: "\(Int(hydration.rounded()))%"
                    )
                }
                .buttonStyle(.plain)
                NumericField(title: "Peso contenitore (g)", value: $containerWeight)
                Picker("Conservazione", selection: $storageMode) {
                    ForEach(StorageMode.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Stepper("Intervallo rinfresco: \(refreshIntervalDays) giorni", value: $refreshIntervalDays, in: 1...14)
                Toggle("Reminder attivi", isOn: $remindersEnabled)
            }

            Section("Mix Farine") {
                ForEach(flours) { flour in
                    Button {
                        editingFlourID = flour.id
                    } label: {
                        HStack {
                            Text(flour.displayName)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text("\(Int(flour.percentage.rounded()))%")
                                .foregroundStyle(Theme.muted)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indices in
                    flours.remove(atOffsets: indices)
                }
                Button {
                    let newFlour = FlourSelection(
                        categoryRaw: FlourCategory.strong.rawValue,
                        customName: "",
                        percentage: 100
                    )
                    flours.append(newFlour)
                    editingFlourID = newFlour.id
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

            Section("Note") {
                TextField("Consigli di rinfresco", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(starter == nil ? "Nuovo starter" : "Modifica starter")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $showingHydrationPicker) {
            StepValuePickerSheet(
                title: "Idratazione",
                values: Array(stride(from: 50, through: 200, by: 5)),
                selection: hydrationSelection,
                unit: "%"
            )
        }
        .sheet(isPresented: editingFlourSheetBinding) {
            NavigationStack {
                if let editingFlourIndex {
                    FlourSelectionEditorView(flour: $flours[editingFlourIndex])
                }
            }
        }
    }

    private func save() {
        let savedStarter: Starter
        if let starter {
            starter.name = name
            starter.type = inferredStarterType
            starter.hydration = hydration
            starter.selectedFlours = flours
            starter.containerWeight = containerWeight
            starter.storageMode = storageMode
            starter.refreshIntervalDays = refreshIntervalDays
            starter.remindersEnabled = remindersEnabled
            starter.notes = notes
            savedStarter = starter
        } else {
            savedStarter = Starter(
                name: name,
                type: inferredStarterType,
                hydration: hydration,
                flourMix: "",
                flours: flours,
                containerWeight: containerWeight,
                storageMode: storageMode,
                refreshIntervalDays: refreshIntervalDays,
                remindersEnabled: remindersEnabled,
                notes: notes
            )
            modelContext.insert(savedStarter)
        }

        try? modelContext.save()

        let starterID = savedStarter.id
        let ctx = modelContext
        Task {
            await environment.notificationService.syncNotifications(forStarter: starterID, in: ctx)
        }

        dismiss()
    }

    private var hydrationSelection: Binding<Int> {
        Binding(
            get: { Int(hydration.rounded()) },
            set: { hydration = Double($0) }
        )
    }

    private var editingFlourSheetBinding: Binding<Bool> {
        Binding(
            get: { editingFlourIndex != nil },
            set: { isPresented in
                if isPresented == false {
                    editingFlourID = nil
                }
            }
        )
    }

    private var editingFlourIndex: Int? {
        guard let editingFlourID else { return nil }
        return flours.firstIndex(where: { $0.id == editingFlourID })
    }

    private var inferredStarterType: StarterType {
        guard let primaryFlour = flours.first else { return starter?.type ?? .mixed }
        guard flours.count == 1 else { return .mixed }

        switch primaryFlour.category {
        case .rye:
            return .rye
        case .semolina:
            return .semolina
        default:
            return .wheat
        }
    }
}

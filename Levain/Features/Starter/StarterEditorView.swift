import SwiftUI
import SwiftData

struct StarterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let starter: Starter?

    @State private var name: String
    @State private var type: StarterType
    @State private var hydration: Double
    @State private var flours: [FlourSelection]
    @State private var containerWeight: Double
    @State private var storageMode: StorageMode
    @State private var refreshIntervalDays: Int
    @State private var remindersEnabled: Bool
    @State private var notes: String

    init(starter: Starter?) {
        self.starter = starter
        _name = State(initialValue: starter?.name ?? "")
        _type = State(initialValue: starter?.type ?? .mixed)
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
                Picker("Tipo", selection: $type) {
                    ForEach(StarterType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            }

            Section("Setup") {
                NumericField(title: "Idratazione (%)", value: $hydration)
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

            Section("Note") {
                LabeledContent("Note") {
                    TextField("Consigli di rinfresco", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle(starter == nil ? "Nuovo starter" : "Modifica starter")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let savedStarter: Starter
        if let starter {
            starter.name = name
            starter.type = type
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
                type: type,
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

        Task {
            await environment.notificationService.syncNotifications(for: savedStarter)
        }

        dismiss()
    }
}

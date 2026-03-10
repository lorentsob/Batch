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
    @State private var flourMix: String
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
        _flourMix = State(initialValue: starter?.flourMix ?? "")
        _containerWeight = State(initialValue: starter?.containerWeight ?? 0)
        _storageMode = State(initialValue: starter?.storageMode ?? .fridge)
        _refreshIntervalDays = State(initialValue: starter?.refreshIntervalDays ?? 7)
        _remindersEnabled = State(initialValue: starter?.remindersEnabled ?? true)
        _notes = State(initialValue: starter?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Identita") {
                TextField("Nome starter", text: $name)
                Picker("Tipo", selection: $type) {
                    ForEach(StarterType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            }

            Section("Setup") {
                NumericField(title: "Idratazione (%)", value: $hydration)
                TextField("Mix farine", text: $flourMix)
                NumericField(title: "Peso contenitore (g)", value: $containerWeight)
                Picker("Conservazione", selection: $storageMode) {
                    ForEach(StorageMode.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Stepper("Intervallo rinfresco: \(refreshIntervalDays) giorni", value: $refreshIntervalDays, in: 1...14)
                Toggle("Reminder attivi", isOn: $remindersEnabled)
            }

            Section("Note") {
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
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
            starter.flourMix = flourMix
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
                flourMix: flourMix,
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

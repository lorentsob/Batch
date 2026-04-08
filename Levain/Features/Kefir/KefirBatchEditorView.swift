import SwiftData
import SwiftUI

@MainActor
struct KefirBatchEditorView: View {
    enum Mode: Identifiable {
        case create
        case derive(KefirBatch)

        var id: String {
            switch self {
            case .create:
                "create"
            case .derive(let batch):
                "derive-\(batch.id.uuidString)"
            }
        }

        var title: String {
            switch self {
            case .create:
                "Nuovo batch"
            case .derive:
                "Nuovo batch"
            }
        }

        var submitLabel: String {
            switch self {
            case .create:
                "Crea"
            case .derive:
                "Crea derivato"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let mode: Mode
    let onSaved: (KefirBatch) -> Void

    @State private var name: String
    @State private var storageMode: KefirStorageMode
    @State private var expectedRoutineHours: Int
    @State private var useLabel: String
    @State private var differentiationNote: String
    @State private var notes: String
    @State private var plannedReactivationEnabled: Bool
    @State private var plannedReactivationAt: Date

    init(mode: Mode, onSaved: @escaping (KefirBatch) -> Void) {
        self.mode = mode
        self.onSaved = onSaved

        switch mode {
        case .create:
            _name = State(initialValue: "")
            _storageMode = State(initialValue: .roomTemperature)
            _expectedRoutineHours = State(initialValue: KefirStorageMode.roomTemperature.defaultRoutineHours)
            _useLabel = State(initialValue: "")
            _differentiationNote = State(initialValue: "")
            _notes = State(initialValue: "")
            _plannedReactivationEnabled = State(initialValue: false)
            _plannedReactivationAt = State(initialValue: .now.addingTimeInterval(5 * 24 * 60 * 60))
        case .derive(let batch):
            _name = State(initialValue: "\(batch.name) derivato")
            _storageMode = State(initialValue: batch.storageMode)
            _expectedRoutineHours = State(initialValue: batch.expectedRoutineHours)
            _useLabel = State(initialValue: batch.useLabel)
            _differentiationNote = State(initialValue: "")
            _notes = State(initialValue: "")
            _plannedReactivationEnabled = State(initialValue: batch.plannedReactivationAt != nil)
            _plannedReactivationAt = State(initialValue: batch.plannedReactivationAt ?? .now.addingTimeInterval(5 * 24 * 60 * 60))
        }
    }

    var body: some View {
        Form {
            identitySection
            routineSection
            contextSection
            notesSection
        }
        .navigationTitle(mode.title)
        .tint(Theme.Control.primaryFill)
        .scrollContentBackground(.hidden)
        .background(Theme.Surface.app)
        .accessibilityIdentifier("KefirBatchEditorView")
        .onChange(of: storageMode) { _, newValue in
            expectedRoutineHours = newValue.defaultRoutineHours
            if newValue != .freezer {
                plannedReactivationEnabled = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(mode.submitLabel) { save() }
                    .disabled(trimmedName.isEmpty)
                    .accessibilityIdentifier("KefirBatchSubmitButton")
            }
        }
    }

    private var identitySection: some View {
        Section("Identità") {
            LabeledContent("Nome batch") {
                TextField("es. Batch cucina", text: $name)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .textContentType(.none)
                    .accessibilityIdentifier("KefirBatchNameField")
            }

            Picker("Conservazione", selection: $storageMode) {
                ForEach(KefirStorageMode.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .accessibilityIdentifier("KefirBatchStoragePicker")
        }
    }

    private var routineSection: some View {
        Section {
            Stepper(value: $expectedRoutineHours, in: 1...336) {
                LabeledContent("Routine attesa") {
                    Text(routineLabel)
                        .foregroundStyle(Theme.ink)
                }
            }
            .accessibilityIdentifier("KefirBatchRoutineStepper")

            if storageMode == .freezer {
                Toggle("Pianifica riattivazione", isOn: $plannedReactivationEnabled)
                    .accessibilityIdentifier("KefirBatchReactivationToggle")

                if plannedReactivationEnabled {
                    DatePicker(
                        "Data riattivazione",
                        selection: $plannedReactivationAt,
                        in: Date.now...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .accessibilityIdentifier("KefirBatchReactivationPicker")
                }
            }
        } header: {
            Text("Routine")
        } footer: {
            Text(storageHint)
        }
    }

    private var contextSection: some View {
        Section("Contesto") {
            TextField("Uso principale", text: $useLabel)
                .accessibilityIdentifier("KefirBatchUseField")

            TextField("Differenze", text: $differentiationNote, axis: .vertical)
                .lineLimit(2...4)
                .accessibilityIdentifier("KefirBatchDifferenceField")
        }
    }

    private var notesSection: some View {
        Section("Note") {
            TextField("Osservazioni rapide", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .accessibilityIdentifier("KefirBatchNotesField")
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var routineLabel: String {
        switch storageMode {
        case .roomTemperature:
            return "\(expectedRoutineHours) ore"
        case .fridge, .freezer:
            let days = max(expectedRoutineHours / 24, 1)
            return "\(days) giorni"
        }
    }

    private var storageHint: String {
        switch storageMode {
        case .roomTemperature:
            "Ciclo rapido, di solito ogni 24 ore."
        case .fridge:
            "Rallenta il ciclo, comodo per chi vuole più flessibilità."
        case .freezer:
            "Pausa lunga. Puoi pianificare quando riattivarlo."
        }
    }

    private func save() {
        let now = Date.now
        let batch = KefirBatch(
            name: trimmedName,
            createdAt: now,
            lastManagedAt: now,
            expectedRoutineHours: expectedRoutineHours,
            storageMode: storageMode,
            alertsEnabled: true,
            sourceBatchId: sourceBatchID,
            useLabel: useLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            differentiationNote: differentiationNote.trimmingCharacters(in: .whitespacesAndNewlines),
            plannedReactivationAt: storageMode == .freezer && plannedReactivationEnabled ? plannedReactivationAt : nil
        )

        modelContext.insert(batch)
        let creationMode = sourceBatch.map { KefirEventRecorder.CreationMode.derive(source: $0) } ?? .create
        KefirEventRecorder.recordCreation(of: batch, mode: creationMode, in: modelContext, at: now)
        try? modelContext.save()

        let batchID = batch.id
        let context = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forKefirBatch: batchID, in: context)
        }

        onSaved(batch)
        dismiss()
    }

    private var sourceBatchID: UUID? {
        sourceBatch?.id
    }

    private var sourceBatch: KefirBatch? {
        guard case .derive(let sourceBatch) = mode else {
            return nil
        }
        return sourceBatch
    }
}

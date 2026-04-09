import SwiftData
import SwiftUI

@MainActor
struct KefirBatchManageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let batch: KefirBatch

    @State private var storageMode: KefirStorageMode
    @State private var expectedRoutineHours: Int
    @State private var plannedReactivationEnabled: Bool
    @State private var plannedReactivationAt: Date

    init(batch: KefirBatch) {
        self.batch = batch
        _storageMode = State(initialValue: batch.storageMode)
        _expectedRoutineHours = State(initialValue: batch.expectedRoutineHours)
        _plannedReactivationEnabled = State(initialValue: batch.plannedReactivationAt != nil)
        _plannedReactivationAt = State(initialValue: batch.plannedReactivationAt ?? .now.addingTimeInterval(5 * 24 * 60 * 60))
    }

    var body: some View {
        NavigationStack {
            Form {
                manageNowSection
                storageSection
            }
            .navigationTitle("Gestisci batch")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Theme.Control.primaryFill)
            .scrollContentBackground(.hidden)
            .background(Theme.Surface.app)
            .presentationBackground(Theme.Surface.app)
            .accessibilityIdentifier("KefirBatchManageSheet")
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
                    Button("Salva") { save() }
                        .accessibilityIdentifier("KefirBatchManageSaveButton")
                }
            }
        }
    }

    private var manageNowSection: some View {
        Section {
            Button(immediateActionLabel) {
                performImmediateAction()
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .accessibilityIdentifier("KefirBatchManageNowButton")
        } header: {
            Text("Azione immediata")
        } footer: {
            Text(immediateActionHint)
        }
    }

    private var storageSection: some View {
        Section {
            Picker("Conservazione", selection: $storageMode) {
                ForEach(KefirStorageMode.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .accessibilityIdentifier("KefirBatchManageStoragePicker")

            Stepper(value: $expectedRoutineHours, in: 1...336) {
                LabeledContent("Routine attesa") {
                    Text(routineLabel)
                }
            }
            .accessibilityIdentifier("KefirBatchManageRoutineStepper")

            if storageMode == .freezer {
                Toggle("Pianifica riattivazione", isOn: $plannedReactivationEnabled)
                    .accessibilityIdentifier("KefirBatchManageReactivationToggle")

                if plannedReactivationEnabled {
                    DatePicker(
                        "Data riattivazione",
                        selection: $plannedReactivationAt,
                        in: Date.now...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .accessibilityIdentifier("KefirBatchManageReactivationPicker")
                }
            }
        } header: {
            Text("Conservazione")
        } footer: {
            Text("Ogni modifica ricalcola la scadenza del prossimo rinnovo.")
        }
    }

    private var immediateActionLabel: String {
        batch.storageMode == .freezer ? "Riattiva adesso" : "Rinnova"
    }

    private var immediateActionHint: String {
        batch.storageMode == .freezer
            ? "Riporta il batch in attività."
            : "Segna il rinnovo adesso."
    }

    private var routineLabel: String {
        switch storageMode {
        case .roomTemperature:
            "\(expectedRoutineHours) ore"
        case .fridge, .freezer:
            "\(max(expectedRoutineHours / 24, 1)) giorni"
        }
    }

    private func performImmediateAction() {
        let now = Date.now

        if batch.storageMode == .freezer {
            let previous = KefirEventRecorder.Snapshot(batch: batch)
            batch.reactivate(at: now)
            KefirEventRecorder.recordReactivation(of: batch, previous: previous, in: modelContext, at: now)
            try? saveContext()
            syncNotificationsAndShowBanner("Batch riattivato")
        } else {
            batch.renew(at: now)
            KefirEventRecorder.recordRenewal(of: batch, in: modelContext, at: now)
            try? saveContext()
            syncNotificationsAndShowBanner("Gestione aggiornata a ora")
        }
        dismiss()
    }

    private func save() {
        let now = Date.now
        let previous = KefirEventRecorder.Snapshot(batch: batch)
        let reactivationDate = storageMode == .freezer && plannedReactivationEnabled
            ? plannedReactivationAt
            : nil
        batch.applyManagementUpdate(
            storageMode: storageMode,
            expectedRoutineHours: expectedRoutineHours,
            plannedReactivationAt: reactivationDate,
            at: now
        )
        KefirEventRecorder.recordManagementUpdate(of: batch, previous: previous, in: modelContext, at: now)
        try? saveContext()
        syncNotificationsAndShowBanner("Conservazione aggiornata")
        dismiss()
    }

    private func saveContext() throws {
        try modelContext.save()
    }

    private func syncNotificationsAndShowBanner(_ message: String) {
        let batchID = batch.id
        let context = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forKefirBatch: batchID, in: context)
        }
        environment.showBanner(message)
    }
}

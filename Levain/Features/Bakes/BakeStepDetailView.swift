import SwiftData
import SwiftUI

struct BakeStepDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let step: BakeStep

    @State private var showingOutOfOrderConfirm = false
    @State private var stepStartedTrigger = false
    @State private var stepCompletedTrigger = false

    var body: some View {
        Form {
            Section("Dettagli fase") {
                Text(step.displayName)
                if !step.descriptionText.isEmpty {
                    Text(step.descriptionText)
                        .foregroundStyle(Theme.muted)
                }
                if step.startedOutOfOrder {
                    StateBadge(text: "Fuori ordine", tone: .info)
                }
            }

            Section("Timing") {
                MetricRow(label: "Pianificato", value: DateFormattingService.dayTime(step.plannedStart))
                MetricRow(label: "Durata pianificata", value: DateFormattingService.duration(minutes: step.plannedDurationMinutes))

                if step.isWindowBased {
                    MetricRow(label: "Apertura finestra", value: DateFormattingService.dayTime(step.windowStart))
                    MetricRow(label: "Chiusura finestra", value: DateFormattingService.dayTime(step.windowEnd))
                }

                if let actualStart = step.actualStart {
                    MetricRow(label: "Inizio reale", value: DateFormattingService.dayTime(actualStart))
                }
                if let actualEnd = step.actualEnd {
                    MetricRow(label: "Fine reale", value: DateFormattingService.dayTime(actualEnd))
                }
            }

            if !step.temperatureRange.isEmpty || !step.volumeTarget.isEmpty {
                Section("Obiettivi qualitativi") {
                    if !step.temperatureRange.isEmpty {
                        MetricRow(label: "Temperatura", value: step.temperatureRange)
                    }
                    if !step.volumeTarget.isEmpty {
                        MetricRow(label: "Target volume", value: step.volumeTarget)
                    }
                }
            }

            if !step.isTerminal {
                Section("Esecuzione") {
                    Button(step.status == .running ? "Completa fase" : "Avvia fase") {
                        if step.status == .running {
                            complete()
                            dismiss()
                        } else if step.requiresSequenceOverrideBeforeStart {
                            showingOutOfOrderConfirm = true
                        } else {
                            start()
                            dismiss()
                        }
                    }

                    if step.requiresSequenceOverrideBeforeStart {
                        Text("Questa fase non è la prossima in sequenza. Puoi comunque avviarla con una conferma esplicita.")
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }

                    Button("Salta questa fase") {
                        skip()
                        dismiss()
                    }
                    .buttonStyle(DangerActionButtonStyle())
                }
            }
        }
        .navigationTitle(step.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: stepStartedTrigger)
        .sensoryFeedback(.success, trigger: stepCompletedTrigger)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
        .confirmationDialog(
            "Vuoi davvero avviare questa fase fuori sequenza?",
            isPresented: $showingOutOfOrderConfirm,
            titleVisibility: .visible
        ) {
            Button("Avvia comunque") {
                start()
                dismiss()
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Le fasi intermedie resteranno da fare e questa verrà segnata come fuori ordine.")
        }
    }

    private func skip() {
        step.skip()
        persistAndSync()
    }

    private func start() {
        step.start()
        stepStartedTrigger.toggle()
        persistAndSync()
    }

    private func complete() {
        step.complete()
        stepCompletedTrigger.toggle()
        persistAndSync()
    }

    private func persistAndSync() {
        try? modelContext.save()
        Task {
            if let bake = step.bake {
                await environment.notificationService.syncNotifications(for: bake)
            }
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.trailing)
        }
    }
}

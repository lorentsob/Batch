import SwiftData
import SwiftUI

struct BakeStepDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let step: BakeStep

    var body: some View {
        Form {
            Section("Dettagli step") {
                Text(step.displayName)
                if !step.descriptionText.isEmpty {
                    Text(step.descriptionText)
                        .foregroundStyle(Theme.muted)
                }
            }

            Section("Timing") {
                MetricRow(label: "Pianificato", value: DateFormattingService.dayTime(step.plannedStart))
                MetricRow(label: "Durata pianificata", value: DateFormattingService.duration(minutes: step.plannedDurationMinutes))

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
                    Button(step.status == .running ? "Completa step" : "Avvia step") {
                        if step.status == .running {
                            complete()
                        } else {
                            start()
                        }
                        dismiss()
                    }

                    Button("Salta questo step") {
                        skip()
                        dismiss()
                    }
                    .foregroundStyle(Theme.danger)
                }
            }
        }
        .navigationTitle("Step")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
    }

    private func skip() {
        step.skip()
        persistAndSync()
    }

    private func start() {
        step.start()
        persistAndSync()
    }

    private func complete() {
        step.complete()
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
        }
    }
}

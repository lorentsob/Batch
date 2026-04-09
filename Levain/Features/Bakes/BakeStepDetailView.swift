import SwiftData
import SwiftUI

@MainActor
struct BakeStepDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let step: BakeStep

    @State private var showingOutOfOrderConfirm = false
    @State private var stepStartedTrigger = false
    @State private var stepCompletedTrigger = false

    private var stepIngredients: [String] { step.stepIngredients }

    var body: some View {
        Form {
            if !stepIngredients.isEmpty {
                Section("Ingredienti") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(stepIngredients, id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Theme.Control.primaryFill.opacity(0.55))
                                    .frame(width: 3, height: 16)
                                    .padding(.top, 3)
                                Text(item)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Procedimento") {
                Text(step.displayName)
                    .font(.headline)

                if !step.descriptionText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Istruzioni")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.Control.primaryFill)

                        Text(step.descriptionText)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }

                if step.startedOutOfOrder {
                    StateBadge(text: "Fuori ordine", tone: .info)
                }
            }

            Section("Timing") {
                MetricRow(label: "Pianificato", value: DateFormattingService.dayTime(step.plannedStart))
                MetricRow(label: "Durata pianificata", value: DateFormattingService.duration(minutes: step.plannedDurationMinutes))

                if step.isWindowBased {
                    MetricRow(label: "Inizio finestra", value: DateFormattingService.dayTime(step.windowStart))
                    MetricRow(label: "Fine finestra", value: DateFormattingService.dayTime(step.windowEnd))
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
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        .scrollClipDisabled(false)
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

        // When this was the last step the bake transitions to .completed.
        // Saving immediately would trigger a re-render of the parent
        // BakeDetailView while its ActiveStepHeroCard / TimelineView is
        // being torn down — causing a crash.  Defer the save so the sheet
        // dismisses first.
        if let bake = step.bake, bake.derivedStatus == .completed {
            let bakeID = bake.id
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                try? modelContext.save()
                await environment.notificationService.syncNotifications(forBake: bakeID, in: modelContext)
                environment.showBanner("Impasto completato!", duration: 4)
            }
        } else {
            persistAndSync()
        }
    }

    private func persistAndSync() {
        let bakeID = step.bake?.id
        try? modelContext.save()

        if let bakeID {
            let ctx = modelContext
            Task { @MainActor in
                await environment.notificationService.syncNotifications(forBake: bakeID, in: ctx)
            }
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

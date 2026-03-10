import SwiftData
import SwiftUI

struct BakeStepCardView: View {
    let step: BakeStep
    var onShift: () -> Void

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    @State private var showingDetail = false

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(step.displayName)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text("\(DateFormattingService.dayTime(step.plannedStart)) · \(DateFormattingService.duration(minutes: step.plannedDurationMinutes))")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    StateBadge(text: stepBadge(step))
                }

                if !step.descriptionText.isEmpty {
                    Text(step.descriptionText)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                        .lineLimit(2)
                }

                if step.status == .running {
                    StepTimerView(step: step)
                }

                Divider()

                HStack {
                    if step.status == .pending {
                        Button("Start") { start(step) }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.accent)
                    } else if step.status == .running {
                        Button("Complete") { complete(step) }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.success)
                    }

                    Button("Dettaglio") { showingDetail = true }
                        .buttonStyle(.bordered)
                        .tint(Theme.ink)

                    if step.isTerminal == false {
                        Button("Sposta") { onShift() }
                            .buttonStyle(.bordered)
                            .tint(Theme.warning)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                BakeStepDetailView(step: step)
            }
        }
    }

    private func stepBadge(_ step: BakeStep) -> String {
        if step.status == .running { return "In corso" }
        if step.isOverdue() { return "In ritardo" }
        return step.status.title
    }

    private func start(_ step: BakeStep) {
        step.start()
        persistAndSync()
    }

    private func complete(_ step: BakeStep) {
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

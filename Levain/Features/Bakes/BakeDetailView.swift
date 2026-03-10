import SwiftData
import SwiftUI

struct BakeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let bake: Bake

    @State private var shiftingStep: BakeStep?
    @State private var showingCancelConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                BakeHeaderCard(bake: bake)

                // Timeline steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Timeline")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    VStack(spacing: 12) {
                        ForEach(bake.sortedSteps) { step in
                            BakeStepCardView(step: step, onShift: {
                                shiftingStep = step
                            })
                        }
                    }
                }

                if bake.derivedStatus != .cancelled && bake.derivedStatus != .completed {
                    Button("Annulla impasto", role: .destructive) {
                        showingCancelConfirm = true
                    }
                    .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(bake.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shiftingStep) { step in
            NavigationStack {
                ShiftTimelineView(bake: bake, anchorStep: step)
            }
        }
        .confirmationDialog("Sei sicuro?", isPresented: $showingCancelConfirm, titleVisibility: .visible) {
            Button("Annulla impasto", role: .destructive) {
                bake.isCancelled = true
                try? modelContext.save()
            }
            Button("Indietro", role: .cancel) {}
        }
    }
}

struct BakeHeaderCard: View {
    let bake: Bake
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bake.type.title.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.muted)
                        Text(bake.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.ink)
                    }
                    Spacer()
                    StateBadge(text: bake.derivedStatus.title)
                }

                Divider()

                HStack(spacing: 16) {
                    MetricItem(label: "Cottura", value: DateFormattingService.dayTime(bake.targetBakeDateTime))
                    MetricItem(label: "Farina", value: "\(Int(bake.totalFlourWeight))g")
                    MetricItem(label: "Idratazione", value: "\(Int(bake.hydrationPercent))%")
                    MetricItem(label: "Porzioni", value: "\(bake.servings)")
                }

                if bake.formula != nil || bake.starter != nil {
                    Divider()
                    HStack(spacing: 12) {
                        if let formula = bake.formula {
                            Button {
                                router.openFormula(formula.id)
                            } label: {
                                Text(formula.name)
                            }
                            .buttonStyle(.bordered)
                        }
                        if let starter = bake.starter {
                            Button {
                                router.openStarter(starter.id)
                            } label: {
                                Label(starter.name, systemImage: "drop.fill")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
    }
}

struct MetricItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.muted)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct StepTimerView: View {
    let step: BakeStep

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let elapsed = Int(context.date.timeIntervalSince(step.actualStart ?? step.plannedStart)) / 60
            let isLate = elapsed > step.plannedDurationMinutes
            let remaining = abs(step.plannedDurationMinutes - elapsed)

            VStack(alignment: .leading, spacing: 6) {
                Text(isLate ? "In ritardo" : "Timer attivo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isLate ? Theme.danger : Theme.ink)
                Text("Trascorso \(DateFormattingService.duration(minutes: max(0, elapsed))) · \(isLate ? "ritardo" : "residuo") \(DateFormattingService.duration(minutes: remaining))")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.background.opacity(0.8))
            )
        }
    }
}

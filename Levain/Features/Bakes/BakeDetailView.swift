import SwiftData
import SwiftUI

struct BakeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let bake: Bake

    @State private var detailStep: BakeStep?
    @State private var shiftingStep: BakeStep?
    @State private var showingCancelConfirm = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        let activeStep = bake.activeStep
        let timelineSteps = bake.sortedSteps.filter { $0.id != activeStep?.id }

        ScrollView {
            VStack(spacing: 24) {
                BakeHeaderCard(bake: bake)

                if let activeStep, bake.derivedStatus != .completed, bake.derivedStatus != .cancelled {
                    ActiveStepHeroCard(
                        contextLabel: "Step attivo",
                        contextValue: bake.name,
                        step: activeStep,
                        onPrimaryAction: {
                            handlePrimary(activeStep)
                        },
                        onDetail: {
                            detailStep = activeStep
                        },
                        onCustomShift: activeStep.status == .running || activeStep.isOverdue() ? {
                            shiftingStep = activeStep
                        } : nil,
                        onQuickShift: activeStep.status == .running || activeStep.isOverdue() ? { minutes in
                            shift(activeStep, by: minutes)
                        } : nil
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(activeStep == nil ? "Timeline" : "Timeline restante")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if timelineSteps.isEmpty {
                        SectionCard {
                            Text("Nessun altro step operativo.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            Text("Quando chiudi lo step corrente, il prossimo entrerà qui.")
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }
                    } else {
                        VStack(spacing: 10) {
                            ForEach(Array(timelineSteps.enumerated()), id: \.element.id) { item in
                                let index = item.offset
                                let step = item.element
                                StepTimelineRow(
                                    step: step,
                                    showsConnector: index < timelineSteps.count - 1
                                ) {
                                    detailStep = step
                                }
                            }
                        }
                    }
                }

                if let activeStep {
                    let tips = environment.knowledgeLibrary.tips(for: activeStep.type)
                    if !tips.isEmpty {
                        TipGroupView(items: tips) { id in
                            router.openKnowledge(id)
                        }
                    }
                }

                if bake.derivedStatus != .cancelled && bake.derivedStatus != .completed {
                    Button("Annulla impasto", role: .destructive) {
                        showingCancelConfirm = true
                    }
                    .padding(.top, 12)
                } else {
                    Button("Elimina impasto", role: .destructive) {
                        showingDeleteConfirm = true
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
        .sheet(item: $detailStep) { step in
            NavigationStack {
                BakeStepDetailView(step: step)
            }
        }
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
        .confirmationDialog("Eliminare definitivamente?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Elimina", role: .destructive) {
                modelContext.delete(bake)
                try? modelContext.save()
                router.selectedTab = .bakes
            }
            Button("Annulla", role: .cancel) {}
        }
    }

    private func handlePrimary(_ step: BakeStep) {
        if step.status == .running {
            step.complete()
        } else if step.isTerminal == false {
            step.start()
        }

        persistAndSync()
    }

    private func shift(_ step: BakeStep, by minutes: Int) {
        BakeScheduler.shiftFutureSteps(in: bake, after: step, by: minutes)
        persistAndSync()
    }

    private func persistAndSync() {
        try? modelContext.save()

        Task {
            await environment.notificationService.syncNotifications(for: bake)
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

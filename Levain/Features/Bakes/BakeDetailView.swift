import SwiftData
import SwiftUI

@MainActor
struct BakeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let bake: Bake

    @State private var detailStep: BakeStep?
    @State private var shiftingStep: BakeStep?
    @State private var destructivePrompt: DestructiveBakePrompt?
    @State private var stepStartedTrigger = false
    @State private var stepCompletedTrigger = false

    var body: some View {
        let isCancelled = bake.derivedStatus == .cancelled
        let activeStep = bake.activeStep
        let timelineSteps = isCancelled
            ? bake.sortedSteps
            : bake.sortedSteps.filter { $0.id != activeStep?.id }

        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    BakeHeaderCard(bake: bake)

                    if let activeStep, bake.derivedStatus != .completed, bake.derivedStatus != .cancelled {
                        ActiveStepHeroCard(
                            contextLabel: "Fase attiva",
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
                        HStack {
                            Text(isCancelled ? "Timeline archiviata" : (activeStep == nil ? "Timeline" : "Timeline restante"))
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            StateBadge(
                                text: "\(timelineSteps.count) fasi",
                                tone: isCancelled ? .done : (timelineSteps.isEmpty ? .schedule : .count)
                            )
                        }

                        if timelineSteps.isEmpty {
                            SectionCard(emphasis: .subtle) {
                                Text("Nessun'altra fase da seguire.")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Text("Quando chiudi la fase corrente, la prossima comparirà qui.")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                        } else {
                            VStack(spacing: 10) {
                                ForEach(timelineSteps) { step in
                                    StepTimelineRow(
                                        step: step,
                                        isBakeCancelled: isCancelled
                                    ) {
                                        detailStep = step
                                    }
                                }
                            }
                        }
                    }

                    if let activeStep, isCancelled == false {
                        let tips = environment.knowledgeLibrary.tips(for: activeStep.type)
                        if !tips.isEmpty {
                            TipGroupView(items: tips) { id in
                                router.openKnowledge(id)
                            }
                        }
                    }

                    if bake.derivedStatus != .cancelled && bake.derivedStatus != .completed {
                        Button("Annulla impasto") {
                            present(prompt: .cancel)
                        }
                        .buttonStyle(DangerActionButtonStyle())
                        .padding(.top, 12)
                    } else {
                        Button("Elimina impasto") {
                            deleteBake()
                        }
                        .buttonStyle(DangerActionButtonStyle())
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .allowsHitTesting(destructivePrompt == nil)

            Group {
                if let destructivePrompt {
                    destructivePromptOverlay(prompt: destructivePrompt)
                }
            }
            .animation(Theme.Animation.standard, value: destructivePrompt?.id)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(bake.name)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        // No implicit .animation() here — it causes rendering deadlocks by
        // animating ALL body changes when destructivePrompt toggles. Overlay
        // animation is scoped via .transition() on the overlay itself and
        // explicit withAnimation in present()/dismissPrompt().
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
        .sensoryFeedback(.impact(flexibility: .soft), trigger: stepStartedTrigger)
        .sensoryFeedback(.success, trigger: stepCompletedTrigger)
    }

    private func handlePrimary(_ step: BakeStep) {
        if step.status == .running {
            step.complete()
            stepCompletedTrigger.toggle()
        } else if step.isTerminal == false {
            step.start()
            stepStartedTrigger.toggle()
        }

        if bake.derivedStatus == .completed {
            router.bakesPath.removeAll()

            let bakeID = bake.id
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                try? modelContext.save()
                await environment.notificationService.syncNotifications(forBake: bakeID, in: modelContext)
                environment.showBanner("Bake completato!", duration: 4)
            }
        } else {
            persistAndSync()
        }
    }

    private func shift(_ step: BakeStep, by minutes: Int) {
        BakeScheduler.shiftFutureSteps(in: bake, after: step, by: minutes)
        persistAndSync()
    }

    private func persistAndSync() {
        let bakeID = bake.id
        try? modelContext.save()

        let ctx = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forBake: bakeID, in: ctx)
        }
    }

    private func present(prompt: DestructiveBakePrompt) {
        withAnimation(Theme.Animation.standard) {
            destructivePrompt = prompt
        }
    }

    private func dismissPrompt() {
        withAnimation(Theme.Animation.standard) {
            destructivePrompt = nil
        }
    }

    @ViewBuilder
    private func destructivePromptOverlay(prompt: DestructiveBakePrompt) -> some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.16)
                .ignoresSafeArea()
                .onTapGesture(perform: dismissPrompt)

            DestructiveBakeSheet(prompt: prompt) {
                dismissPrompt()
            } onConfirm: {
                confirm(prompt)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func confirm(_ prompt: DestructiveBakePrompt) {
        switch prompt {
        case .cancel:
            // Navigate back BEFORE mutating to avoid the SwiftUI rendering
            // deadlock caused by structural body changes while the view is live.
            // The bake moves to the archive section in BakesView.
            destructivePrompt = nil
            router.bakesPath.removeAll()

            let bakeRef = bake
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                bakeRef.isCancelled = true
                try? modelContext.save()
                await environment.notificationService.resyncAll(using: modelContext)
                environment.showBanner("Bake annullato e spostato in archivio.", duration: 4)
            }

        case .delete:
            dismissPrompt()
            deleteBake()
        }
    }

    private func deleteBake() {
        modelContext.delete(bake)
        try? modelContext.save()
        router.selectedTab = .bakes
        router.bakesPath.removeAll()

        Task { @MainActor in
            await environment.notificationService.resyncAll(using: modelContext)
        }
    }
}

struct BakeHeaderCard: View {
    let bake: Bake
    @EnvironmentObject private var router: AppRouter

    @State private var showingIngredients = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]

    var body: some View {
        SectionCard(emphasis: isCancelled ? .danger : .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        StateBadge(text: bake.type.title, tone: typeTone)
                        Text(bake.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(titleColor)
                    }
                    Spacer()
                    StateBadge(bakeStatus: bake.derivedStatus)
                }

                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                    MetricChip(label: "Utilizzo", value: DateFormattingService.dayTime(bake.targetBakeDateTime), tone: metricTone)
                    MetricChip(label: "Farina", value: "\(Int(bake.totalFlourWeight)) g", tone: metricTone)
                    MetricChip(label: "Idratazione", value: "\(Int(bake.hydrationPercent))%", tone: metricTone)
                    MetricChip(label: "Porzioni", value: "\(bake.servings)", tone: metricTone)
                }

                VStack(alignment: .leading, spacing: 8) {
                    if bake.formula != nil || bake.starter != nil {
                        HStack(spacing: 12) {
                            if let formula = bake.formula {
                                Button {
                                    router.openFormula(formula.id)
                                } label: {
                                    Label(formula.name, systemImage: "book.closed")
                                }
                                .buttonStyle(
                                    SecondaryActionButtonStyle(
                                        fill: Theme.Surface.card,
                                        tint: secondaryTint,
                                        border: secondaryBorder
                                    )
                                )
                            }
                            if let starter = bake.starter {
                                Button {
                                    router.openStarter(starter.id)
                                } label: {
                                    Label(starter.name, systemImage: "drop.fill")
                                }
                                .buttonStyle(
                                    SecondaryActionButtonStyle(
                                        fill: Theme.Surface.card,
                                        tint: secondaryTint,
                                        border: secondaryBorder
                                    )
                                )
                            }
                        }
                    }

                    Button {
                        showingIngredients = true
                    } label: {
                        Label("Ricetta", systemImage: "list.bullet.clipboard")
                    }
                    .buttonStyle(
                        SecondaryActionButtonStyle(
                            fill: Theme.Surface.card,
                            tint: secondaryTint,
                            border: secondaryBorder
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showingIngredients) {
            NavigationStack {
                BakeIngredientsView(bake: bake)
            }
        }
    }

    private var isCancelled: Bool {
        bake.derivedStatus == .cancelled
    }

    private var typeTone: StateBadge.Tone {
        isCancelled ? .done : .info
    }

    private var metricTone: StateBadge.Tone {
        isCancelled ? .done : .info
    }

    private var titleColor: Color {
        isCancelled ? Theme.Text.onDanger : Theme.ink
    }

    private var secondaryTint: Color {
        isCancelled ? Theme.Text.onDanger : Theme.Control.secondaryForeground
    }

    private var secondaryBorder: Color {
        isCancelled ? Theme.Border.danger : Theme.Control.secondaryBorder
    }
}

private enum DestructiveBakePrompt: String, Identifiable {
    case cancel
    case delete

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cancel:
            "Annullare questo bake?"
        case .delete:
            "Eliminare definitivamente?"
        }
    }

    var message: String {
        switch self {
        case .cancel:
            "La timeline passerà in archivio, il bottone finale diventerà \"Elimina impasto\" e i promemoria verranno rimossi."
        case .delete:
            "Il bake, le sue fasi e i promemoria associati verranno rimossi in modo permanente."
        }
    }

    var actionTitle: String {
        switch self {
        case .cancel:
            "Annulla impasto"
        case .delete:
            "Elimina impasto"
        }
    }
}

private struct DestructiveBakeSheet: View {
    let prompt: DestructiveBakePrompt
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(prompt.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text(prompt.message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                Button(prompt.actionTitle, action: onConfirm)
                    .buttonStyle(DangerActionButtonStyle())

                Button("Indietro", action: onCancel)
                    .buttonStyle(SecondaryActionButtonStyle(fill: Theme.Surface.card))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .fill(Theme.Surface.app)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .stroke(Theme.Border.defaultColor, lineWidth: 1)
        )
        .shadow(color: Theme.Shadow.card, radius: 24, y: 12)
    }
}

struct MetricItem: View {
    let label: String
    let value: String

    var body: some View {
        MetricChip(label: label, value: value, tone: .info)
    }
}

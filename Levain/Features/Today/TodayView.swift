import SwiftData
import SwiftUI

@MainActor
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.lastRefresh, order: .reverse) private var starters: [Starter]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var refreshStarter: Starter?
    @State private var detailSelection: TodayBakeSelection?
    @State private var shiftSelection: TodayBakeSelection?
    @State private var stepStartedTrigger = false
    @State private var stepCompletedTrigger = false

    var body: some View {
        let snapshot = TodaySnapshot.make(
            bakes: Array(bakes),
            starters: Array(starters),
            formulas: Array(formulas)
        )

        ZStack(alignment: .topLeading) {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard(emphasis: .tinted) {
                        Text("Cosa fare oggi")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.ink)

                        Text(snapshot.heroSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)

                        if snapshot.agenda.emptyState == .actionable {
                            HStack(spacing: 12) {
                                StateBadge(text: "\(snapshot.todayCount) in agenda", tone: .count)
                                if snapshot.inProgressCount > 0 {
                                    StateBadge(text: "\(snapshot.inProgressCount) bake attivi", tone: .info)
                                }
                            }
                        }
                    }

                    switch snapshot.agenda.emptyState {
                    case .firstLaunch:
                        TodayOnboardingView(
                            onNewBake: { router.selectedTab = .bakes },
                            onAddStarter: { router.selectedTab = .starter }
                        )
                    case .allClear:
                        TodayAllClearView {
                            router.selectedTab = .bakes
                        }
                        TodayKnowledgeCard {
                            router.showingKnowledge = true
                        }
                    case .futureOnly:
                        if let preview = snapshot.agenda.futurePreview {
                            TodayFuturePreviewCard(preview: preview) {
                                openFuturePreview(preview)
                            }
                        }
                        if starters.isEmpty == false {
                            TodayStarterStatusCard(starters: Array(starters)) { starter in
                                refreshStarter = starter
                            }
                        }
                        TodayKnowledgeCard {
                            router.showingKnowledge = true
                        }
                    case .actionable:
                        ForEach(TodayAgendaItem.Section.allCases) { section in
                            if let items = snapshot.agenda.sections[section], items.isEmpty == false {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(section.title)
                                            .font(.headline)
                                            .foregroundStyle(Theme.ink)
                                        Spacer()
                                        StateBadge(text: "\(items.count)", tone: .count)
                                    }

                                    ForEach(items) { item in
                                        switch item.kind {
                                        case let .bake(summary):
                                            if let selection = resolve(summary) {
                                                switch summary.presentationStyle {
                                                case .tomorrowPreview:
                                                    TodayTomorrowPreviewRow(bake: selection.bake, step: selection.step) {
                                                        detailSelection = selection
                                                    }
                                                case .compactWindow:
                                                    TodayWindowedBakeRow(item: item) {
                                                        detailSelection = selection
                                                    }
                                                case .primaryCard:
                                                    TodayStepCardView(
                                                        bake: selection.bake,
                                                        step: selection.step,
                                                        section: item.section,
                                                        onPrimaryAction: {
                                                            handlePrimary(selection)
                                                        },
                                                        onOpenDetail: {
                                                            detailSelection = selection
                                                        },
                                                        onOpenShift: {
                                                            shiftSelection = selection
                                                        },
                                                        onQuickShift: { minutes in
                                                            shift(selection, by: minutes)
                                                        }
                                                    )
                                                }
                                            }
                                        case let .starter(starterID):
                                            TodayStarterReminderRow(item: item, isUrgent: item.section == .urgent) {
                                                openStarter(starterID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        // Starter snapshot — visibile anche quando lo starter è ok
                        if starters.contains(where: { $0.dueState() == .ok }) {
                            TodayStarterStatusCard(
                                starters: starters.filter { $0.dueState() == .ok }
                            ) { starter in
                                refreshStarter = starter
                            }
                        }

                        TodayKnowledgeCard {
                            router.showingKnowledge = true
                        }
                    }


                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .contentMargins(.bottom, 88, for: .scrollContent)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityIdentifier("TodayScrollView")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $refreshStarter) { starter in
            NavigationStack {
                RefreshLogView(starter: starter)
            }
        }
        .sheet(item: $detailSelection) { selection in
            NavigationStack {
                BakeStepDetailView(step: selection.step)
            }
        }
        .sheet(item: $shiftSelection) { selection in
            NavigationStack {
                ShiftTimelineView(bake: selection.bake, anchorStep: selection.step)
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: stepStartedTrigger)
        .sensoryFeedback(.success, trigger: stepCompletedTrigger)
    }

    private func resolve(_ summary: TodayAgendaItem.BakeSummary) -> TodayBakeSelection? {
        guard let bake = bakes.first(where: { $0.id == summary.bakeID }),
              let step = bake.steps.first(where: { $0.id == summary.stepID }) else {
            return nil
        }

        return TodayBakeSelection(bake: bake, step: step)
    }

    private func handlePrimary(_ selection: TodayBakeSelection) {
        let step = selection.step

        if step.status == .running {
            step.complete()
            stepCompletedTrigger.toggle()
        } else if step.isTerminal == false {
            step.start()
            stepStartedTrigger.toggle()
        }

        // If the bake just became complete (in-memory, before save), persist
        // on a short delay so SwiftUI never re-renders the TodayStepCardView
        // with a stale ActiveStepHeroCard / TimelineView being torn down.
        let bake = selection.bake
        if bake.derivedStatus == .completed {
            let bakeID = bake.id
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                try? modelContext.save()
                await environment.notificationService.syncNotifications(forBake: bakeID, in: modelContext)
                environment.showBanner("Bake completato!", duration: 4)
            }
        } else {
            persistAndSync(for: bake)
        }
    }

    private func shift(_ selection: TodayBakeSelection, by minutes: Int) {
        BakeScheduler.shiftFutureSteps(in: selection.bake, after: selection.step, by: minutes)
        persistAndSync(for: selection.bake)
    }

    private func openStarter(_ starterID: UUID) {
        refreshStarter = starters.first(where: { $0.id == starterID })
    }

    private func openFuturePreview(_ preview: TodayFuturePreview) {
        switch preview.kind {
        case let .bake(summary):
            router.openBake(summary.bakeID)
        case let .starter(starterID):
            router.openStarter(starterID)
        }
    }

    private func persistAndSync(for bake: Bake) {
        let bakeID = bake.id
        try? modelContext.save()

        let ctx = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forBake: bakeID, in: ctx)
        }
    }
}

private struct TodayBakeSelection: Identifiable {
    let bake: Bake
    let step: BakeStep

    var id: UUID { step.id }
}

private struct TodaySnapshot {
    let agenda: TodayAgendaSnapshot
    let todayCount: Int
    let inProgressCount: Int
    let heroSubtitle: String

    static func make(bakes: [Bake], starters: [Starter], formulas: [RecipeFormula]) -> TodaySnapshot {
        let agenda = TodayAgendaBuilder.buildSnapshot(
            bakes: bakes,
            starters: starters,
            hasPersistedData: bakes.isEmpty == false || starters.isEmpty == false || formulas.isEmpty == false
        )

        let todayCount = (agenda.sections[.urgent]?.count ?? 0) + (agenda.sections[.scheduled]?.count ?? 0)
        let inProgressCount = bakes.reduce(into: 0) { count, bake in
            if bake.derivedStatus == .inProgress {
                count += 1
            }
        }

        let heroSubtitle: String
        switch agenda.emptyState {
        case .firstLaunch:
            heroSubtitle = "Crea il tuo primo bake o aggiungi uno starter per cominciare."
        case .allClear:
            heroSubtitle = "Tutto in pari — nessuna azione urgente per oggi."
        case .futureOnly:
            if let preview = agenda.futurePreview {
                heroSubtitle = "Oggi sei libero, ma ricordati di: \(preview.title)."
            } else {
                heroSubtitle = "Oggi è libero: non c'è ancora nulla in programma."
            }
        case .actionable:
            if let first = agenda.sections[.urgent]?.first, let summary = first.bakeSummary {
                heroSubtitle = "Hai una fase da seguire in \(summary.bakeName): \(summary.stepName)."
            } else if let first = agenda.sections[.urgent]?.first {
                heroSubtitle = "C'è uno starter da rinfrescare: \(first.title)."
            } else if let first = agenda.sections[.scheduled]?.first, let summary = first.bakeSummary {
                heroSubtitle = "Più tardi ti aspetta \(summary.stepName) per \(summary.bakeName)."
            } else if let first = agenda.sections[.scheduled]?.first {
                heroSubtitle = "Oggi è previsto il rinfresco di \(first.title)."
            } else {
                heroSubtitle = "Tutto sotto controllo per ora."
            }
        }

        return TodaySnapshot(
            agenda: agenda,
            todayCount: todayCount,
            inProgressCount: inProgressCount,
            heroSubtitle: heroSubtitle
        )
    }
}

private struct TodayFuturePreviewCard: View {
    let preview: TodayFuturePreview
    let action: () -> Void

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                StateBadge(text: "In programma", tone: .count)

                Text("Tieni d'occhio gli starter")
                    .foregroundStyle(Theme.muted)

                VStack(alignment: .leading, spacing: 4) {
                    Text(preview.title)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(preview.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }

                Button(buttonTitle, action: action)
                    .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private var buttonTitle: String {
        switch preview.kind {
        case .bake:
            return "Vai a Impasti"
        case .starter:
            return "Vai a Starter"
        }
    }
}

private struct TodayWindowedBakeRow: View {
    let item: TodayAgendaItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                        StateBadge(text: item.state, tone: .schedule)
                    }

                    Text(item.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.Text.tertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .fill(Theme.Surface.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .stroke(Theme.Border.defaultColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TodayTomorrowPreviewRow: View {
    let bake: Bake
    let step: BakeStep
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(bake.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                        StateBadge(text: "Domani", tone: .schedule)
                    }

                    Text(step.displayName)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    Text(DateFormattingService.dayTime(step.isWindowBased ? step.windowStart : step.plannedStart))
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.Text.tertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .fill(Theme.Surface.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .stroke(Theme.Border.defaultColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Starter status snapshot (actionable / futureOnly)

private struct TodayStarterStatusCard: View {
    let starters: [Starter]
    let onRefresh: (Starter) -> Void

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Text("Lievito madre")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                ForEach(starters) { starter in
                    if starter.id != starters.first?.id {
                        Divider()
                    }
                    TodayStarterStatusRow(starter: starter) {
                        onRefresh(starter)
                    }
                }
            }
        }
    }
}

private struct TodayStarterStatusRow: View {
    let starter: Starter
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(starter.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text(nextRefreshLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }

            Spacer()

            StateBadge(dueState: starter.dueState())
        }
    }

    private var nextRefreshLabel: String {
        let days = Calendar.current.dateComponents([.day], from: Date().startOfDay, to: starter.nextDueDate.startOfDay).day ?? 0
        switch days {
        case 0:  return "Rinfresco oggi"
        case 1:  return "Rinfresco domani"
        default: return "Rinfresco tra \(days) giorni"
        }
    }
}

// MARK: - All-clear state

private struct TodayAllClearView: View {
    let onNewBake: () -> Void

    var body: some View {
        SectionCard(emphasis: .subtle) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.Status.doneBackground)
                            .frame(width: 48, height: 48)
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Theme.Status.doneForeground)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tutto in pari")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text("Non c'è nulla di urgente da fare. Il tuo starter è ok e non hai step da seguire oggi.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button("Pianifica un nuovo bake", action: onNewBake)
                    .buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }
}

// MARK: - First-launch onboarding

private struct TodayOnboardingView: View {
    @EnvironmentObject private var router: AppRouter
    let onNewBake: () -> Void
    let onAddStarter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionCard(emphasis: .tinted) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Inizia il tuo primo bake")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.ink)
                        Text("Scegli una ricetta, imposta l'orario di sfornatura e Levain costruisce la timeline automaticamente.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Button("Nuovo bake", action: onNewBake)
                        .buttonStyle(PrimaryActionButtonStyle())
                }
            }

            HStack(spacing: 12) {
                FeaturePillCard(
                    systemImage: "drop.fill",
                    title: "Aggiungi starter",
                    subtitle: "Traccia rinfreschi e ricevi promemoria.",
                    accessibilityIdentifier: "TodayAddStarterButton",
                    action: onAddStarter
                )

                FeaturePillCard(
                    systemImage: "book.pages.fill",
                    title: "Sfoglia le guide",
                    subtitle: "Scopri i segreti della lievitazione naturale.",
                    accessibilityIdentifier: "TodayBrowseGuidesButton",
                    action: { router.showingKnowledge = true }
                )
            }
        }
    }
}

private struct FeaturePillCard: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .fill(Theme.Surface.card)
                    .shadow(color: Theme.Shadow.card, radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .stroke(Theme.Border.defaultColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Knowledge card

private struct TodayKnowledgeCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Guide e consigli")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Scopri i segreti della lievitazione naturale.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .fill(Theme.Surface.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .stroke(Theme.Border.defaultColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Today") {
    NavigationStack {
        TodayView()
    }
    .environmentObject(AppRouter())
    .environmentObject(AppEnvironment())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}

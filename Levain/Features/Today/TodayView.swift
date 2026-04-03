import SwiftData
import SwiftUI

@MainActor
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.lastRefresh, order: .reverse) private var starters: [Starter]
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var kefirBatches: [KefirBatch]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]
    @Query private var appSettingsList: [AppSettings]

    @State private var refreshStarter: Starter?
    @State private var detailSelection: TodayBakeSelection?
    @State private var shiftSelection: TodayBakeSelection?
    @State private var stepStartedTrigger = false
    @State private var stepCompletedTrigger = false
    @State private var cachedSnapshot: TodaySnapshot?
    @State private var showingSettings = false

    private var appSettings: AppSettings? { appSettingsList.first }

    private var allFeaturesDisabled: Bool {
        guard let s = appSettings else { return false }
        return !s.isBakeEnabled && !s.isStarterEnabled && !s.isKefirEnabled
    }

    var body: some View {
        let revision = snapshotRevision
        let snapshot = resolvedSnapshot(for: revision)

        ZStack(alignment: .topLeading) {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard(emphasis: .tinted) {
                        Text("Cosa fare oggi")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.ink)

                        Text(allFeaturesDisabled
                            ? "Tutte le sezioni sono disattivate."
                            : snapshot.heroSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)

                        if !allFeaturesDisabled && snapshot.agenda.emptyState == .actionable {
                            HStack(spacing: 12) {
                                StateBadge(text: "\(snapshot.todayCount) in agenda", tone: .count)
                                if snapshot.inProgressCount > 0 {
                                    StateBadge(text: "\(snapshot.inProgressCount) bake attivi", tone: .info)
                                }
                            }
                        }
                    }

                    if allFeaturesDisabled {
                        EmptyStateView(
                            title: "Nessuna sezione attiva",
                            message: "Attiva almeno una sezione (Impasti, Starter o Kefir) dalle impostazioni per iniziare a usare Levain.",
                            actionTitle: "Apri impostazioni"
                        ) {
                            showingSettings = true
                        }
                    } else {

                    switch snapshot.agenda.emptyState {
                    case .firstLaunch:
                        TodayOnboardingView(
                            onNewBake: { router.selectedTab = .fermentations },
                            onAddStarter: { router.selectedTab = .fermentations }
                        )
                    case .allClear:
                        TodayAllClearView {
                            router.selectedTab = .fermentations
                        }
                        TodayKnowledgeCard {
                            router.openKnowledge(nil)
                        }
                    case .futureOnly:
                        if let preview = snapshot.agenda.futurePreview {
                            TodayFuturePreviewCard(preview: preview) {
                                openFuturePreview(preview)
                            }
                        }
                        if snapshot.healthyStarters.isEmpty == false {
                            TodayStarterStatusCard(starters: snapshot.healthyStarters) { starter in
                                refreshStarter = starter
                            }
                        }
                        TodayKnowledgeCard {
                            router.openKnowledge(nil)
                        }
                    case .actionable:
                        // Build domain-grouped sections so all starters, lievitati, and
                        // kefir items appear together regardless of urgency ordering.
                        let sections = renderSections(
                            feed: snapshot.agenda.feed,
                            healthyStarters: snapshot.healthyStarters
                        )
                        ForEach(sections) { section in
                            ForEach(Array(section.items.enumerated()), id: \.offset) { idx, sectionItem in
                                TodayOperationalCardView(domain: section.domain, showHeader: idx == 0) {
                                    switch sectionItem {
                                    case let .feedItem(item):
                                        switch item.kind {
                                        case let .bake(summary):
                                            if let selection = snapshot.selection(for: summary) {
                                                switch summary.presentationStyle {
                                                case .tomorrowPreview:
                                                    TodayTomorrowPreviewRow(bake: selection.bake, step: selection.step) {
                                                        router.openBake(selection.bake.id)
                                                    }
                                                case .compactWindow:
                                                    TodayWindowedBakeRow(item: item) {
                                                        detailSelection = selection
                                                    }
                                                case .primaryCard:
                                                    TodayStepCardView(
                                                        bake: selection.bake,
                                                        step: selection.step,
                                                        urgency: item.urgency,
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
                                            TodayStarterReminderRow(item: item, urgency: item.urgency) {
                                                openStarter(starterID)
                                            }
                                        case let .kefir(batchID):
                                            TodayKefirBatchRow(item: item) {
                                                router.openKefirBatch(batchID)
                                            }
                                        }
                                    case let .healthyStarter(starter):
                                        TodayHealthyStarterCard(starter: starter) {
                                            refreshStarter = starter
                                        }
                                    }
                                }
                            }
                        }

                        TodayKnowledgeCard {
                            router.openKnowledge(nil)
                        }
                    }

                    } // end else (features not all disabled)

                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .contentMargins(.bottom, 88, for: .scrollContent)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityIdentifier("TodayScrollView")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Impostazioni")
                .accessibilityIdentifier("TodaySettingsButton")
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
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
        .task(id: revision) {
            cachedSnapshot = buildSnapshot(revision: revision)
        }
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
        case let .kefir(batchID):
            router.openKefirBatch(batchID)
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

    private var snapshotRevision: Int {
        var hasher = Hasher()

        for bake in bakes {
            hasher.combine(bake.id)
            hasher.combine(bake.name)
            hasher.combine(bake.isCancelled)
            hasher.combine(bake.targetBakeDateTime)

            for step in bake.steps {
                hasher.combine(step.id)
                hasher.combine(step.orderIndex)
                hasher.combine(step.typeRaw)
                hasher.combine(step.nameOverride)
                hasher.combine(step.descriptionText)
                hasher.combine(step.plannedStart)
                hasher.combine(step.plannedDurationMinutes)
                hasher.combine(step.flexibleWindowStart)
                hasher.combine(step.flexibleWindowEnd)
                hasher.combine(step.actualStart)
                hasher.combine(step.actualEnd)
                hasher.combine(step.statusRaw)
            }
        }

        for starter in starters {
            hasher.combine(starter.id)
            hasher.combine(starter.name)
            hasher.combine(starter.storageModeRaw)
            hasher.combine(starter.refreshIntervalDays)
            hasher.combine(starter.lastRefresh)
        }

        for batch in kefirBatches {
            hasher.combine(batch.id)
            hasher.combine(batch.name)
            hasher.combine(batch.lastManagedAt)
            hasher.combine(batch.expectedRoutineHours)
            hasher.combine(batch.storageModeRaw)
            hasher.combine(batch.plannedReactivationAt)
            hasher.combine(batch.archivedAt)
        }

        hasher.combine(formulas.count)
        hasher.combine(appSettings?.isBakeEnabled ?? true)
        hasher.combine(appSettings?.isStarterEnabled ?? true)
        hasher.combine(appSettings?.isKefirEnabled ?? true)
        return hasher.finalize()
    }

    private func resolvedSnapshot(for revision: Int) -> TodaySnapshot {
        if let cachedSnapshot, cachedSnapshot.revision == revision {
            return cachedSnapshot
        }
        return buildSnapshot(revision: revision)
    }

    private func buildSnapshot(revision: Int) -> TodaySnapshot {
        let settings = appSettings
        let filteredBakes = settings?.isBakeEnabled == false ? [] : Array(bakes)
        let filteredStarters = settings?.isStarterEnabled == false ? [] : Array(starters)
        let filteredKefirBatches = settings?.isKefirEnabled == false ? [] : Array(kefirBatches)
        return TodaySnapshot.make(
            revision: revision,
            bakes: filteredBakes,
            starters: filteredStarters,
            kefirBatches: filteredKefirBatches,
            formulas: Array(formulas)
        )
    }
}

private struct TodayBakeSelection: Identifiable {
    let bake: Bake
    let step: BakeStep

    var id: UUID { step.id }
}

// MARK: - Domain section grouping

private struct TodayRenderSection: Identifiable {
    enum Item {
        case feedItem(TodayAgendaItem)
        case healthyStarter(Starter)
    }
    let domain: TodayAgendaItem.Domain
    let items: [Item]
    var id: String { domain.rawValue }
}

/// Groups the feed items by domain (all items of the same domain are contiguous)
/// and appends healthy (ok) starters to the starter domain section.
/// Domain order follows the first appearance in the urgency-sorted feed.
private func renderSections(
    feed: [TodayAgendaItem],
    healthyStarters: [Starter]
) -> [TodayRenderSection] {
    var order: [TodayAgendaItem.Domain] = []
    var map: [TodayAgendaItem.Domain: [TodayRenderSection.Item]] = [:]

    for item in feed {
        if map[item.domain] == nil {
            order.append(item.domain)
            map[item.domain] = []
        }
        map[item.domain]!.append(.feedItem(item))
    }

    if !healthyStarters.isEmpty {
        if map[.starter] == nil { order.append(.starter) }
        healthyStarters.forEach { map[.starter, default: []].append(.healthyStarter($0)) }
    }

    return order.compactMap { domain in
        guard let items = map[domain], !items.isEmpty else { return nil }
        return TodayRenderSection(domain: domain, items: items)
    }
}

private struct TodaySnapshot {
    let revision: Int
    let agenda: TodayAgendaSnapshot
    let todayCount: Int
    let inProgressCount: Int
    let heroSubtitle: String
    let healthyStarters: [Starter]
    let selectionByStepID: [UUID: TodayBakeSelection]

    static func make(
        revision: Int,
        bakes: [Bake],
        starters: [Starter],
        kefirBatches: [KefirBatch],
        formulas: [RecipeFormula]
    ) -> TodaySnapshot {
        let bakeInputs = bakes.map { bake in
            TodayAgendaBakeInput(bake: bake, operational: bake.makeOperationalSnapshot())
        }

        let agenda = TodayAgendaBuilder.buildSnapshot(
            inputs: bakeInputs,
            starters: starters,
            kefirBatches: kefirBatches,
            hasPersistedData: bakes.isEmpty == false || starters.isEmpty == false || kefirBatches.isEmpty == false || formulas.isEmpty == false
        )

        let todayCount = agenda.feed.filter { $0.urgency != .preview }.count
        let inProgressCount = bakeInputs.reduce(into: 0) { count, input in
            if input.operational.derivedStatus == .inProgress {
                count += 1
            }
        }
        let healthyStarters = starters.filter { $0.dueState() == .ok }
        let selectionByStepID = bakeInputs.reduce(into: [UUID: TodayBakeSelection]()) { selections, input in
            guard let step = input.operational.activeStep else {
                return
            }
            selections[step.id] = TodayBakeSelection(bake: input.bake, step: step)
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
            let urgentItem = agenda.feed.first { $0.urgency == .overdue || $0.urgency == .warning }
            let anyItem = agenda.feed.first
            if let first = urgentItem, let summary = first.bakeSummary {
                heroSubtitle = "Hai una fase da seguire in \(summary.bakeName): \(summary.stepName)."
            } else if let first = urgentItem, first.domain == .kefir {
                heroSubtitle = "C'è un batch kefir da seguire: \(first.title)."
            } else if let first = urgentItem {
                heroSubtitle = "C'è uno starter da rinfrescare: \(first.title)."
            } else if let first = anyItem, let summary = first.bakeSummary {
                heroSubtitle = "Più tardi ti aspetta \(summary.stepName) per \(summary.bakeName)."
            } else if let first = anyItem, first.domain == .kefir {
                heroSubtitle = "Più tardi controlla \(first.title)."
            } else if let first = anyItem {
                heroSubtitle = "Oggi è previsto il rinfresco di \(first.title)."
            } else {
                heroSubtitle = "Tutto sotto controllo per ora."
            }
        }

        return TodaySnapshot(
            revision: revision,
            agenda: agenda,
            todayCount: todayCount,
            inProgressCount: inProgressCount,
            heroSubtitle: heroSubtitle,
            healthyStarters: healthyStarters,
            selectionByStepID: selectionByStepID
        )
    }

    func selection(for summary: TodayAgendaItem.BakeSummary) -> TodayBakeSelection? {
        selectionByStepID[summary.stepID]
    }
}

private struct TodayFuturePreviewCard: View {
    let preview: TodayFuturePreview
    let action: () -> Void

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                StateBadge(text: "In programma", tone: .count)

                Text("Prossima attività")
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
        case .bake:    return "Vai ai Fermenti"
        case .starter: return "Vai ai Fermenti"
        case .kefir:   return "Apri batch"
        }
    }
}

private struct TodayKefirBatchRow: View {
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
                        StateBadge(text: item.state, tone: stateTone)
                    }

                    Text(item.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)

                    Text("Prossima azione: \(item.actionTitle)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.accent)
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
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var stateTone: StateBadge.Tone {
        switch item.urgency {
        case .overdue:
            return .overdue
        case .warning:
            return .warning
        case .active, .preview:
            return .schedule
        }
    }

    private var accessibilityIdentifier: String {
        guard case let .kefir(batchID) = item.kind else {
            return "TodayKefirRow"
        }
        return "TodayKefirRow-\(batchID.uuidString)"
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
        VStack(alignment: .leading, spacing: 6) {
            // Domain label — same pattern as TodayOperationalCardView
            HStack(spacing: 5) {
                Image("navbar-starter")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Theme.accent)
                    .frame(width: 12, height: 12)
                Text("Starter")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.accent)
            }
            .padding(.leading, 2)

            SectionCard(emphasis: .tinted) {
                VStack(alignment: .leading, spacing: 12) {
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

/// Healthy (ok) starter rendered inline within the actionable feed,
/// styled as a plain card to match the other feed items.
private struct TodayHealthyStarterCard: View {
    let starter: Starter
    let onRefresh: () -> Void

    var body: some View {
        TodayStarterStatusRow(starter: starter, onRefresh: onRefresh)
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
                    action: { router.openKnowledge(nil) }
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

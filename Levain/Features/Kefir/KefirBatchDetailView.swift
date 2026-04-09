import SwiftData
import SwiftUI

struct KefirBatchDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var allBatches: [KefirBatch]
    @Query private var recentEvents: [KefirEvent]

    let batch: KefirBatch

    @State private var showingManageSheet = false
    @State private var showingArchiveConfirmation = false
    @State private var editorMode: KefirBatchEditorView.Mode?

    private let metricColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 8)
    ]

    init(batch: KefirBatch) {
        self.batch = batch
        _recentEvents = Query(KefirEvent.descriptor(for: batch.id))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                actionsCard
                recentHistoryCard
                operationalContextCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .accessibilityIdentifier("KefirBatchDetailView")
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(batch.name)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .accessibilityIdentifier("KefirBatchDetailScrollView")
        .sheet(isPresented: $showingManageSheet) {
            KefirBatchManageSheet(batch: batch)
        }
        .sheet(item: $editorMode) { mode in
            NavigationStack {
                KefirBatchEditorView(mode: mode) { newBatch in
                    router.fermentationsPath.append(.kefirBatch(newBatch.id))
                }
            }
        }
        .alert("Archivia batch", isPresented: $showingArchiveConfirmation) {
            Button("Annulla", role: .cancel) {}
            Button("Archivia", role: .destructive) {
                archiveBatch()
            }
        } message: {
            Text("Il batch resta leggibile in archivio. Puoi sempre crearne uno nuovo a partire da questo.")
        }
    }

    private var headerCard: some View {
        headerSectionCard
    }

    private var operationalContextCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Note e dettagli")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                Text(batch.operationalSummary)
                    .foregroundStyle(Theme.muted)

                if let originSummary = lineageSummary.originSummary {
                    VStack(alignment: .leading, spacing: 6) {
                        StateBadge(text: "Origine", tone: .schedule)
                        Text(originSummary)
                            .foregroundStyle(Theme.muted)
                    }
                }

                if let derivedSummary = lineageSummary.derivedSummary {
                    VStack(alignment: .leading, spacing: 6) {
                        StateBadge(text: "Derivati", tone: .info)
                        Text(derivedSummary)
                            .foregroundStyle(Theme.muted)
                    }
                }

                if let contextSummary = batch.contextSummary {
                    VStack(alignment: .leading, spacing: 6) {
                        StateBadge(text: "Come si usa", tone: .info)
                        Text(contextSummary)
                            .foregroundStyle(Theme.muted)
                    }
                }

                if batch.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    VStack(alignment: .leading, spacing: 6) {
                        StateBadge(text: "Note", tone: .info)
                        Text(batch.notes)
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
        }
    }

    private var recentHistoryCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Storia recente")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                        .accessibilityIdentifier("KefirBatchRecentHistoryTitle")

                    Spacer()

                    StateBadge(text: "\(recentEvents.count)", tone: .count)
                }

                Text("Gli ultimi movimenti di questo batch.")
                    .foregroundStyle(Theme.muted)

                if recentEvents.isEmpty {
                    Text("Qui compariranno i rinnovi, i cambi e le note.")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                } else {
                    ForEach(Array(recentEvents.prefix(3))) { event in
                        KefirEventRow(
                            event: event,
                            batchName: nil,
                            showsBatchContext: false
                        )
                    }
                }

                NavigationLink {
                    KefirJournalView(focusBatch: batch)
                } label: {
                    Label("Apri journal batch", systemImage: "clock.arrow.circlepath")
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("KefirDetailOpenJournalButton")
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityIdentifier("KefirDetailOpenJournalButton")
            }
        }
        .accessibilityIdentifier("KefirBatchRecentHistoryCard")
    }

    private var actionsCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Azioni rapide")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                Text(detailPrimaryActionPrompt)
                    .foregroundStyle(Theme.muted)

                primaryActionButton

                secondaryQuickActions
            }
        }
        .accessibilityIdentifier("KefirBatchActionsCard")
    }

    @ViewBuilder
    private var primaryActionButton: some View {
        if batch.derivedState == .overdue {
            primaryActionButtonContent
                .buttonStyle(DangerActionButtonStyle())
        } else if batch.derivedState == .archived {
            primaryActionButtonContent
                .buttonStyle(SecondaryActionButtonStyle())
        } else {
            primaryActionButtonContent
                .buttonStyle(PrimaryActionButtonStyle())
        }
    }

    private var primaryActionButtonContent: some View {
        Button(action: handlePrimaryAction) {
            primaryActionLabelView
        }
        .accessibilityIdentifier("KefirDetailPrimaryActionButton")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(detailPrimaryActionLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(.isStaticText)
    }

    private var primaryActionLabelView: some View {
        Text(detailPrimaryActionLabel)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("KefirDetailPrimaryActionButton")
    }

    @ViewBuilder
    private var headerSectionCard: some View {
        if batch.derivedState == .overdue {
            SectionCard(emphasis: .danger) {
                headerContent
            }
        } else if batch.sectionKind == .warning {
            SectionCard(emphasis: .tinted) {
                headerContent
            }
        } else {
            SectionCard {
                headerContent
            }
        }
    }

    private func quickActionButton(
        label: String,
        systemImage: String,
        accessibilityIdentifier: String,
        action: @escaping () -> Void,
        isDisabled: Bool = false
    ) -> some View {
        Button(action: action) {
            quickActionLabel(
                label: label,
                systemImage: systemImage,
                accessibilityIdentifier: accessibilityIdentifier
            )
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .disabled(isDisabled)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func quickActionLabel(
        label: String,
        systemImage: String,
        accessibilityIdentifier: String? = nil
    ) -> some View {
        HStack(spacing: 6) {
            Spacer(minLength: 0)
            Image(systemName: systemImage)
                .imageScale(.small)
            Text(label)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(accessibilityIdentifier ?? label)
    }

    private var secondaryQuickActions: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                journalQuickAction
                contextualOperationalAction
            }
            HStack(spacing: 10) {
                deriveQuickAction
                archiveQuickAction
            }
        }
    }

    private var contextualOperationalAction: some View {
        NavigationLink {
            KefirBatchComparisonView(primaryBatch: batch)
        } label: {
            quickActionLabel(
                label: "Confronta",
                systemImage: "arrow.left.arrow.right",
                accessibilityIdentifier: "KefirDetailCompareButton"
            )
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Confronta")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("KefirDetailCompareButton")
    }

    private var journalQuickAction: some View {
        NavigationLink {
            KefirJournalView(focusBatch: batch)
        } label: {
            quickActionLabel(
                label: "Journal",
                systemImage: "clock.arrow.circlepath",
                accessibilityIdentifier: "KefirDetailQuickJournalButton"
            )
        }
        .buttonStyle(SecondaryActionButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Journal")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("KefirDetailQuickJournalButton")
    }

    private var deriveQuickAction: some View {
        quickActionButton(
            label: "Nuovo batch",
            systemImage: "arrow.triangle.branch",
            accessibilityIdentifier: "KefirDetailQuickDeriveButton",
            action: deriveBatch
        )
    }

    private var archiveQuickAction: some View {
        Button(action: { showingArchiveConfirmation = true }) {
            quickActionLabel(
                label: batch.isArchived ? "Archiviato" : "Archivia",
                systemImage: "archivebox",
                accessibilityIdentifier: "KefirDetailQuickArchiveButton"
            )
        }
        .buttonStyle(DestructiveOutlineButtonStyle())
        .disabled(batch.isArchived)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(batch.isArchived ? "Archiviato" : "Archivia")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("KefirDetailQuickArchiveButton")
    }

    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(batch.name)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.ink)

                    Text(batch.statusHeadline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }

                Spacer()

                StateBadge(kefirState: batch.derivedState)
            }

            HStack(spacing: 8) {
                StateBadge(text: batch.storageMode.title, tone: .schedule)
                if batch.sourceBatchId != nil {
                    StateBadge(text: "Derivato", tone: .info)
                }
                if let derivedBadgeText = lineageSummary.derivedBadgeText {
                    StateBadge(text: derivedBadgeText, tone: .info)
                }
            }

            if let lineageCardSummary = lineageSummary.cardSummary {
                Text(lineageCardSummary)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.muted)
            }

            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Routine", value: batch.routineSummary, tone: .schedule)
                MetricChip(label: "Ultima gestione", value: batch.lastManagedSummary, tone: .schedule)
                MetricChip(label: batch.nextManagementLabel, value: batch.nextManagementSummary, tone: batch.nextManagementTone)
                MetricChip(label: "Conservazione", value: batch.storageMode.title, tone: .info)
            }
        }
    }

    private var detailPrimaryActionLabel: String {
        if batch.isArchived { return "Nuovo batch" }
        if batch.primaryAction == .reactivate { return "Riattiva" }
        return "Rinfresca"
    }

    private var detailPrimaryActionPrompt: String {
        if batch.isArchived {
            return "Il batch è in archivio: il gesto più utile qui è derivarne uno nuovo partendo dal suo contesto."
        }
        return batch.primaryActionPrompt
    }

    private func handlePrimaryAction() {
        if batch.isArchived {
            deriveBatch()
            return
        }
        if batch.primaryAction == .reactivate {
            let now = Date.now
            let previous = KefirEventRecorder.Snapshot(batch: batch)
            batch.reactivate(at: now)
            KefirEventRecorder.recordReactivation(of: batch, previous: previous, in: modelContext, at: now)
            try? modelContext.save()
            syncNotificationsAndShowBanner("Batch riattivato")
            return
        }
        showingManageSheet = true
    }

    private func deriveBatch() {
        editorMode = .derive(batch)
    }

    private func archiveBatch() {
        let now = Date.now
        batch.archive(at: now)
        KefirEventRecorder.recordArchive(of: batch, in: modelContext, at: now)
        try? modelContext.save()
        syncNotificationsAndShowBanner("Batch archiviato")
    }

    private var lineageSummary: KefirBatchLineageSummary {
        lineageIndex.lineageSummary(for: batch)
    }

    private var lineageIndex: KefirLineageIndex {
        KefirLineageIndex(batches: allBatches)
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

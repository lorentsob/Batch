import SwiftData
import SwiftUI

struct KefirJournalView: View {
    private struct RenderState {
        let archivedBatches: [KefirBatch]
        let journalSections: [KefirJournalDaySection]
        let lineageIndex: KefirLineageIndex
    }

    @EnvironmentObject private var router: AppRouter
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var allBatches: [KefirBatch]
    @Query private var events: [KefirEvent]

    let focusBatch: KefirBatch?

    init(focusBatch: KefirBatch? = nil) {
        self.focusBatch = focusBatch

        if let focusBatch {
            _events = Query(KefirEvent.descriptor(for: focusBatch.id))
        } else {
            _events = Query(KefirEvent.timelineDescriptor)
        }
    }

    var body: some View {
        let renderState = makeRenderState()

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard(renderState: renderState)

                if showArchiveLibrary(renderState: renderState) {
                    archiveLibraryCard(
                        archivedBatches: renderState.archivedBatches,
                        lineageIndex: renderState.lineageIndex
                    )
                }

                timelineSection(
                    journalSections: renderState.journalSections,
                    lineageIndex: renderState.lineageIndex
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .accessibilityIdentifier("KefirJournalView")
        }
        .accessibilityIdentifier("KefirJournalScrollView")
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(focusBatch == nil ? "Cronologia kefir" : "Storia batch")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
    }

    @ViewBuilder
    private func headerCard(renderState: RenderState) -> some View {
        if let focusBatch {
            SectionCard(emphasis: focusBatch.cardEmphasis) {
                headerBody(renderState: renderState)
            }
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .stroke(Theme.Border.danger, lineWidth: focusBatch.derivedState == .overdue ? 1.5 : 0)
            )
            .accessibilityIdentifier("KefirJournalHeaderCard")
        } else {
            SectionCard(emphasis: .tinted) {
                headerBody(renderState: renderState)
            }
            .accessibilityIdentifier("KefirJournalHeaderCard")
        }
    }

    private func archiveLibraryCard(
        archivedBatches: [KefirBatch],
        lineageIndex: KefirLineageIndex
    ) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Batch archiviati")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    Spacer()

                    StateBadge(text: "\(archivedBatches.count)", tone: .count)
                }

                Text("Puoi aprirli, confrontarli o usarli come base per un nuovo batch.")
                    .foregroundStyle(Theme.muted)

                ForEach(archivedBatches) { batch in
                    archiveBatchRow(batch, lineageIndex: lineageIndex)
                }

                NavigationLink {
                    KefirArchiveView()
                } label: {
                    Label("Vai all'archivio completo", systemImage: "archivebox")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityIdentifier("KefirJournalOpenArchiveButton")
            }
        }
        .accessibilityIdentifier("KefirJournalArchiveSection")
    }

    @ViewBuilder
    private func timelineSection(
        journalSections: [KefirJournalDaySection],
        lineageIndex: KefirLineageIndex
    ) -> some View {
        if journalSections.isEmpty {
            SectionCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nessun evento ancora")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text("Qui compariranno i rinnovi, i cambi e le note.")
                        .foregroundStyle(Theme.muted)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text("Timeline")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                ForEach(journalSections) { section in
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(section.title)
                                    .font(.headline)
                                    .foregroundStyle(Theme.ink)

                                Spacer()

                                StateBadge(text: "\(section.events.count)", tone: .count)
                            }

                            ForEach(section.events) { event in
                                KefirEventRow(
                                    event: event,
                                    batchName: lineageIndex.batchName(id: event.batchID),
                                    showsBatchContext: focusBatch == nil,
                                    onOpenBatch: openBatchAction(for: event.batchID, lineageIndex: lineageIndex)
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private func archiveBatchRow(
        _ batch: KefirBatch,
        lineageIndex: KefirLineageIndex
    ) -> some View {
        Button {
            router.fermentationsPath.append(.kefirBatch(batch.id))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(batch.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)

                    if let summary = lineageIndex.lineageSummary(for: batch).cardSummary {
                        Text(summary)
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                    }

                    Text(batch.operationalSummary)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .fill(Theme.Surface.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .stroke(Theme.Border.emphasis, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("KefirJournalArchivedBatch-\(batch.accessibilityStem)")
    }

    private func openBatchAction(
        for batchID: UUID,
        lineageIndex: KefirLineageIndex
    ) -> (() -> Void)? {
        guard focusBatch == nil, lineageIndex.batch(id: batchID) != nil else {
            return nil
        }

        return {
            router.fermentationsPath.append(.kefirBatch(batchID))
        }
    }

    private var headerTitle: String {
        if let focusBatch {
            return focusBatch.name
        }
        return "Cronologia e archivio"
    }

    private var headerMessage: String {
        if focusBatch != nil {
            return "La storia completa di questo batch."
        }
        return "Tieni traccia dei rinfreschi dei tuoi batch"
    }

    private func headerSummary(renderState: RenderState) -> String? {
        if let focusBatch {
            let lineageSummary = renderState.lineageIndex.lineageSummary(for: focusBatch)
            return [lineageSummary.cardSummary, focusBatch.contextSummary]
                .compactMap { $0 }
                .joined(separator: " · ")
                .nilIfEmpty
        }

        guard let latestEvent = events.first else {
            return nil
        }

        return "Ultimo rinfresco: \(latestEvent.presentation(batchName: renderState.lineageIndex.batchName(id: latestEvent.batchID)).title)."
    }

    private func makeRenderState() -> RenderState {
        let lineageIndex = KefirLineageIndex(batches: allBatches)

        return RenderState(
            archivedBatches: focusBatch == nil ? allBatches.filter(\.isArchived) : [],
            journalSections: events.journalSections,
            lineageIndex: lineageIndex
        )
    }

    private func showArchiveLibrary(renderState: RenderState) -> Bool {
        focusBatch == nil && renderState.archivedBatches.isEmpty == false
    }

    private func headerBody(renderState: RenderState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(headerTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.ink)

            Text(headerMessage)
                .foregroundStyle(Theme.muted)

            HStack(spacing: 8) {
                StateBadge(text: "\(events.count) eventi", tone: .count)

                if let focusBatch {
                    StateBadge(kefirState: focusBatch.derivedState)
                    StateBadge(text: focusBatch.storageMode.title, tone: .schedule)
                } else if renderState.archivedBatches.isEmpty == false {
                    StateBadge(text: "\(renderState.archivedBatches.count) in archivio", tone: .done)
                }
            }

            if let summary = headerSummary(renderState: renderState) {
                Text(summary)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.muted)
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

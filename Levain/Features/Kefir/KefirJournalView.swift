import SwiftData
import SwiftUI

struct KefirJournalView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if showArchiveLibrary {
                    archiveLibraryCard
                }

                timelineSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .accessibilityIdentifier("KefirJournalView")
        }
        .accessibilityIdentifier("KefirJournalScrollView")
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(focusBatch == nil ? "Journal kefir" : "Storia batch")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
    }

    @ViewBuilder
    private var headerCard: some View {
        if let focusBatch, focusBatch.derivedState == .overdue {
            SectionCard(emphasis: .danger) {
                headerBody
            }
            .accessibilityIdentifier("KefirJournalHeaderCard")
        } else if let focusBatch, focusBatch.sectionKind == .warning {
            SectionCard(emphasis: .tinted) {
                headerBody
            }
            .accessibilityIdentifier("KefirJournalHeaderCard")
        } else if focusBatch == nil {
            SectionCard(emphasis: .tinted) {
                headerBody
            }
            .accessibilityIdentifier("KefirJournalHeaderCard")
        } else {
            SectionCard {
                headerBody
            }
            .accessibilityIdentifier("KefirJournalHeaderCard")
        }
    }

    private var archiveLibraryCard: some View {
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
                    archiveBatchRow(batch)
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
    private var timelineSection: some View {
        if events.isEmpty {
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

                ForEach(events.journalSections) { section in
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
                                    batchName: batchNameMap[event.batchID],
                                    showsBatchContext: focusBatch == nil,
                                    onOpenBatch: openBatchAction(for: event.batchID)
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private func archiveBatchRow(_ batch: KefirBatch) -> some View {
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

    private func openBatchAction(for batchID: UUID) -> (() -> Void)? {
        guard focusBatch == nil, batchNameMap[batchID] != nil else {
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
        return "Journal e archivio"
    }

    private var headerMessage: String {
        if focusBatch != nil {
            return "La storia completa di questo batch."
        }
        return "Tutti i movimenti dei tuoi batch, in ordine."
    }

    private var headerSummary: String? {
        if let focusBatch {
            let lineageSummary = lineageIndex.lineageSummary(for: focusBatch)
            return [lineageSummary.cardSummary, focusBatch.contextSummary]
                .compactMap { $0 }
                .joined(separator: " · ")
                .nilIfEmpty
        }

        guard let latestEvent = events.first else {
            return nil
        }

        return "Ultimo passaggio: \(latestEvent.presentation(batchName: batchNameMap[latestEvent.batchID]).title)."
    }

    private var archivedBatches: [KefirBatch] {
        allBatches.filter(\.isArchived)
    }

    private var showArchiveLibrary: Bool {
        focusBatch == nil && archivedBatches.isEmpty == false
    }

    private var batchNameMap: [UUID: String] {
        allBatches.reduce(into: [UUID: String]()) { result, batch in
            result[batch.id] = batch.name
        }
    }

    private var lineageIndex: KefirLineageIndex {
        KefirLineageIndex(batches: allBatches)
    }

    private var headerBody: some View {
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
                } else if archivedBatches.isEmpty == false {
                    StateBadge(text: "\(archivedBatches.count) in archivio", tone: .done)
                }
            }

            if let summary = headerSummary {
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

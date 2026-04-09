import SwiftData
import SwiftUI

/// Dedicated archive surface: browse, review, and reuse archived kefir batches.
struct KefirArchiveView: View {
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var allBatches: [KefirBatch]
    @State private var editorMode: KefirBatchEditorView.Mode?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if archivedBatches.isEmpty {
                    emptyCard
                } else {
                    ForEach(archivedBatches) { batch in
                        archiveBatchCard(batch)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .accessibilityIdentifier("KefirArchiveView")
        }
        .accessibilityIdentifier("KefirArchiveScrollView")
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Archivio kefir")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .sheet(item: $editorMode) { mode in
            NavigationStack {
                KefirBatchEditorView(mode: mode) { newBatch in
                    router.fermentationsPath.append(.kefirBatch(newBatch.id))
                }
            }
        }
    }

    private var archivedBatches: [KefirBatch] {
        allBatches.filter(\.isArchived).sorted { lhs, rhs in
            let l = lhs.archivedAt ?? lhs.lastManagedAt
            let r = rhs.archivedAt ?? rhs.lastManagedAt
            return l > r
        }
    }

    private var headerCard: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Archivio kefir")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.ink)

                Text("Puoi rileggere la storia di ogni batch e usarlo come base per uno nuovo.")
                    .foregroundStyle(Theme.muted)

                StateBadge(text: "\(archivedBatches.count) archiviati", tone: .count)
            }
        }
        .accessibilityIdentifier("KefirArchiveHeaderCard")
    }

    private var emptyCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Nessun batch in archivio")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                Text("I batch che archivi restano qui. Puoi rileggere e ripartire da qualsiasi momento.")
                    .foregroundStyle(Theme.muted)
            }
        }
        .accessibilityIdentifier("KefirArchiveEmptyCard")
    }

    private func archiveBatchCard(_ batch: KefirBatch) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(batch.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)

                        Text(batch.operationalSummary)
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    StateBadge(kefirState: batch.derivedState)
                }

                if let cardSummary = lineageIndex.lineageSummary(for: batch).cardSummary {
                    Text(cardSummary)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.muted)
                }

                if let contextSummary = batch.contextSummary {
                    Text(contextSummary)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }

                Button {
                    router.fermentationsPath.append(.kefirBatch(batch.id))
                } label: {
                    Label("Rileggi", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityIdentifier("KefirArchiveOpenButton-\(batch.accessibilityStem)")

                Button {
                    editorMode = .derive(batch)
                } label: {
                    Label("Nuovo batch", systemImage: "arrow.triangle.branch")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .accessibilityIdentifier("KefirArchiveDeriveButton-\(batch.accessibilityStem)")
            }
        }
        .accessibilityIdentifier("KefirArchiveBatchCard-\(batch.accessibilityStem)")
    }

    private var lineageIndex: KefirLineageIndex {
        KefirLineageIndex(batches: allBatches)
    }
}

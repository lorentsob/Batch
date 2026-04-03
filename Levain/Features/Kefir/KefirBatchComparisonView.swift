import SwiftData
import SwiftUI

/// Lightweight comparison surface for lineage-related kefir batches.
/// Shows source and derived siblings alongside the primary batch for quick orientation.
struct KefirBatchComparisonView: View {
    let primaryBatch: KefirBatch

    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var allBatches: [KefirBatch]
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                primaryCard

                if let source = lineageIndex.sourceBatch(for: primaryBatch) {
                    sourceSection(source)
                }

                if derivedBatches.isEmpty == false {
                    derivedSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .accessibilityIdentifier("KefirBatchComparisonView")
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Confronto batch")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
    }

    private var lineageSummary: KefirBatchLineageSummary {
        lineageIndex.lineageSummary(for: primaryBatch)
    }

    private var derivedBatches: [KefirBatch] {
        lineageIndex.derivedBatches(for: primaryBatch)
    }

    private var lineageIndex: KefirLineageIndex {
        KefirLineageIndex(batches: allBatches)
    }

    private var headerCard: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Confronto batch")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.ink)

                Text("Confronta questo batch con l'origine e i derivati.")
                    .foregroundStyle(Theme.muted)

                if let cardSummary = lineageSummary.cardSummary {
                    Text(cardSummary)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.muted)
                }
            }
        }
        .accessibilityIdentifier("KefirComparisonHeaderCard")
    }

    private var primaryCard: some View {
        SectionCard(emphasis: .tinted) {
            comparisonCardBody(
                for: primaryBatch,
                role: "Batch corrente",
                isPrimary: true
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Batch corrente \(primaryBatch.name)")
            .accessibilityIdentifier("KefirComparisonPrimaryCard")
        }
    }

    private func sourceSection(_ batch: KefirBatch) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Origine")
                .font(.headline)
                .foregroundStyle(Theme.ink)

            comparisonCard(
                for: batch,
                role: "Origine",
                isPrimary: false,
                accessibilityIdentifier: "KefirComparisonSourceCard"
            )
        }
        .accessibilityIdentifier("KefirComparisonSourceSection")
    }

    private var derivedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Derivati")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                StateBadge(text: "\(derivedBatches.count)", tone: .count)
            }

            ForEach(derivedBatches) { batch in
                comparisonCard(
                    for: batch,
                    role: "Derivato",
                    isPrimary: false,
                    accessibilityIdentifier: "KefirComparisonDerivedCard-\(batch.accessibilityStem)"
                )
            }
        }
        .accessibilityIdentifier("KefirComparisonDerivedSection")
    }

    @ViewBuilder
    private func comparisonCard(
        for batch: KefirBatch,
        role: String,
        isPrimary: Bool,
        accessibilityIdentifier: String? = nil
    ) -> some View {
        let card = SectionCard(emphasis: isPrimary ? .tinted : .subtle) {
            comparisonCardBody(for: batch, role: role, isPrimary: isPrimary)
        }

        if let accessibilityIdentifier {
            card
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(accessibilityIdentifier)
        } else {
            card
        }
    }

    private func comparisonCardBody(for batch: KefirBatch, role: String, isPrimary: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    StateBadge(text: role, tone: isPrimary ? .running : .info)
                    if isPrimary {
                        Text(batch.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .accessibilityIdentifier("KefirComparisonPrimaryCard")
                    } else {
                        Text(batch.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                    }
                }
                Spacer()
                StateBadge(kefirState: batch.derivedState)
            }

            Text(batch.statusHeadline)
                .font(.footnote)
                .foregroundStyle(Theme.muted)

            if let contextSummary = batch.contextSummary {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Come si usa")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Text(contextSummary)
                        .font(.footnote)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("KefirComparisonContextText")
                }
            }

            if batch.id != primaryBatch.id {
                Button {
                    router.fermentationsPath.append(.kefirBatch(batch.id))
                } label: {
                    Label("Apri batch", systemImage: "arrow.right.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityIdentifier("KefirComparisonOpenBatchButton-\(batch.accessibilityStem)")
            }
        }
    }
}

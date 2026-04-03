import SwiftUI

struct KefirBatchCardView: View {
    let batch: KefirBatch
    let lineageSummary: KefirBatchLineageSummary
    let onOpen: () -> Void

    private let metricColumns = [
        GridItem(.adaptive(minimum: 122), spacing: 8)
    ]

    var body: some View {
        sectionCard
            .accessibilityIdentifier("KefirBatchCard-\(batch.accessibilityStem)")
    }

    @ViewBuilder
    private var primaryCTA: some View {
        if batch.derivedState == .overdue {
            Button(action: onOpen) {
                Label(batch.primaryNavigationLabel, systemImage: batch.primaryActionSystemImage)
            }
            .buttonStyle(DangerActionButtonStyle())
            .accessibilityIdentifier("KefirBatchPrimaryCTA-\(batch.accessibilityStem)")
        } else if batch.derivedState == .archived {
            Button(action: onOpen) {
                Label(batch.primaryNavigationLabel, systemImage: batch.primaryActionSystemImage)
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .accessibilityIdentifier("KefirBatchPrimaryCTA-\(batch.accessibilityStem)")
        } else {
            Button(action: onOpen) {
                Label(batch.primaryNavigationLabel, systemImage: batch.primaryActionSystemImage)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .accessibilityIdentifier("KefirBatchPrimaryCTA-\(batch.accessibilityStem)")
        }
    }

    @ViewBuilder
    private var sectionCard: some View {
        if batch.derivedState == .overdue {
            SectionCard(emphasis: .danger) {
                cardContent
            }
        } else if batch.sectionKind == .warning {
            SectionCard(emphasis: .tinted) {
                cardContent
            }
        } else {
            SectionCard {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(batch.name)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if let contextSummary = batch.contextSummary {
                        Text(contextSummary)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }

                    if let lineageCardSummary = lineageSummary.cardSummary {
                        Text(lineageCardSummary)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Theme.muted)
                    }
                }

                Spacer()

                Button(action: onOpen) {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("KefirBatchOpenButton-\(batch.accessibilityStem)")
            }

            HStack(spacing: 8) {
                StateBadge(kefirState: batch.derivedState)
                StateBadge(text: batch.storageMode.title, tone: .schedule)
                if batch.sourceBatchId != nil {
                    StateBadge(text: "Derivato", tone: .info)
                }
                if let derivedBadgeText = lineageSummary.derivedBadgeText {
                    StateBadge(text: derivedBadgeText, tone: .info)
                }
            }

            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Ultima gestione", value: batch.lastManagedSummary, tone: .schedule)
                MetricChip(label: batch.nextManagementLabel, value: batch.nextManagementSummary, tone: batch.nextManagementTone)
            }

            Text(batch.operationalSummary)
                .font(.footnote)
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)

            primaryCTA
        }
    }
}

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
        SectionCard(emphasis: cardEmphasis) {
            cardContent
        }
        .overlay(overdueOutline)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(batch.name)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Text.primary)
                        .layoutPriority(1)

                    if let contextSummary = batch.contextSummary {
                        Text(contextSummary)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Text.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let lineageCardSummary = lineageSummary.cardSummary {
                        Text(lineageCardSummary)
                            .font(Theme.Typography.footnoteSemibold)
                            .foregroundStyle(Theme.Text.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
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
                StateBadge(text: batch.storageMode.title, tone: .info)
                if batch.sourceBatchId != nil {
                    StateBadge(text: "Derivato", tone: .info)
                }
                if let derivedBadgeText = lineageSummary.derivedBadgeText {
                    StateBadge(text: derivedBadgeText, tone: .info)
                }
            }

            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Ultimo rinfresco", value: batch.lastManagedSummary, tone: .done)
                MetricChip(label: batch.nextManagementLabel, value: batch.nextManagementSummary, tone: batch.nextManagementTone)
            }

            Text(batch.operationalSummary)
                .font(Theme.Typography.footnote)
                .foregroundStyle(batch.derivedState == .overdue ? Theme.Text.onDanger : Theme.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)

            primaryCTA
        }
    }

    private var cardEmphasis: SectionCardEmphasis {
        switch batch.derivedState {
        case .overdue:
            return .surface
        case .dueSoon, .dueNow:
            return .tinted
        case .active, .pausedFridge, .pausedFreezer, .archived:
            return .surface
        }
    }

    private var overdueOutline: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
            .stroke(Theme.Border.danger, lineWidth: batch.derivedState == .overdue ? 1.5 : 0)
    }
}

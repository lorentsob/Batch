import SwiftUI

struct KefirEventRow: View {
    let event: KefirEvent
    let batchName: String?
    var showsBatchContext: Bool = true
    var onOpenBatch: (() -> Void)? = nil

    private var presentation: KefirEventPresentation {
        event.presentation(batchName: batchName)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                topMeta

                VStack(alignment: .leading, spacing: 6) {
                    Text(presentation.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)

                    if let detail = presentation.detail {
                        Text(detail)
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let secondaryText = presentation.secondaryText {
                        Text(secondaryText)
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if let onOpenBatch {
                Button(action: onOpenBatch) {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                        .padding(.top, 4)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("KefirEventOpenBatchButton")
            }
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
        .accessibilityIdentifier("KefirEventRow")
    }

    private var topMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            StateBadge(text: presentation.badgeText, tone: presentation.badgeTone)

            if showsBatchContext, let batchName, batchName.isEmpty == false {
                StateBadge(text: batchName, tone: .count)
            }

            Spacer(minLength: 12)

            Text(event.timestampSummary)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.trailing)
        }
    }
}

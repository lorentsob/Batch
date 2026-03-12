import SwiftUI

/// Shows a compact list of related knowledge tips, positioned as secondary/supportive content.
/// Opening a tip navigates to the shared article detail used by the Knowledge tab, ensuring
/// one consistent article destination across browse and contextual entry points.
struct TipGroupView: View {
    let title: String
    let items: [KnowledgeItem]
    let onOpen: (String) -> Void

    init(
        title: String = "Guide utili",
        items: [KnowledgeItem],
        onOpen: @escaping (String) -> Void
    ) {
        self.title = title
        self.items = Array(items.prefix(3))
        self.onOpen = onOpen
    }

    var body: some View {
        if !items.isEmpty {
            SectionCard(emphasis: .subtle) {
                HStack(alignment: .center) {
                    StateBadge(text: title, tone: .info)
                    Spacer()
                    Image(systemName: "lightbulb.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.Control.primaryFill)
                }

                ForEach(items) { item in
                    Button {
                        onOpen(item.id)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.ink)
                                    .lineLimit(2)
                                Text(item.summary)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.muted)
                                .padding(.top, 3)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                                .fill(Theme.Surface.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                                .stroke(Theme.Border.defaultColor, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

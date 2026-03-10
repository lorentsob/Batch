import SwiftUI

struct KnowledgeDetailView: View {
    let item: KnowledgeItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header articolo
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.category.title.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                    Text(item.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Theme.ink)
                }
                .padding(.horizontal, 20)

                // Corpo
                Text(item.content)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)

                // Tags
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(item.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.muted)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.panel)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.bottom, 64)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

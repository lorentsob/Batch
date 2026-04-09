import SwiftUI

struct KnowledgeDetailView: View {
    let item: KnowledgeItem

    @Environment(\.knowledgePresentationContext) private var presentationContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    private var glossaryIndex: KnowledgeGlossaryIndex {
        environment.knowledgeLibrary.glossaryIndex
    }

    private var isContextualSheet: Bool {
        presentationContext == .contextualSheet
    }

    private var relatedItems: [KnowledgeItem] {
        environment.knowledgeLibrary.relatedItems(for: item)
    }

    var body: some View {
        ScrollView {
            content
        }
        .accessibilityIdentifier("KnowledgeDetailView")
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        if isContextualSheet {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                SectionCard(emphasis: .surface, padding: Theme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md + 2) {
                        headerBlock
                        bodyBlock

                        if !item.tags.isEmpty {
                            tagsBlock
                        }
                    }
                }

                if !relatedItems.isEmpty {
                    TipGroupView(title: "Articoli correlati", items: relatedItems) { id in
                        router.openKnowledge(id)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.xl)
        } else {
            VStack(alignment: .leading, spacing: 24) {
                headerBlock
                bodyBlock

                if !item.tags.isEmpty {
                    tagsBlock
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .padding(.bottom, 64)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.category.title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
            Text(item.title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
                .accessibilityIdentifier("KnowledgeDetailTitle-\(item.id)")
        }
    }

    private var bodyBlock: some View {
        GlossaryLinkedText(
            text: item.content,
            glossaryIndex: glossaryIndex,
            maxLinks: 3,
            excludedArticleIDs: [item.id],
            onOpenKnowledge: router.openKnowledge
        )
        .font(.body)
        .foregroundStyle(Theme.ink)
        .lineSpacing(6)
    }

    private var tagsBlock: some View {
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
        }
    }
}

enum KnowledgePresentationContext {
    case standard
    case contextualSheet
}

private struct KnowledgePresentationContextKey: EnvironmentKey {
    static let defaultValue: KnowledgePresentationContext = .standard
}

extension EnvironmentValues {
    var knowledgePresentationContext: KnowledgePresentationContext {
        get { self[KnowledgePresentationContextKey.self] }
        set { self[KnowledgePresentationContextKey.self] = newValue }
    }
}

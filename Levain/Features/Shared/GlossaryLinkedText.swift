import SwiftUI

struct GlossaryLinkedText: View {
    let text: String
    let glossaryIndex: KnowledgeGlossaryIndex
    var maxLinks: Int = 2
    var excludedArticleIDs: Set<String> = []
    var onOpenKnowledge: ((String) -> Void)? = nil

    private var attributedText: AttributedString {
        var attributed = AttributedString(text)
        let matches = glossaryIndex.matches(in: text, maxMatches: max(maxLinks * 2, maxLinks))
            .filter { excludedArticleIDs.contains($0.articleID) == false }
            .prefix(maxLinks)

        for match in matches {
            guard let url = URL(string: AppRouter.DeepLink.knowledge(id: match.articleID)),
                  let attributedRange = Range(match.range, in: attributed)
            else {
                continue
            }

            attributed[attributedRange].link = url
            attributed[attributedRange].foregroundColor = Theme.Control.primaryFill
            attributed[attributedRange].font = .body.weight(.semibold)
            attributed[attributedRange][GlossaryChipAttribute.self] = true
        }

        return attributed
    }

    var body: some View {
        Text(attributedText)
            .tint(Theme.Control.primaryFill)
            .textRenderer(GlossaryChipTextRenderer())
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == AppRouter.DeepLink.scheme,
                      url.host == "knowledge"
                else {
                    return .systemAction
                }

                let pathComponents = url.pathComponents.filter { $0 != "/" }
                guard let articleID = pathComponents.first else {
                    return .discarded
                }

                onOpenKnowledge?(articleID)
                return .handled
            })
    }
}

private struct GlossaryChipTextRenderer: TextRenderer {
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                if run[GlossaryChipAttribute.self] != nil {
                    let bounds = run.typographicBounds.rect
                    let chipRect = CGRect(
                        x: bounds.minX - 5,
                        y: bounds.minY - 2.5,
                        width: bounds.width + 10,
                        height: bounds.height + 5
                    )

                    let chipShape = RoundedRectangle(
                        cornerRadius: 7,
                        style: .continuous
                    )

                    context.fill(
                        chipShape.path(in: chipRect),
                        with: .color(Theme.Surface.running.opacity(0.78))
                    )
                    context.stroke(
                        chipShape.path(in: chipRect),
                        with: .color(Theme.Border.emphasis),
                        lineWidth: 1
                    )
                }

                context.draw(run)
            }
        }
    }
}

private enum GlossaryChipAttribute: AttributedStringKey, TextAttribute {
    typealias Value = Bool
    static let name = "GlossaryChipAttribute"
}

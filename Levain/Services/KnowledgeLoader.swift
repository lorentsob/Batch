import Foundation

enum KnowledgeLoader {
    static func loadKnowledgeItems(bundle: Bundle = Bundle(for: KnowledgeLoaderClass.self)) -> [KnowledgeItem] {
        guard
            let url = bundle.url(forResource: "knowledge", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([KnowledgeItem].self, from: data)
        else {
            return []
        }
        return items
    }
}

/// Anchor class used by KnowledgeLoader to locate the correct bundle at runtime.
/// This resolves the bundle whether called from the main app or from a test host that
/// links against the Levain target (where Bundle.main would be the XCTest runner bundle).
private final class KnowledgeLoaderClass {}



@MainActor
final class KnowledgeLibrary: ObservableObject {
    @Published private(set) var items: [KnowledgeItem] = []
    private(set) var glossaryIndex: KnowledgeGlossaryIndex = .empty
    private var itemsByID: [String: KnowledgeItem] = [:]
    private var itemsByCategory: [KnowledgeCategory: [KnowledgeItem]] = [:]
    private var tipsByStepType: [String: [KnowledgeItem]] = [:]
    private var tipsByStarterState: [String: [KnowledgeItem]] = [:]
    private var preloadTask: Task<Void, Never>?

    func loadIfNeeded() {
        guard items.isEmpty, preloadTask == nil else { return }
        applyLoadedItems(KnowledgeLoader.loadKnowledgeItems())
    }

    func preloadIfNeeded() {
        guard items.isEmpty, preloadTask == nil else { return }

        preloadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.preloadTask = nil }

            let loadedItems = await Task.detached(priority: .utility) {
                KnowledgeLoader.loadKnowledgeItems()
            }.value

            self.applyLoadedItems(loadedItems)
        }
    }

    func item(id: String) -> KnowledgeItem? {
        itemsByID[id]
    }

    func item(matchingGlossaryTerm term: String) -> KnowledgeItem? {
        guard let id = glossaryIndex.articleID(for: term) else { return nil }
        return itemsByID[id]
    }

    func items(in category: KnowledgeCategory) -> [KnowledgeItem] {
        itemsByCategory[category] ?? []
    }

    func searchResults(matching query: String, in category: KnowledgeCategory? = nil) -> [KnowledgeItem] {
        let candidateItems: [KnowledgeItem]
        if let category {
            candidateItems = items(in: category)
        } else {
            candidateItems = items
        }

        let normalizedQuery = KnowledgeGlossaryIndex.normalize(term: query)
        guard normalizedQuery.isEmpty == false else { return candidateItems }

        return candidateItems
            .compactMap { item -> (item: KnowledgeItem, score: Int)? in
                guard let score = searchScore(for: item, normalizedQuery: normalizedQuery) else {
                    return nil
                }
                return (item: item, score: score)
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.item.title.localizedCaseInsensitiveCompare(rhs.item.title) == .orderedAscending
                }
                return lhs.score > rhs.score
            }
            .map(\.item)
    }

    func tips(for stepType: BakeStepType) -> [KnowledgeItem] {
        tipsByStepType[stepType.rawValue] ?? []
    }

    func tips(for starterState: StarterDueState) -> [KnowledgeItem] {
        tipsByStarterState[starterState.rawValue] ?? []
    }

    func relatedItems(for item: KnowledgeItem, limit: Int = 3) -> [KnowledgeItem] {
        let normalizedTags = Set(item.tags.map(KnowledgeGlossaryIndex.normalize(term:)))
        let relatedStepTypes = Set(item.relatedStepTypes)
        let relatedStarterStates = Set(item.relatedStarterStates)
        let directMentionedIDs = Set(
            glossaryIndex.matches(in: item.content, maxMatches: max(items.count, limit * 3))
                .map(\.articleID)
        )

        return items
            .compactMap { candidate -> (item: KnowledgeItem, score: Int)? in
                guard candidate.id != item.id else { return nil }

                let candidateNormalizedTags = Set(candidate.tags.map(KnowledgeGlossaryIndex.normalize(term:)))
                let sharedTags = normalizedTags.intersection(candidateNormalizedTags)
                let sharedStepTypes = relatedStepTypes.intersection(candidate.relatedStepTypes)
                let sharedStarterStates = relatedStarterStates.intersection(candidate.relatedStarterStates)

                var score = 0

                if directMentionedIDs.contains(candidate.id) {
                    score += 600
                }
                if candidate.category == item.category {
                    score += 180
                }

                score += sharedTags.count * 90
                score += sharedStepTypes.count * 70
                score += sharedStarterStates.count * 70

                guard score > 0 else { return nil }
                return (candidate, score)
            }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.item.title.localizedCaseInsensitiveCompare(rhs.item.title) == .orderedAscending
                }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map(\.item)
    }

    private func searchScore(for item: KnowledgeItem, normalizedQuery: String) -> Int? {
        let title = KnowledgeGlossaryIndex.normalize(term: item.title)
        let aliases = item.aliases.map(KnowledgeGlossaryIndex.normalize(term:))
        let tags = item.tags.map(KnowledgeGlossaryIndex.normalize(term:))
        let summary = KnowledgeGlossaryIndex.normalize(term: item.summary)
        let content = KnowledgeGlossaryIndex.normalize(term: item.content)

        if title == normalizedQuery { return 1_000 }
        if aliases.contains(normalizedQuery) { return 950 }
        if tags.contains(normalizedQuery) { return 900 }
        if title.contains(normalizedQuery) { return 800 }
        if aliases.contains(where: { $0.contains(normalizedQuery) }) { return 750 }
        if tags.contains(where: { $0.contains(normalizedQuery) }) { return 700 }
        if summary.contains(normalizedQuery) { return 600 }
        if content.contains(normalizedQuery) { return 500 }
        return nil
    }

    private func applyLoadedItems(_ loadedItems: [KnowledgeItem]) {
        items = loadedItems
        itemsByID = Dictionary(uniqueKeysWithValues: loadedItems.map { ($0.id, $0) })
        itemsByCategory = Dictionary(grouping: loadedItems, by: \.category)
        glossaryIndex = KnowledgeGlossaryIndex(items: loadedItems)

        tipsByStepType = Dictionary(
            grouping: loadedItems.flatMap { item in
                item.relatedStepTypes.map { ($0, item) }
            },
            by: \.0
        ).mapValues { $0.map(\.1) }

        tipsByStarterState = Dictionary(
            grouping: loadedItems.flatMap { item in
                item.relatedStarterStates.map { ($0, item) }
            },
            by: \.0
        ).mapValues { $0.map(\.1) }
    }
}

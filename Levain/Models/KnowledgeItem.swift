import Foundation

struct KnowledgeItem: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: String
    var category: KnowledgeCategory
    var tags: [String]
    var aliases: [String]
    var summary: String
    var content: String
    var relatedStepTypes: [String]
    var relatedStarterStates: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case tags
        case aliases
        case summary
        case content
        case relatedStepTypes
        case relatedStarterStates
    }

    init(
        id: String,
        title: String,
        category: KnowledgeCategory,
        tags: [String] = [],
        aliases: [String] = [],
        summary: String,
        content: String,
        relatedStepTypes: [String] = [],
        relatedStarterStates: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.tags = tags
        self.aliases = aliases
        self.summary = summary
        self.content = content
        self.relatedStepTypes = relatedStepTypes
        self.relatedStarterStates = relatedStarterStates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(KnowledgeCategory.self, forKey: .category)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        aliases = try container.decodeIfPresent([String].self, forKey: .aliases) ?? []
        summary = try container.decode(String.self, forKey: .summary)
        content = try container.decode(String.self, forKey: .content)
        relatedStepTypes = try container.decodeIfPresent([String].self, forKey: .relatedStepTypes) ?? []
        relatedStarterStates = try container.decodeIfPresent([String].self, forKey: .relatedStarterStates) ?? []
    }

    var glossaryTerms: [String] {
        var seen = Set<String>()
        var terms: [String] = []

        for raw in [title] + aliases {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false else { continue }

            let normalized = KnowledgeGlossaryIndex.normalize(term: trimmed)
            guard normalized.isEmpty == false, seen.insert(normalized).inserted else { continue }
            terms.append(trimmed)
        }

        return terms
    }
}

import Foundation

struct KnowledgeItem: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var category: KnowledgeCategory
    var tags: [String]
    var summary: String
    var content: String
    var relatedStepTypes: [String]
    var relatedStarterStates: [String]
}


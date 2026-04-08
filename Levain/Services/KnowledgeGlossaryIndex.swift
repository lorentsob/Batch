import Foundation
import SwiftUI

struct KnowledgeGlossaryIndex: Sendable {
    struct Match: Sendable, Equatable {
        let articleID: String
        let articleTitle: String
        let matchedTerm: String
        let range: Range<String.Index>
    }

    static let empty = KnowledgeGlossaryIndex(items: [])

    private struct Entry: Sendable {
        let term: String
        let normalizedTerm: String
        let articleID: String
        let articleTitle: String
        let regex: NSRegularExpression?
    }

    private let entries: [Entry]
    private let articleIDsByNormalizedTerm: [String: String]

    init(items: [KnowledgeItem]) {
        var uniqueEntries: [String: Entry] = [:]
        var idsByNormalizedTerm: [String: String] = [:]

        for item in items {
            for term in item.glossaryTerms {
                let normalized = Self.normalize(term: term)
                guard normalized.isEmpty == false else { continue }

                let pattern = Self.pattern(for: term)
                let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let entry = Entry(
                    term: term,
                    normalizedTerm: normalized,
                    articleID: item.id,
                    articleTitle: item.title,
                    regex: regex
                )

                if uniqueEntries[normalized] == nil {
                    uniqueEntries[normalized] = entry
                    idsByNormalizedTerm[normalized] = item.id
                }
            }
        }

        entries = uniqueEntries.values.sorted {
            if $0.term.count == $1.term.count {
                return $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending
            }
            return $0.term.count > $1.term.count
        }
        articleIDsByNormalizedTerm = idsByNormalizedTerm
    }

    func articleID(for term: String) -> String? {
        articleIDsByNormalizedTerm[Self.normalize(term: term)]
    }

    func matches(in text: String, maxMatches: Int = 2) -> [Match] {
        guard text.isEmpty == false, maxMatches > 0 else { return [] }

        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        var acceptedRanges: [NSRange] = []
        var results: [Match] = []

        for entry in entries {
            guard let regex = entry.regex else { continue }
            let regexMatches = regex.matches(in: text, options: [], range: fullRange)

            for regexMatch in regexMatches {
                guard let stringRange = Range(regexMatch.range, in: text) else { continue }
                if acceptedRanges.contains(where: { NSIntersectionRange($0, regexMatch.range).length > 0 }) {
                    continue
                }

                acceptedRanges.append(regexMatch.range)
                results.append(
                    Match(
                        articleID: entry.articleID,
                        articleTitle: entry.articleTitle,
                        matchedTerm: String(text[stringRange]),
                        range: stringRange
                    )
                )

                if results.count == maxMatches {
                    return results.sorted { $0.range.lowerBound < $1.range.lowerBound }
                }
            }
        }

        return results.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }

    func attributedString(
        for text: String,
        maxMatches: Int = 2
    ) -> AttributedString {
        var attributed = AttributedString(text)
        let matches = matches(in: text, maxMatches: maxMatches)

        for match in matches {
            guard let url = URL(string: AppRouter.DeepLink.knowledge(id: match.articleID)),
                  let attributedRange = Range(match.range, in: attributed)
            else {
                continue
            }

            attributed[attributedRange].link = url
        }

        return attributed
    }

    static func normalize(term: String) -> String {
        term
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private static func pattern(for term: String) -> String {
        let escaped = NSRegularExpression.escapedPattern(for: term)
            .replacingOccurrences(of: "\\ ", with: "\\s+")
        return "(?<![\\p{L}\\p{N}])\(escaped)(?![\\p{L}\\p{N}])"
    }
}

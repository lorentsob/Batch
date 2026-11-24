import SwiftUI

/// Renders a multiline description text as a bullet list with vertical bar markers.
/// Strips leading "- " prefixes and replaces " → " with ": " in each line.
struct DescriptionBulletList: View {
    let lines: [String]

    init(text: String) {
        self.lines = Self.parse(text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Theme.Control.primaryFill.opacity(0.55))
                        .frame(width: 3, height: 16)
                        .padding(.top, 3)
                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    nonisolated static func parse(_ text: String) -> [String] {
        text.split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { raw in
                var s = String(raw).trimmingCharacters(in: .whitespaces)
                if s.hasPrefix("- ") { s = String(s.dropFirst(2)) }
                s = s.replacingOccurrences(of: " → ", with: ": ")
                return s.isEmpty ? nil : s
            }
    }
}

extension String {
    /// Returns the first parsed bullet line, suitable for compact card previews.
    var descriptionFirstLine: String {
        DescriptionBulletList.parse(self).first ?? self
    }
}

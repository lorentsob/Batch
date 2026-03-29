import SwiftUI

struct PreparationHubCardView: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let badge: String?
    let isEmpty: Bool
    let emptyLabel: String
    let onTap: () -> Void
    let onEmptyCTA: () -> Void

    init(
        systemImage: String,
        title: String,
        subtitle: String,
        badge: String? = nil,
        isEmpty: Bool = false,
        emptyLabel: String,
        onTap: @escaping () -> Void,
        onEmptyCTA: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.isEmpty = isEmpty
        self.emptyLabel = emptyLabel
        self.onTap = onTap
        self.onEmptyCTA = onEmptyCTA
    }

    var body: some View {
        Button(action: onTap) {
            SectionCard {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(Theme.ink)

                            if let badge {
                                StateBadge(text: badge, tone: .count)
                            }
                        }

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                            .lineLimit(2)

                        if isEmpty {
                            Button(emptyLabel, action: onEmptyCTA)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.accent)
                                .padding(.top, 2)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.muted)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

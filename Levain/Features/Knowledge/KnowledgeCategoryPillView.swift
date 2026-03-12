import SwiftUI

struct KnowledgeCategoryPillView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Theme.Control.primaryForeground : Theme.Control.secondaryForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.Control.primaryFill : Theme.Surface.card)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Theme.Border.defaultColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

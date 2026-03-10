import SwiftUI

struct KnowledgeCategoryPillView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Theme.background : Theme.muted)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.ink : Theme.panel)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Theme.muted.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

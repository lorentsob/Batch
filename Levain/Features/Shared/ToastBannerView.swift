import SwiftUI

struct ToastBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.headline)
                .foregroundStyle(Theme.Control.primaryFill)

            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("ToastBannerMessage")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous)
                .fill(Theme.Surface.tinted)
                .shadow(color: Theme.Shadow.card, radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous)
                .stroke(Theme.Border.emphasis, lineWidth: 1)
        )
        .accessibilityIdentifier("ToastBannerView")
    }
}

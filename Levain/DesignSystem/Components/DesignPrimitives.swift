import SwiftUI

struct MetricChip: View {
    let label: String
    let value: String
    var tone: StateBadge.Tone = .info

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.Text.tertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(valueColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                .fill(tone == .danger ? Theme.Status.dangerBackground : Theme.Surface.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                .stroke(
                    tone == .danger ? Theme.Status.dangerForeground.opacity(0.25) : Theme.Border.emphasis,
                    lineWidth: 1.5
                )
        )
    }

    private var valueColor: Color {
        tone == .danger ? Theme.Status.dangerForeground : Theme.Text.primary
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    var fill: Color = Theme.Control.primaryFill

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Theme.Control.primaryForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous)
                    .fill(fill)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    var fill: Color = Theme.Control.secondaryFill
    var tint: Color = Theme.Control.secondaryForeground
    var border: Color = Theme.Control.outlineBorder

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DangerActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.Control.dangerForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .fill(Theme.Control.dangerFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .stroke(Theme.Status.dangerForeground.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

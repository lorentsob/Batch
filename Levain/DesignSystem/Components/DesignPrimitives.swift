import SwiftUI

struct MetricChip: View {
    let label: String
    let value: String
    var tone: StateBadge.Tone = .info

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(labelColor)
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
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }

    private var backgroundColor: Color {
        switch tone {
        case .danger, .overdue:
            Theme.Surface.danger
        case .done, .skipped:
            Theme.Surface.subtle
        default:
            Theme.Surface.card
        }
    }

    private var borderColor: Color {
        switch tone {
        case .danger, .overdue:
            Theme.Border.danger
        case .done, .skipped:
            Theme.Border.done
        default:
            Theme.Border.emphasis
        }
    }

    private var labelColor: Color {
        switch tone {
        case .done, .skipped:
            Theme.Text.secondary
        default:
            Theme.Text.tertiary
        }
    }

    private var valueColor: Color {
        switch tone {
        case .danger, .overdue:
            Theme.Text.onDanger
        case .done, .skipped:
            Theme.Text.secondary
        default:
            Theme.Text.primary
        }
    }
}

// MARK: - Primary Action Button
// Solid green fill — all main CTAs: Avvia, Completa, Rinfresca, Salva, Crea

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

// MARK: - Secondary Action Button
// Outline style — transparent bg, green500 border, green800 text
// v2.0: was neutral100 bg — updated to outline for semantic clarity (secondary CTAs are green actions)

struct SecondaryActionButtonStyle: ButtonStyle {
    var fill: Color = Theme.Control.secondaryFill          // Color.clear — outline style
    var tint: Color = Theme.Control.secondaryForeground    // green800
    var border: Color = Theme.Control.secondaryBorder      // green500

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
                    .stroke(border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Destructive Outline Button
// Red border + red text, transparent bg — reversible destructive actions (archive, remove)
// Distinct from DangerActionButtonStyle (solid red) which is for urgent/irreversible actions

struct DestructiveOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.Control.dangerFill)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .fill(Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .stroke(Theme.Control.dangerFill, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Danger Action Button
// Solid red fill, white text — destructive actions and overdue primary CTAs
// v2.0: was errorLight bg + error text (outlined danger) — updated to solid fill for visual weight

struct DangerActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.Control.dangerForeground)  // neutral0 — white on red
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.compact, style: .continuous)
                    .fill(Theme.Control.dangerFill)            // Palette.error — solid red
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

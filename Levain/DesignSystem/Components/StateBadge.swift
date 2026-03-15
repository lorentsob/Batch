import SwiftUI

struct StateBadge: View {
    enum Tone: String, CaseIterable {
        case running
        case pending
        case done
        case skipped
        case overdue
        case danger
        case info
        case count
        /// Alias for .info — retained for backward compatibility with existing call sites
        case schedule

        var background: Color {
            switch self {
            case .running:
                Theme.Status.runningBackground          // green500 — accade adesso
            case .pending:
                Theme.Status.pendingBackground          // green100 — nel piano, arriverà
            case .done:
                Theme.Status.doneBackground             // neutral100 — archiviato
            case .skipped:
                Theme.Status.skippedBackground          // neutral100 — saltato
            case .overdue:
                Theme.Status.overdueBackground          // errorLight — problema attivo
            case .danger:
                Theme.Status.dangerBackground           // errorLight — critico
            case .info:
                Theme.Status.infoBackground             // green25 — informativo
            case .count:
                Theme.Status.countBackground            // green50 — metrica
            case .schedule:
                Theme.Status.infoBackground             // green25 — alias di .info
            }
        }

        var foreground: Color {
            switch self {
            case .running:
                Theme.Status.runningForeground          // neutral0 su verde pieno
            case .pending:
                Theme.Status.pendingForeground          // green800 su green100
            case .done:
                Theme.Status.doneForeground             // neutral600 su neutral100
            case .skipped:
                Theme.Status.skippedForeground          // neutral500 su neutral100
            case .overdue:
                Theme.Status.overdueForeground          // errorDark su errorLight
            case .danger:
                Theme.Status.dangerForeground           // errorDark su errorLight
            case .info:
                Theme.Status.infoForeground             // green600 su green25
            case .count:
                Theme.Status.countForeground            // green800 su green50
            case .schedule:
                Theme.Status.infoForeground             // green600 — alias di .info
            }
        }
    }

    let text: String
    let tone: Tone

    init(text: String, tone: Tone = .info) {
        self.text = text
        self.tone = tone
    }

    init(stepStatus: StepStatus) {
        self.text = stepStatus.title
        switch stepStatus {
        case .pending:
            tone = .pending
        case .running:
            tone = .running
        case .done:
            tone = .done
        case .skipped:
            tone = .skipped
        }
    }

    init(bakeStatus: BakeStatus) {
        self.text = bakeStatus.title
        switch bakeStatus {
        case .planned:
            tone = .info
        case .inProgress:
            tone = .running
        case .completed:
            tone = .done
        case .cancelled:
            tone = .danger
        }
    }

    init(dueState: StarterDueState) {
        self.text = dueState.title
        switch dueState {
        case .ok:
            tone = .count
        case .dueToday:
            tone = .pending             // verde tenue — scade oggi, richiede attenzione
        case .overdue:
            tone = .overdue             // rosso — in ritardo
        }
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tone.foreground)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(tone.background)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tone.stroke, lineWidth: tone.stroke == .clear ? 0 : 1)
            )
    }
}

private extension StateBadge.Tone {
    var stroke: Color {
        switch self {
        case .overdue, .danger:
            Theme.Border.danger
        default:
            .clear
        }
    }
}

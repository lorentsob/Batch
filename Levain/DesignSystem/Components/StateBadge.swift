import SwiftUI

struct StateBadge: View {
    enum Tone: String, CaseIterable {
        case running
        case done
        case pending
        case info
        case count
        case schedule
        case danger

        var background: Color {
            switch self {
            case .running:
                Theme.Status.runningBackground         // green500 — solid, attivo ora
            case .done:
                Theme.Status.doneBackground            // green50 — completato
            case .pending:
                Theme.Palette.green100                 // green100 — da fare (era grigio)
            case .info:
                Theme.Status.countBackground           // green50 — informativo
            case .count:
                Theme.Status.countBackground           // green50
            case .schedule:
                Theme.Status.doneBackground            // green50 — pianificato (era grigio)
            case .danger:
                Theme.Status.dangerBackground          // rosso chiaro
            }
        }

        var foreground: Color {
            switch self {
            case .running:
                Theme.Status.runningForeground         // bianco su verde pieno
            case .done:
                Theme.Status.doneForeground            // green600
            case .pending:
                Theme.Text.primary                     // green800 su green100
            case .info:
                Theme.Status.countForeground           // green800
            case .count:
                Theme.Status.countForeground           // green800
            case .schedule:
                Theme.Status.doneForeground            // green600 su green50
            case .danger:
                Theme.Status.dangerForeground          // rosso
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
            tone = .pending
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
            tone = .done
        case .dueToday:
            tone = .schedule
        case .overdue:
            tone = .danger
        }
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tone.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(tone.background)
            )
    }
}

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

        var backgroundToken: String {
            switch self {
            case .running:
                "green-500"
            case .done:
                "green-50"
            case .pending:
                "neutral-100"
            case .info:
                "green-25"
            case .count:
                "green-50"
            case .schedule:
                "neutral-100"
            case .danger:
                "error-light"
            }
        }

        var foregroundToken: String {
            switch self {
            case .running:
                "neutral-0"
            case .done:
                "green-600"
            case .pending:
                "neutral-400"
            case .info:
                "green-600"
            case .count:
                "green-800"
            case .schedule:
                "neutral-500"
            case .danger:
                "error"
            }
        }

        var background: Color {
            switch self {
            case .running:
                Theme.Status.runningBackground
            case .done:
                Theme.Status.doneBackground
            case .pending:
                Theme.Status.pendingBackground
            case .info:
                Theme.Status.infoBackground
            case .count:
                Theme.Status.countBackground
            case .schedule:
                Theme.Status.scheduleBackground
            case .danger:
                Theme.Status.dangerBackground
            }
        }

        var foreground: Color {
            switch self {
            case .running:
                Theme.Status.runningForeground
            case .done:
                Theme.Status.doneForeground
            case .pending:
                Theme.Status.pendingForeground
            case .info:
                Theme.Status.infoForeground
            case .count:
                Theme.Status.countForeground
            case .schedule:
                Theme.Status.scheduleForeground
            case .danger:
                Theme.Status.dangerForeground
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
            tone = .pending
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

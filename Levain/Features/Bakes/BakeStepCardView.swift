import SwiftUI

struct ActiveStepHeroCard: View {
    let contextLabel: String
    let contextValue: String
    let step: BakeStep
    let onPrimaryAction: () -> Void
    let onDetail: () -> Void
    let onCustomShift: (() -> Void)?
    let onQuickShift: ((Int) -> Void)?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let now = context.date
            let phase = step.timerPhase(now: now)
            let appearance = OperationalStepAppearance(phase: phase)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contextLabel.uppercased())
                            .font(.caption.weight(.semibold))
                            .kerning(0.6)
                            .foregroundStyle(appearance.label)

                        Text(contextValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)

                        Text(step.displayName)
                            .font(.system(size: 28, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.ink)

                        if !step.descriptionText.isEmpty {
                            Text(step.descriptionText)
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                                .lineLimit(3)
                        }
                    }

                    Spacer(minLength: 12)

                    TimerStatusPill(phase: phase, appearance: appearance)
                }

                HStack(spacing: 10) {
                    StepMetaPill(label: "Inizio", value: DateFormattingService.time(step.referenceStart))
                    StepMetaPill(label: "Durata", value: DateFormattingService.duration(minutes: step.plannedDurationMinutes))
                    StepMetaPill(label: "Fine", value: DateFormattingService.time(step.plannedEnd))
                }

                LiveTimerBlock(step: step, now: now, appearance: appearance)

                if let onQuickShift, let onCustomShift, phase == .running || phase == .overdue {
                    StepQuickShiftStrip(onShift: onQuickShift, onCustom: onCustomShift)
                }

                VStack(spacing: 10) {
                    Button(primaryActionTitle) {
                        onPrimaryAction()
                    }
                    .buttonStyle(OperationalPrimaryButtonStyle(fill: appearance.accent))

                    HStack(spacing: 10) {
                        Button("Dettaglio") {
                            onDetail()
                        }
                        .buttonStyle(OperationalSecondaryButtonStyle(tint: appearance.accent))

                        if let onCustomShift, phase == .running || phase == .overdue {
                            Button("Sposta") {
                                onCustomShift()
                            }
                            .buttonStyle(OperationalSecondaryButtonStyle(tint: appearance.accent))
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(appearance.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(appearance.border, lineWidth: 1.5)
            )
            .shadow(color: appearance.shadow, radius: 18, y: 10)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilitySummary(now: now))
        }
    }

    private var primaryActionTitle: String {
        step.status == .running ? "Completa step" : "Avvia step"
    }

    private func accessibilitySummary(now: Date) -> String {
        switch step.timerPhase(now: now) {
        case .upcoming:
            let startsIn = max(step.startsInMinutes(now: now), 0)
            let waitLabel = startsIn == 0 ? "ora" : "tra \(DateFormattingService.duration(minutes: startsIn))"
            return "\(step.displayName). Pianificato \(waitLabel). Fine prevista \(DateFormattingService.time(step.plannedEnd))."
        case .running:
            return "\(step.displayName). In corso. Residuo \(DateFormattingService.duration(minutes: step.remainingMinutes(now: now)))."
        case .overdue:
            return "\(step.displayName). In ritardo di \(DateFormattingService.duration(minutes: step.overrunMinutes(now: now)))."
        case .completed:
            return "\(step.displayName). \(step.status.title)."
        }
    }
}

struct StepTimelineRow: View {
    let step: BakeStep
    let showsConnector: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(DateFormattingService.time(step.plannedStart))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(DateFormattingService.duration(minutes: step.plannedDurationMinutes))
                        .font(.caption2)
                        .foregroundStyle(Theme.muted)
                }
                .frame(width: 70, alignment: .trailing)

                VStack(spacing: 0) {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 12, height: 12)

                    if showsConnector {
                        Rectangle()
                            .fill(Theme.muted.opacity(0.18))
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 14)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(step.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(step.isTerminal ? Theme.muted : Theme.ink)

                        Spacer(minLength: 8)

                        if step.isTerminal {
                            StateBadge(text: step.status.title)
                        } else if step.isOverdue() {
                            StateBadge(text: "In ritardo")
                        }
                    }

                    if !step.descriptionText.isEmpty {
                        Text(step.descriptionText)
                            .font(.footnote)
                            .foregroundStyle(Theme.muted)
                            .lineLimit(1)
                    }

                    Text(statusLine)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.muted.opacity(0.8))
                    .padding(.top, 2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(step.isTerminal ? Theme.panel.opacity(0.55) : Theme.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var dotColor: Color {
        if step.status == .running { return Theme.success }
        if step.isOverdue() { return Theme.danger }
        if step.status == .done { return Theme.success }
        if step.status == .skipped { return Theme.muted }
        return Theme.accent
    }

    private var borderColor: Color {
        if step.isOverdue() { return Theme.danger.opacity(0.18) }
        if step.status == .done { return Theme.success.opacity(0.12) }
        return Color.clear
    }

    private var statusLine: String {
        switch step.status {
        case .pending:
            if step.isOverdue() {
                return "Scaduto alle \(DateFormattingService.time(step.plannedEnd))"
            }
            return "Previsto \(DateFormattingService.dayTime(step.plannedStart))"
        case .running:
            return "Iniziato alle \(DateFormattingService.time(step.referenceStart))"
        case .done:
            if let actualEnd = step.actualEnd {
                return "Completato alle \(DateFormattingService.time(actualEnd))"
            }
            return "Completato"
        case .skipped:
            if let actualEnd = step.actualEnd {
                return "Saltato alle \(DateFormattingService.time(actualEnd))"
            }
            return "Saltato"
        }
    }
}

struct StepProgressBar: View {
    let progress: Double
    let accent: Color
    let isOverdue: Bool

    var body: some View {
        GeometryReader { geometry in
            let clampedProgress = min(max(progress, 0), 1)
            let width = geometry.size.width
            let fillWidth = max(width * CGFloat(clampedProgress), 14)

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(accent.opacity(0.14))

                Capsule(style: .continuous)
                    .fill(accent)
                    .frame(width: fillWidth)

                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(accent, lineWidth: 2)
                    )
                    .offset(x: min(max(fillWidth - 12, 0), max(width - 12, 0)))

                if isOverdue {
                    HStack {
                        Spacer()
                        Image(systemName: "exclamationmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(accent)
                            .padding(.trailing, 4)
                    }
                }
            }
        }
        .frame(height: 14)
    }
}

struct TimerStatusPill: View {
    let phase: BakeStep.TimerPhase
    let appearance: OperationalStepAppearance

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatePulse = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(appearance.accent)
                .frame(width: 10, height: 10)
                .scaleEffect(animatePulse ? 1.18 : 1)
                .animation(
                    reduceMotion || phase == .upcoming || phase == .completed
                    ? nil
                    : .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: animatePulse
                )

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(appearance.accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(appearance.accent.opacity(0.12))
        )
        .task(id: phase) {
            animatePulse = phase == .running || phase == .overdue
        }
    }

    private var label: String {
        switch phase {
        case .upcoming:
            return "In partenza"
        case .running:
            return "In corso"
        case .overdue:
            return "In ritardo"
        case .completed:
            return "Completato"
        }
    }
}

struct LiveTimerBlock: View {
    let step: BakeStep
    let now: Date
    let appearance: OperationalStepAppearance

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(headline)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(appearance.label)

                    Text(primaryValue)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }

                Spacer(minLength: 12)

                Text(DateFormattingService.duration(minutes: step.plannedDurationMinutes))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(appearance.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(appearance.accent.opacity(0.1))
                    )
            }

            StepProgressBar(progress: progressValue, accent: appearance.accent, isOverdue: phase == .overdue)

            HStack(alignment: .top, spacing: 8) {
                TimerMetric(label: "Inizio", value: DateFormattingService.time(step.referenceStart))
                TimerMetric(label: "Fine prevista", value: DateFormattingService.time(step.plannedEnd))
                TimerMetric(label: trailingMetricLabel, value: trailingMetricValue)
            }

            Text(detailLine)
                .font(.footnote)
                .foregroundStyle(Theme.muted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(appearance.accent.opacity(0.12), lineWidth: 1)
        )
    }

    private var phase: BakeStep.TimerPhase {
        step.timerPhase(now: now)
    }

    private var headline: String {
        switch phase {
        case .upcoming:
            return "Parte tra"
        case .running:
            return "Tempo residuo"
        case .overdue:
            return "Ritardo accumulato"
        case .completed:
            return "Step completato"
        }
    }

    private var primaryValue: String {
        switch phase {
        case .upcoming:
            let minutes = step.startsInMinutes(now: now)
            return minutes == 0 ? "Ora" : DateFormattingService.duration(minutes: minutes)
        case .running:
            return DateFormattingService.duration(minutes: step.remainingMinutes(now: now))
        case .overdue:
            return DateFormattingService.duration(minutes: step.overrunMinutes(now: now))
        case .completed:
            return step.status.title
        }
    }

    private var progressValue: Double {
        switch phase {
        case .upcoming:
            return 0
        case .running:
            return step.progressValue(now: now)
        case .overdue:
            return 1
        case .completed:
            return 1
        }
    }

    private var trailingMetricLabel: String {
        switch phase {
        case .upcoming:
            return "Attesa"
        case .running:
            return "Trascorso"
        case .overdue:
            return "Ritardo"
        case .completed:
            return "Esito"
        }
    }

    private var trailingMetricValue: String {
        switch phase {
        case .upcoming:
            let minutes = step.startsInMinutes(now: now)
            return minutes == 0 ? "Ora" : DateFormattingService.duration(minutes: minutes)
        case .running:
            return DateFormattingService.duration(minutes: step.elapsedMinutes(now: now))
        case .overdue:
            return DateFormattingService.duration(minutes: step.overrunMinutes(now: now))
        case .completed:
            return step.status.title
        }
    }

    private var detailLine: String {
        switch phase {
        case .upcoming:
            return "Inizio alle \(DateFormattingService.time(step.plannedStart)) con chiusura prevista alle \(DateFormattingService.time(step.plannedEnd))."
        case .running:
            return "Avviato alle \(DateFormattingService.time(step.referenceStart)); il ritmo previsto si chiude alle \(DateFormattingService.time(step.plannedEnd))."
        case .overdue:
            return "La durata prevista era fino alle \(DateFormattingService.time(step.plannedEnd)); puoi completare lo step o spostare il resto della timeline."
        case .completed:
            if let actualEnd = step.actualEnd {
                return "Step chiuso alle \(DateFormattingService.time(actualEnd))."
            }
            return "Step chiuso."
        }
    }
}

struct StepQuickShiftStrip: View {
    let onShift: (Int) -> Void
    let onCustom: () -> Void

    private let presets = [15, 30, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Riallinea rapidamente la timeline")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.muted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(presets, id: \.self) { minutes in
                    Button(shiftLabel(for: minutes)) {
                        onShift(minutes)
                    }
                    .buttonStyle(OperationalSecondaryButtonStyle(tint: Theme.accent))
                }

                Button("Custom") {
                    onCustom()
                }
                .buttonStyle(OperationalSecondaryButtonStyle(tint: Theme.accent))
            }
        }
    }

    private func shiftLabel(for minutes: Int) -> String {
        switch minutes {
        case 60:
            return "+1 h"
        default:
            return "+\(minutes) min"
        }
    }
}

struct OperationalStepAppearance {
    let background: Color
    let border: Color
    let shadow: Color
    let accent: Color
    let label: Color

    init(phase: BakeStep.TimerPhase) {
        switch phase {
        case .upcoming:
            background = Theme.panel
            border = Theme.accent.opacity(0.16)
            shadow = Theme.accent.opacity(0.12)
            accent = Theme.accent
            label = Theme.accent
        case .running:
            background = Theme.success.opacity(0.12)
            border = Theme.success.opacity(0.2)
            shadow = Theme.success.opacity(0.12)
            accent = Theme.success
            label = Theme.success
        case .overdue:
            background = Theme.danger.opacity(0.12)
            border = Theme.danger.opacity(0.24)
            shadow = Theme.danger.opacity(0.1)
            accent = Theme.danger
            label = Theme.danger
        case .completed:
            background = Theme.panel.opacity(0.8)
            border = Theme.muted.opacity(0.12)
            shadow = Theme.ink.opacity(0.04)
            accent = Theme.muted
            label = Theme.muted
        }
    }
}

private struct TimerMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.muted)
            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StepMetaPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.muted)
            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.5))
        )
    }
}

private struct OperationalPrimaryButtonStyle: ButtonStyle {
    let fill: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(fill)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct OperationalSecondaryButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint.opacity(0.18), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

import SwiftUI

struct ActiveStepHeroCard: View {
    let contextLabel: String
    let contextValue: String
    let step: BakeStep
    let onPrimaryAction: () -> Void
    let onDetail: () -> Void
    let onCustomShift: (() -> Void)?
    let onQuickShift: ((Int) -> Void)?

    private let metricColumns = [
        GridItem(.adaptive(minimum: 104), spacing: 8)
    ]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let now = context.date
            let phase = step.timerPhase(now: now)
            let appearance = OperationalStepAppearance(phase: phase)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            StateBadge(text: contextLabel, tone: .info)
                            if step.startedOutOfOrder {
                                StateBadge(text: "Fuori ordine", tone: .info)
                            }
                        }

                        Text(contextValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)

                        Text(step.displayName)
                            .font(.system(size: 28, weight: .bold))
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

                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                    MetricChip(
                        label: "Inizio",
                        value: DateFormattingService.time(step.referenceStart),
                        tone: .schedule
                    )
                    MetricChip(
                        label: "Durata",
                        value: DateFormattingService.duration(minutes: step.plannedDurationMinutes),
                        tone: .info
                    )
                    MetricChip(
                        label: step.isWindowBased ? "Finestra" : "Fine",
                        value: DateFormattingService.time(step.isWindowBased ? step.windowEnd : step.plannedEnd),
                        tone: appearance.metricTone
                    )
                }

                LiveTimerBlock(step: step, now: now, appearance: appearance)

                if let onQuickShift, let onCustomShift, phase == .running || phase == .overdue {
                    StepQuickShiftStrip(onShift: onQuickShift, onCustom: onCustomShift)
                }

                VStack(spacing: 10) {
                    Button(primaryActionTitle) {
                        onPrimaryAction()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    HStack(spacing: 10) {
                        Button("Dettaglio") {
                            onDetail()
                        }
                        .buttonStyle(SecondaryActionButtonStyle())

                        if let onCustomShift, phase == .running || phase == .overdue {
                            Button("Sposta") {
                                onCustomShift()
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(appearance.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .stroke(appearance.border, lineWidth: appearance.lineWidth)
            )
            .shadow(color: appearance.shadow, radius: 18, y: 10)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilitySummary(now: now))
        }
    }

    private var primaryActionTitle: String {
        step.status == .running ? "Completa fase" : "Avvia fase"
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
                VStack(alignment: .trailing, spacing: 4) {
                    Text(DateFormattingService.time(step.plannedStart))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(DateFormattingService.duration(minutes: step.plannedDurationMinutes))
                        .font(.caption2)
                        .foregroundStyle(Theme.Text.tertiary)
                }
                .frame(width: 70, alignment: .trailing)

                VStack(spacing: 0) {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 12, height: 12)

                    if showsConnector {
                        Rectangle()
                            .fill(Theme.Border.defaultColor)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 14)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(step.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(step.isTerminal ? Theme.muted : Theme.ink)

                        Spacer(minLength: 8)
                        statusBadge
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
                    .foregroundStyle(Theme.Text.tertiary)
                    .padding(.top, 2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if step.isTerminal {
            StateBadge(stepStatus: step.status)
        } else if step.isOverdue() {
            StateBadge(text: "In ritardo", tone: .danger)
        } else if step.startedOutOfOrder {
            StateBadge(text: "Fuori ordine", tone: .info)
        } else {
            StateBadge(stepStatus: step.status)
        }
    }

    private var dotColor: Color {
        if step.status == .running { return Theme.Status.runningBackground }
        if step.isOverdue() { return Theme.Status.dangerForeground }
        if step.status == .done { return Theme.Status.doneForeground }
        if step.status == .skipped { return Theme.Text.tertiary }
        return Theme.Text.secondary
    }

    private var backgroundColor: Color {
        if step.isOverdue() { return Theme.Surface.dangerTint }
        if step.status == .running { return Theme.Surface.tinted }
        return Theme.Surface.card
    }

    private var borderColor: Color {
        if step.isOverdue() { return Theme.Status.dangerForeground.opacity(0.26) }
        if step.status == .running { return Theme.Border.active }
        return Theme.Border.defaultColor
    }

    private var lineWidth: CGFloat {
        step.status == .running ? 2 : 1
    }

    private var statusLine: String {
        switch step.status {
        case .pending:
            if step.isOverdue() {
                return "Scaduto alle \(DateFormattingService.time(step.isWindowBased ? step.windowEnd : step.plannedEnd))"
            }
            return "Previsto \(DateFormattingService.dayTime(step.isWindowBased ? step.windowStart : step.plannedStart))"
        case .running:
            if step.shouldShowCompactWindowState() {
                return "Finestra dalle \(DateFormattingService.dayTime(step.windowStart))"
            }
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
                    .fill(Theme.Status.doneBackground)

                Capsule(style: .continuous)
                    .fill(accent)
                    .frame(width: fillWidth)

                Circle()
                    .fill(Theme.Surface.card)
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
                .fill(appearance.pillBackground)
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

    private let timerColumns = [
        GridItem(.adaptive(minimum: 92), spacing: 8)
    ]

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

                StateBadge(
                    text: DateFormattingService.duration(minutes: step.plannedDurationMinutes),
                    tone: appearance.metricTone
                )
            }

            StepProgressBar(progress: progressValue, accent: appearance.accent, isOverdue: phase == .overdue)

            LazyVGrid(columns: timerColumns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Inizio", value: DateFormattingService.time(step.referenceStart), tone: .schedule)
                MetricChip(label: "Fine", value: DateFormattingService.time(step.plannedEnd), tone: phase == .overdue ? .danger : .schedule)
                MetricChip(label: trailingMetricLabel, value: trailingMetricValue, tone: appearance.metricTone)
            }

            Text(detailLine)
                .font(.footnote)
                .foregroundStyle(Theme.muted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                .fill(Theme.Surface.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                .stroke(appearance.innerBorder, lineWidth: 1)
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
            return "Fase completata"
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
        case .overdue, .completed:
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
            if step.isWindowBased {
                return "Finestra prevista dalle \(DateFormattingService.time(step.windowStart)) alle \(DateFormattingService.time(step.windowEnd))."
            }
            return "Inizio alle \(DateFormattingService.time(step.plannedStart)) con chiusura prevista alle \(DateFormattingService.time(step.plannedEnd))."
        case .running:
            if step.isWindowBased, step.hasWindowOpened(now: now) == false {
                return "Fase in corso. La finestra operativa si apre alle \(DateFormattingService.time(step.windowStart)) e si chiude alle \(DateFormattingService.time(step.windowEnd))."
            }
            return "Avviato alle \(DateFormattingService.time(step.referenceStart)); il ritmo previsto si chiude alle \(DateFormattingService.time(step.isWindowBased ? step.windowEnd : step.plannedEnd))."
        case .overdue:
            return "La chiusura prevista era alle \(DateFormattingService.time(step.isWindowBased ? step.windowEnd : step.plannedEnd)); puoi completare la fase o spostare il resto degli orari."
        case .completed:
            if let actualEnd = step.actualEnd {
                return "Fase chiusa alle \(DateFormattingService.time(actualEnd))."
            }
            return "Fase chiusa."
        }
    }
}

struct StepQuickShiftStrip: View {
    let onShift: (Int) -> Void
    let onCustom: () -> Void

    private let presets = [15, 30, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StateBadge(text: "Sposta rapidamente gli orari", tone: .schedule)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(presets, id: \.self) { minutes in
                    Button(shiftLabel(for: minutes)) {
                        onShift(minutes)
                    }
                    .buttonStyle(SecondaryActionButtonStyle(fill: Theme.Surface.card))
                }

                Button("Personalizzato") {
                    onCustom()
                }
                .buttonStyle(SecondaryActionButtonStyle(fill: Theme.Surface.card))
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
    let innerBorder: Color
    let shadow: Color
    let accent: Color
    let label: Color
    let pillBackground: Color
    let metricTone: StateBadge.Tone
    let lineWidth: CGFloat

    init(phase: BakeStep.TimerPhase) {
        switch phase {
        case .upcoming:
            background = Theme.Surface.card
            border = Theme.Border.defaultColor
            innerBorder = Theme.Border.defaultColor
            shadow = Theme.Shadow.card
            accent = Theme.Control.primaryFill
            label = Theme.Palette.green600
            pillBackground = Theme.Surface.tinted
            metricTone = .schedule
            lineWidth = 1
        case .running:
            background = Theme.Surface.tinted
            border = Theme.Border.active
            innerBorder = Theme.Border.emphasis
            shadow = Theme.Palette.green100.opacity(0.38)
            accent = Theme.Status.runningBackground
            label = Theme.Palette.green600
            pillBackground = Theme.Palette.green50
            metricTone = .running
            lineWidth = 2
        case .overdue:
            background = Theme.Surface.dangerTint
            border = Theme.Status.dangerForeground
            innerBorder = Theme.Status.dangerForeground.opacity(0.18)
            shadow = Theme.Status.dangerForeground.opacity(0.1)
            accent = Theme.Status.dangerForeground
            label = Theme.Status.dangerForeground
            pillBackground = Theme.Status.dangerBackground
            metricTone = .danger
            lineWidth = 1.5
        case .completed:
            background = Theme.Surface.card
            border = Theme.Border.defaultColor
            innerBorder = Theme.Border.defaultColor
            shadow = Theme.Shadow.card.opacity(0.8)
            accent = Theme.Status.doneForeground
            label = Theme.Status.doneForeground
            pillBackground = Theme.Status.doneBackground
            metricTone = .done
            lineWidth = 1
        }
    }
}

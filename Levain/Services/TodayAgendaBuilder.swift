import Foundation

struct TodayAgendaItem: Identifiable {
    struct BakeSummary: Hashable {
        let bakeID: UUID
        let stepID: UUID
        let bakeName: String
        let stepName: String
        let stepDescription: String
        let plannedStart: Date
        let plannedEnd: Date
        let plannedDurationMinutes: Int
        let stepStatus: StepStatus
        let timerPhase: BakeStep.TimerPhase
        let isOverdue: Bool
        let primaryActionTitle: String
    }

    enum Kind: Hashable {
        case bake(BakeSummary)
        case starter(starterID: UUID)
    }

    enum Section: String, CaseIterable, Identifiable {
        case now
        case upcoming
        case starter
        case later

        var id: String { rawValue }

        var title: String {
            switch self {
            case .now: "Ora / in ritardo"
            case .upcoming: "In arrivo"
            case .starter: "Starter"
            case .later: "Più tardi"
            }
        }
    }

    let id: String
    let section: Section
    let kind: Kind
    let title: String
    let subtitle: String
    let state: String
    let actionTitle: String
    let sortDate: Date

    var bakeSummary: BakeSummary? {
        guard case let .bake(summary) = kind else { return nil }
        return summary
    }
}

enum TodayAgendaBuilder {
    static func build(bakes: [Bake], starters: [Starter], now: Date = .now) -> [TodayAgendaItem.Section: [TodayAgendaItem]] {
        var grouped: [TodayAgendaItem.Section: [TodayAgendaItem]] = [:]

        for bake in bakes {
            let status = bake.derivedStatus
            guard status != .cancelled && status != .completed else { continue }
            guard let step = bake.activeStep else { continue }
            
            let section: TodayAgendaItem.Section
            if step.status == .running || step.isOverdue(now: now) {
                section = .now
            } else if Calendar.current.isDate(step.plannedStart, inSameDayAs: now) {
                section = .upcoming
            } else {
                section = .later
            }

            let summary = TodayAgendaItem.BakeSummary(
                bakeID: bake.id,
                stepID: step.id,
                bakeName: bake.name,
                stepName: step.displayName,
                stepDescription: step.descriptionText,
                plannedStart: step.plannedStart,
                plannedEnd: step.plannedEnd,
                plannedDurationMinutes: step.plannedDurationMinutes,
                stepStatus: step.status,
                timerPhase: step.timerPhase(now: now),
                isOverdue: step.isOverdue(now: now),
                primaryActionTitle: step.status == .running ? "Completa step" : "Avvia step"
            )

            let state: String
            switch summary.timerPhase {
            case .running:
                state = "In corso"
            case .overdue:
                state = "In ritardo"
            case .completed:
                state = step.status.title
            case .upcoming:
                state = "Pianificato"
            }

            grouped[section, default: []].append(
                TodayAgendaItem(
                    id: "bake-\(bake.id.uuidString)",
                    section: section,
                    kind: .bake(summary),
                    title: bake.name,
                    subtitle: step.displayName,
                    state: state,
                    actionTitle: summary.primaryActionTitle,
                    sortDate: step.plannedStart
                )
            )
        }

        for starter in starters {
            let dueState = starter.dueState(now: now)
            guard dueState != .ok else { continue }
            grouped[.starter, default: []].append(
                TodayAgendaItem(
                    id: "starter-\(starter.id.uuidString)",
                    section: .starter,
                    kind: .starter(starterID: starter.id),
                    title: starter.name,
                    subtitle: dueState == .overdue ? "rinfresco in ritardo" : "rinfresco previsto oggi",
                    state: dueState.rawValue,
                    actionTitle: "Rinfresca",
                    sortDate: starter.nextDueDate
                )
            )
        }

        for key in grouped.keys {
            grouped[key]?.sort { $0.sortDate < $1.sortDate }
        }

        return grouped
    }
}

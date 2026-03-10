import Foundation

struct TodayAgendaItem: Identifiable {
    enum Kind: Hashable {
        case bakeStep(bakeID: UUID, stepID: UUID)
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
}

enum TodayAgendaBuilder {
    static func build(bakes: [Bake], starters: [Starter], now: Date = .now) -> [TodayAgendaItem.Section: [TodayAgendaItem]] {
        var grouped: [TodayAgendaItem.Section: [TodayAgendaItem]] = [:]

        for bake in bakes {
            for step in bake.sortedSteps where step.isTerminal == false {
                let section: TodayAgendaItem.Section
                if step.status == .running || step.isOverdue(now: now) {
                    section = .now
                } else if Calendar.current.isDate(step.plannedStart, inSameDayAs: now) {
                    section = .upcoming
                } else {
                    section = .later
                }

                let state: String
                if step.status == .running {
                    state = "running"
                } else if step.isOverdue(now: now) {
                    state = "late"
                } else {
                    state = step.status.rawValue
                }

                grouped[section, default: []].append(
                    TodayAgendaItem(
                        id: "bake-\(step.id.uuidString)",
                        section: section,
                        kind: .bakeStep(bakeID: bake.id, stepID: step.id),
                        title: "\(step.displayName) · \(bake.name)",
                        subtitle: step.status == .running
                            ? "in corso · fine prevista \(DateFormattingService.time(step.plannedEnd))"
                            : DateFormattingService.dayTime(step.plannedStart),
                        state: state,
                        actionTitle: "Apri step",
                        sortDate: step.plannedStart
                    )
                )
            }
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


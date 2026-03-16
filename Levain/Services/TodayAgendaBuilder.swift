import Foundation

struct TodayFuturePreview: Hashable {
    enum Kind: Hashable {
        case bake(TodayAgendaItem.BakeSummary)
        case starter(starterID: UUID)
    }

    let kind: Kind
    let title: String
    let subtitle: String
    let referenceDate: Date
}

struct TodayAgendaSnapshot {
    enum EmptyStateMode: String {
        case firstLaunch
        case allClear
        case futureOnly
        case actionable
    }

    let sections: [TodayAgendaItem.Section: [TodayAgendaItem]]
    let emptyState: EmptyStateMode
    let futurePreview: TodayFuturePreview?
}

struct TodayAgendaItem: Identifiable {
    struct BakeSummary: Hashable {
        enum PresentationStyle: Hashable {
            case primaryCard
            case compactWindow
            case tomorrowPreview
        }

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
        let presentationStyle: PresentationStyle
        let windowStart: Date?
        let windowEnd: Date?
    }

    enum Kind: Hashable {
        case bake(BakeSummary)
        case starter(starterID: UUID)
    }

    enum Section: String, CaseIterable, Identifiable {
        case urgent
        case scheduled
        case tomorrow

        var id: String { rawValue }

        var title: String {
            switch self {
            case .urgent: "Da fare"
            case .scheduled: "In programma oggi"
            case .tomorrow: "Domani"
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
    let sortPriority: Int
    let sortDate: Date

    var bakeSummary: BakeSummary? {
        guard case let .bake(summary) = kind else { return nil }
        return summary
    }
}

enum TodayAgendaBuilder {
    static func buildSnapshot(
        bakes: [Bake],
        starters: [Starter],
        hasPersistedData: Bool,
        now: Date = .now
    ) -> TodayAgendaSnapshot {
        var grouped: [TodayAgendaItem.Section: [TodayAgendaItem]] = [:]
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now.startOfDay) ?? now.addingTimeInterval(24 * 60 * 60)

        for bake in bakes {
            guard bake.derivedStatus != .cancelled,
                  bake.derivedStatus != .completed,
                  let step = bake.activeStep else {
                continue
            }

            let presentationStyle: TodayAgendaItem.BakeSummary.PresentationStyle
            let section: TodayAgendaItem.Section
            let sortDate: Date
            let state: String
            let subtitle: String
            let actionTitle: String

            if step.shouldShowCompactWindowState(now: now) {
                presentationStyle = .compactWindow
                section = .scheduled
                sortDate = step.windowStart
                state = "In maturazione"
                subtitle = "\(step.displayName) in corso · inizio finestra alle \(DateFormattingService.time(step.windowStart))"
                actionTitle = "Apri fase"
            } else if step.isOperationallyUrgent(now: now) {
                presentationStyle = .primaryCard
                section = .urgent
                sortDate = step.isWindowBased ? step.windowEnd : step.plannedStart
                state = step.isOverdue(now: now) ? "In ritardo" : "In corso"
                subtitle = step.displayName
                actionTitle = step.status == .running ? "Completa fase" : "Avvia fase"
            } else {
                let referenceDate = step.isWindowBased ? step.windowStart : step.plannedStart

                if calendar.isDate(referenceDate, inSameDayAs: now) {
                    presentationStyle = .primaryCard
                    section = .scheduled
                } else if calendar.isDate(referenceDate, inSameDayAs: tomorrow) {
                    presentationStyle = .tomorrowPreview
                    section = .tomorrow
                } else {
                    continue
                }

                sortDate = referenceDate
                state = "Pianificato"
                subtitle = step.displayName
                actionTitle = "Avvia fase"
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
                primaryActionTitle: actionTitle,
                presentationStyle: presentationStyle,
                windowStart: step.isWindowBased ? step.windowStart : nil,
                windowEnd: step.isWindowBased ? step.windowEnd : nil
            )

            grouped[section, default: []].append(
                TodayAgendaItem(
                    id: "bake-\(bake.id.uuidString)",
                    section: section,
                    kind: .bake(summary),
                    title: bake.name,
                    subtitle: subtitle,
                    state: state,
                    actionTitle: actionTitle,
                    sortPriority: presentationStyle == .compactWindow ? 0 : 1,
                    sortDate: sortDate
                )
            )
        }

        for starter in starters {
            let dueState = starter.dueState(now: now)
            guard dueState != .ok else { continue }

            let section: TodayAgendaItem.Section = dueState == .overdue ? .urgent : .scheduled
            grouped[section, default: []].append(
                TodayAgendaItem(
                    id: "starter-\(starter.id.uuidString)",
                    section: section,
                    kind: .starter(starterID: starter.id),
                    title: starter.name,
                    subtitle: dueState == .overdue ? "Rinfresco in ritardo" : "Rinfresco previsto oggi",
                    state: dueState.title,
                    actionTitle: "Rinfresca",
                    sortPriority: dueState == .overdue ? 2 : 3,
                    sortDate: starter.nextDueDate.settingTime(hour: dueState == .overdue ? 8 : 21, minute: 0)
                )
            )
        }

        for key in grouped.keys {
            grouped[key]?.sort {
                if $0.sortPriority == $1.sortPriority {
                    return $0.sortDate < $1.sortDate
                }
                return $0.sortPriority < $1.sortPriority
            }
        }

        if let tomorrowItems = grouped[.tomorrow] {
            grouped[.tomorrow] = Array(tomorrowItems.prefix(2))
        }

        let hasActionableWork = grouped[.urgent]?.isEmpty == false || grouped[.scheduled]?.isEmpty == false
        let futurePreview = makeFuturePreview(bakes: bakes, starters: starters, now: now)

        let emptyState: TodayAgendaSnapshot.EmptyStateMode
        if hasActionableWork {
            emptyState = .actionable
        } else if hasPersistedData == false {
            emptyState = .firstLaunch
        } else if futurePreview != nil {
            emptyState = .futureOnly
        } else {
            emptyState = .allClear
        }

        return TodayAgendaSnapshot(
            sections: grouped,
            emptyState: emptyState,
            futurePreview: futurePreview
        )
    }

    private static func makeFuturePreview(
        bakes: [Bake],
        starters: [Starter],
        now: Date
    ) -> TodayFuturePreview? {
        var candidates: [TodayFuturePreview] = []
        let endOfToday = now.startOfDay.addingTimeInterval((24 * 60 * 60) - 1)

        for bake in bakes {
            guard bake.derivedStatus != .cancelled,
                  bake.derivedStatus != .completed,
                  let step = bake.activeStep else {
                continue
            }

            if step.shouldShowCompactWindowState(now: now) {
                continue
            }

            let referenceDate = step.isWindowBased ? step.windowStart : step.plannedStart
            guard referenceDate > endOfToday else { continue }

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
                primaryActionTitle: "Apri bake",
                presentationStyle: .tomorrowPreview,
                windowStart: step.isWindowBased ? step.windowStart : nil,
                windowEnd: step.isWindowBased ? step.windowEnd : nil
            )

            candidates.append(
                TodayFuturePreview(
                    kind: .bake(summary),
                    title: bake.name,
                    subtitle: "\(step.displayName) · \(DateFormattingService.dayTime(referenceDate))",
                    referenceDate: referenceDate
                )
            )
        }

        for starter in starters {
            let dueState = starter.dueState(now: now)
            guard dueState == .ok else { continue }
            let referenceDate = starter.nextDueDate.settingTime(hour: 9, minute: 0)
            candidates.append(
                TodayFuturePreview(
                    kind: .starter(starterID: starter.id),
                    title: starter.name,
                    subtitle: "Prossimo rinfresco · \(DateFormattingService.dayTime(referenceDate))",
                    referenceDate: referenceDate
                )
            )
        }

        return candidates.sorted { $0.referenceDate < $1.referenceDate }.first
    }
}

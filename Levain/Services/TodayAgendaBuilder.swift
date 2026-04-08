import Foundation

// MARK: - Future Preview

struct TodayFuturePreview: Hashable {
    enum Kind: Hashable {
        case bake(TodayAgendaItem.BakeSummary)
        case starter(starterID: UUID)
        case kefir(batchID: UUID)
    }

    let kind: Kind
    let title: String
    let subtitle: String
    let referenceDate: Date
}

// MARK: - Snapshot

/// The v2 agenda snapshot exposes a single ranked cross-domain feed.
/// `sections` is retained as a backward-compat computed property for any
/// consumers that still reference section buckets.
struct TodayAgendaSnapshot {
    enum EmptyStateMode: String {
        case firstLaunch
        case allClear
        case futureOnly
        case actionable
    }

    /// Single ordered operational feed — the canonical v2 surface.
    /// Sorted by urgency first, then by time-based tie-breaker within each group.
    let feed: [TodayAgendaItem]
    let emptyState: EmptyStateMode
    let futurePreview: TodayFuturePreview?

    /// Backward-compat section buckets derived from the feed.
    var sections: [TodayAgendaItem.Section: [TodayAgendaItem]] {
        var grouped: [TodayAgendaItem.Section: [TodayAgendaItem]] = [:]
        for item in feed {
            grouped[item.section, default: []].append(item)
        }
        return grouped
    }
}

// MARK: - Agenda Item

struct TodayAgendaItem: Identifiable {
    // MARK: Domain

    /// The preparation domain the item belongs to. Used for the card domain cue.
    enum Domain: String {
        case pane
        case starter
        case kefir  // Phase 19 — kefir-ready hook
    }

    // MARK: Urgency

    /// Cross-domain urgency level. Drives feed ordering in preference to
    /// section membership or sort-priority integers.
    /// Tie-breakers within each level are time-based:
    ///   - overdue: oldest missed time first (sortDate ascending)
    ///   - warning: nearest due time first (sortDate ascending)
    ///   - active:  soonest upcoming action first (sortDate ascending)
    ///   - preview: chronological (sortDate ascending)
    enum Urgency: Int, Comparable {
        case overdue = 0   // missed timing — needs action now
        case warning = 1   // actionable today — running or due today
        case active  = 2   // in-progress but not immediately critical
        case preview = 3   // tomorrow / future

        static func < (lhs: Urgency, rhs: Urgency) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: Bake Summary

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

    // MARK: Kind

    enum Kind: Hashable {
        case bake(BakeSummary)
        case starter(starterID: UUID)
        case kefir(batchID: UUID)
    }

    // MARK: Section (backward compat)

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

    // MARK: Fields

    let id: String
    let domain: Domain
    let urgency: Urgency
    let section: Section          // backward compat — derived from urgency + timing
    let kind: Kind
    let title: String
    let subtitle: String
    let state: String
    let actionTitle: String
    let sortDate: Date            // tie-breaker within urgency group

    var bakeSummary: BakeSummary? {
        guard case let .bake(summary) = kind else { return nil }
        return summary
    }
}

struct TodayAgendaBakeInput {
    let bake: Bake
    let operational: Bake.OperationalSnapshot
}

// MARK: - Builder

enum TodayAgendaBuilder {
    static func buildSnapshot(
        bakes: [Bake],
        starters: [Starter],
        kefirBatches: [KefirBatch] = [],
        hasPersistedData: Bool,
        now: Date = .now
    ) -> TodayAgendaSnapshot {
        buildSnapshot(
            inputs: bakes.map { bake in
                TodayAgendaBakeInput(bake: bake, operational: bake.makeOperationalSnapshot())
            },
            starters: starters,
            kefirBatches: kefirBatches,
            hasPersistedData: hasPersistedData,
            now: now
        )
    }

    static func buildSnapshot(
        inputs: [TodayAgendaBakeInput],
        starters: [Starter],
        kefirBatches: [KefirBatch] = [],
        hasPersistedData: Bool,
        now: Date = .now
    ) -> TodayAgendaSnapshot {
        buildSnapshotImpl(
            bakes: inputs,
            starters: starters,
            kefirBatches: kefirBatches,
            hasPersistedData: hasPersistedData,
            now: now
        )
    }

    private static func buildSnapshotImpl(
        bakes: [TodayAgendaBakeInput],
        starters: [Starter],
        kefirBatches: [KefirBatch] = [],
        hasPersistedData: Bool,
        now: Date = .now
    ) -> TodayAgendaSnapshot {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now.startOfDay) ?? now.addingTimeInterval(24 * 60 * 60)

        var items: [TodayAgendaItem] = []

        // MARK: Bread bakes

        for input in bakes {
            let bake = input.bake

            guard input.operational.derivedStatus != .cancelled,
                  input.operational.derivedStatus != .completed,
                  let step = input.operational.activeStep else {
                continue
            }

            let presentationStyle: TodayAgendaItem.BakeSummary.PresentationStyle
            let section: TodayAgendaItem.Section
            let urgency: TodayAgendaItem.Urgency
            let sortDate: Date
            let state: String
            let subtitle: String
            let actionTitle: String

            if step.shouldShowCompactWindowState(now: now) {
                presentationStyle = .compactWindow
                section = .scheduled
                urgency = .active
                sortDate = step.windowStart
                state = "In maturazione"
                subtitle = "\(step.displayName) in corso · inizio finestra alle \(DateFormattingService.time(step.windowStart))"
                actionTitle = "Apri fase"

            } else if step.isOperationallyUrgent(now: now) {
                presentationStyle = .primaryCard
                section = .urgent
                let isOverdue = step.isOverdue(now: now)
                urgency = isOverdue ? .overdue : .warning
                sortDate = step.isWindowBased ? step.windowEnd : step.plannedStart
                state = isOverdue ? "In ritardo" : "In corso"
                subtitle = step.displayName
                actionTitle = step.status == .running ? "Completa fase" : "Avvia fase"

            } else {
                let referenceDate = step.isWindowBased ? step.windowStart : step.plannedStart

                if calendar.isDate(referenceDate, inSameDayAs: now) {
                    presentationStyle = .primaryCard
                    section = .scheduled
                    urgency = .active
                } else if calendar.isDate(referenceDate, inSameDayAs: tomorrow) {
                    presentationStyle = .tomorrowPreview
                    section = .tomorrow
                    urgency = .preview
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

            items.append(
                TodayAgendaItem(
                    id: "bake-\(bake.id.uuidString)",
                    domain: .pane,
                    urgency: urgency,
                    section: section,
                    kind: .bake(summary),
                    title: bake.name,
                    subtitle: subtitle,
                    state: state,
                    actionTitle: actionTitle,
                    sortDate: sortDate
                )
            )
        }

        // MARK: Starters

        for starter in starters {
            let dueState = starter.dueState(now: now)
            guard dueState != .ok else { continue }

            let section: TodayAgendaItem.Section = dueState == .overdue ? .urgent : .scheduled
            let urgency: TodayAgendaItem.Urgency = dueState == .overdue ? .overdue : .warning
            let sortDate = starter.nextDueDate.settingTime(
                hour: dueState == .overdue ? 8 : 21,
                minute: 0
            )

            items.append(
                TodayAgendaItem(
                    id: "starter-\(starter.id.uuidString)",
                    domain: .starter,
                    urgency: urgency,
                    section: section,
                    kind: .starter(starterID: starter.id),
                    title: starter.name,
                    subtitle: dueState == .overdue ? "Rinfresco in ritardo" : "Rinfresco previsto oggi",
                    state: dueState.title,
                    actionTitle: "Rinfresca",
                    sortDate: sortDate
                )
            )
        }

        // MARK: Kefir batches

        for batch in kefirBatches {
            guard let item = makeKefirAgendaItem(for: batch, now: now) else {
                continue
            }

            items.append(item)
        }

        // MARK: Sort feed

        // Primary: urgency ascending (overdue → warning → active → preview)
        // Secondary: sortDate ascending within each urgency group
        items.sort {
            if $0.urgency == $1.urgency {
                return $0.sortDate < $1.sortDate
            }
            return $0.urgency < $1.urgency
        }

        // Limit tomorrow/preview items to two entries (same rule as before)
        let previewCount = items.filter { $0.urgency == .preview }.count
        if previewCount > 2 {
            var seen = 0
            items = items.filter { item in
                guard item.urgency == .preview else { return true }
                seen += 1
                return seen <= 2
            }
        }

        // MARK: Empty state

        let hasActionableWork = items.contains { $0.urgency == .overdue || $0.urgency == .warning || $0.urgency == .active }
        let futurePreview = makeFuturePreview(
            bakes: bakes,
            starters: starters,
            kefirBatches: kefirBatches,
            now: now
        )

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
            feed: items,
            emptyState: emptyState,
            futurePreview: futurePreview
        )
    }

    private static func makeKefirAgendaItem(for batch: KefirBatch, now: Date) -> TodayAgendaItem? {
        guard batch.isArchived == false,
              let dueAt = batch.nextManagementAt else {
            return nil
        }

        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now.startOfDay) ?? now.addingTimeInterval(24 * 60 * 60)
        let state = batch.derivedState(at: now)

        let urgency: TodayAgendaItem.Urgency
        let section: TodayAgendaItem.Section

        switch state {
        case .overdue:
            if batch.storageMode == .roomTemperature {
                urgency = .overdue
                section = .urgent
            } else {
                urgency = .warning
                section = .scheduled
            }
        case .dueSoon, .dueNow:
            urgency = .warning
            section = .scheduled
        case .active, .pausedFridge, .pausedFreezer:
            if calendar.isDate(dueAt, inSameDayAs: now) {
                urgency = .active
                section = .scheduled
            } else if calendar.isDate(dueAt, inSameDayAs: tomorrow) {
                urgency = .preview
                section = .tomorrow
            } else {
                return nil
            }
        case .archived:
            return nil
        }

        return TodayAgendaItem(
            id: "kefir-\(batch.id.uuidString)",
            domain: .kefir,
            urgency: urgency,
            section: section,
            kind: .kefir(batchID: batch.id),
            title: batch.name,
            subtitle: makeKefirSubtitle(for: batch, state: state, dueAt: dueAt),
            state: state.title,
            actionTitle: batch.primaryActionSuggestion(at: now).title,
            sortDate: dueAt
        )
    }

    private static func makeKefirSubtitle(for batch: KefirBatch, state: KefirBatchState, dueAt: Date) -> String {
        let dueLabel = DateFormattingService.smartDayTime(dueAt)

        switch batch.storageMode {
        case .roomTemperature:
            switch state {
            case .overdue:
                return "Routine fuori finestra · soglia \(dueLabel)"
            case .dueSoon, .dueNow:
                return "Da rinnovare entro \(dueLabel)"
            case .active:
                return "Prossimo rinnovo \(dueLabel)"
            case .pausedFridge, .pausedFreezer, .archived:
                return batch.operationalSummary
            }
        case .fridge:
            switch state {
            case .overdue:
                return "Controllo frigo oltre soglia · riferimento \(dueLabel)"
            case .dueSoon, .dueNow:
                return "Controllo frigo entro \(dueLabel)"
            case .active, .pausedFridge:
                return "Batch in frigo · prossimo controllo \(dueLabel)"
            case .pausedFreezer, .archived:
                return batch.operationalSummary
            }
        case .freezer:
            switch state {
            case .overdue:
                return "Riattivazione pianificata oltre soglia · riferimento \(dueLabel)"
            case .dueSoon, .dueNow:
                return "Riattivazione prevista \(dueLabel)"
            case .active, .pausedFreezer:
                return "Batch in freezer · riattivazione \(dueLabel)"
            case .pausedFridge, .archived:
                return batch.operationalSummary
            }
        }
    }

    // MARK: Future Preview

    private static func makeFuturePreview(
        bakes: [TodayAgendaBakeInput],
        starters: [Starter],
        kefirBatches: [KefirBatch],
        now: Date
    ) -> TodayFuturePreview? {
        var candidates: [TodayFuturePreview] = []
        let endOfToday = now.startOfDay.addingTimeInterval((24 * 60 * 60) - 1)

        for input in bakes {
            let bake = input.bake

            guard input.operational.derivedStatus != .cancelled,
                  input.operational.derivedStatus != .completed,
                  let step = input.operational.activeStep else {
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
                primaryActionTitle: "Apri impasto",
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

        for batch in kefirBatches {
            guard batch.isArchived == false,
                  let referenceDate = batch.nextManagementAt,
                  referenceDate > endOfToday else {
                continue
            }

            candidates.append(
                TodayFuturePreview(
                    kind: .kefir(batchID: batch.id),
                    title: batch.name,
                    subtitle: futurePreviewSubtitle(for: batch, referenceDate: referenceDate),
                    referenceDate: referenceDate
                )
            )
        }

        return candidates.sorted { $0.referenceDate < $1.referenceDate }.first
    }

    private static func futurePreviewSubtitle(for batch: KefirBatch, referenceDate: Date) -> String {
        switch batch.storageMode {
        case .roomTemperature:
            return "Prossimo rinnovo · \(DateFormattingService.dayTime(referenceDate))"
        case .fridge:
            return "Controllo frigo · \(DateFormattingService.dayTime(referenceDate))"
        case .freezer:
            return "Riattivazione · \(DateFormattingService.dayTime(referenceDate))"
        }
    }
}

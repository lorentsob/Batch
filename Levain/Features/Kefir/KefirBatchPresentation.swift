import Foundation
import SwiftUI

enum KefirBatchSectionKind: String, CaseIterable, Identifiable {
    case warning
    case active
    case paused
    case archived

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warning:
            "Da seguire"
        case .active:
            "In corso"
        case .paused:
            "In pausa"
        case .archived:
            "Archivio"
        }
    }
}

struct KefirBatchSectionModel: Identifiable {
    let kind: KefirBatchSectionKind
    let batches: [KefirBatch]

    var id: String { kind.rawValue }
}

struct KefirBatchLineageSummary {
    let sourceName: String?
    let hasMissingSource: Bool
    let derivedNames: [String]

    var cardSummary: String? {
        [sourceCardSummary, derivedCardSummary]
            .compactMap { $0 }
            .joined(separator: " · ")
            .nilIfEmpty
    }

    var originSummary: String? {
        if let sourceName {
            return "Derivato da \(sourceName)."
        }

        if hasMissingSource {
            return "Derivato da un batch non piu disponibile."
        }

        return nil
    }

    var derivedSummary: String? {
        guard derivedNames.isEmpty == false else {
            return nil
        }

        if derivedNames.count == 1, let first = derivedNames.first {
            return "Ha gia generato \(first)."
        }

        if derivedNames.count == 2 {
            return "Ha gia generato \(derivedNames[0]) e \(derivedNames[1])."
        }

        let preview = derivedNames.prefix(2).joined(separator: ", ")
        return "Ha gia generato \(preview) e altri \(derivedNames.count - 2) batch."
    }

    var derivedBadgeText: String? {
        guard derivedNames.isEmpty == false else {
            return nil
        }

        if derivedNames.count == 1 {
            return "1 derivato"
        }

        return "\(derivedNames.count) derivati"
    }

    private var sourceCardSummary: String? {
        if let sourceName {
            return "Da \(sourceName)"
        }

        if hasMissingSource {
            return "Origine non disponibile"
        }

        return nil
    }

    private var derivedCardSummary: String? {
        derivedBadgeText
    }
}

struct KefirLineageIndex {
    private let batchByID: [UUID: KefirBatch]
    private let derivedBySourceID: [UUID: [KefirBatch]]

    init(batches: [KefirBatch]) {
        let orderedBatches = batches.sorted { lhs, rhs in
            if lhs.lastManagedAt != rhs.lastManagedAt {
                return lhs.lastManagedAt > rhs.lastManagedAt
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        batchByID = Dictionary(uniqueKeysWithValues: orderedBatches.map { ($0.id, $0) })

        derivedBySourceID = Dictionary(grouping: orderedBatches.compactMap { batch in
            guard batch.sourceBatchId != nil else {
                return nil
            }
            return batch
        }) { batch in
            batch.sourceBatchId!
        }.mapValues { derived in
            derived.sorted { lhs, rhs in
                if lhs.lastManagedAt != rhs.lastManagedAt {
                    return lhs.lastManagedAt > rhs.lastManagedAt
                }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }

    func batch(id: UUID) -> KefirBatch? {
        batchByID[id]
    }

    func batchName(id: UUID) -> String? {
        batchByID[id]?.name
    }

    func sourceBatch(for batch: KefirBatch) -> KefirBatch? {
        guard let sourceBatchId = batch.sourceBatchId else {
            return nil
        }
        return batchByID[sourceBatchId]
    }

    func derivedBatches(for batch: KefirBatch) -> [KefirBatch] {
        derivedBySourceID[batch.id] ?? []
    }

    func lineageSummary(for batch: KefirBatch) -> KefirBatchLineageSummary {
        let source = sourceBatch(for: batch)

        return KefirBatchLineageSummary(
            sourceName: source?.name,
            hasMissingSource: batch.sourceBatchId != nil && source == nil,
            derivedNames: derivedBatches(for: batch).map(\.name)
        )
    }
}

struct KefirJournalDaySection: Identifiable {
    let date: Date
    let title: String
    let events: [KefirEvent]

    var id: Date { date }
}

struct KefirEventPresentation {
    let badgeText: String
    let badgeTone: StateBadge.Tone
    let title: String
    let detail: String?
    let secondaryText: String?
}

extension Array where Element == KefirBatch {
    var kefirSections: [KefirBatchSectionModel] {
        KefirBatchSectionKind.allCases.compactMap { kind in
            let filtered = filter { $0.sectionKind == kind }
                .sorted(by: kind.sortComparator)
            guard filtered.isEmpty == false else {
                return nil
            }
            return KefirBatchSectionModel(kind: kind, batches: filtered)
        }
    }

    var activeKefirCount: Int {
        filter { $0.sectionKind == .active }.count
    }

    var warningKefirCount: Int {
        filter { $0.sectionKind == .warning }.count
    }

    var pausedKefirCount: Int {
        filter { $0.sectionKind == .paused }.count
    }

    var archivedKefirCount: Int {
        filter { $0.sectionKind == .archived }.count
    }

    var liveKefirCount: Int {
        count - archivedKefirCount
    }
}

extension Array where Element == KefirEvent {
    var journalSections: [KefirJournalDaySection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: self) { event in
            calendar.startOfDay(for: event.createdAt)
        }

        return grouped
            .map { date, events in
                KefirJournalDaySection(
                    date: date,
                    title: journalSectionTitle(for: date, calendar: calendar),
                    events: events.sorted { lhs, rhs in
                        lhs.createdAt > rhs.createdAt
                    }
                )
            }
            .sorted { lhs, rhs in
                lhs.date > rhs.date
            }
    }
}

extension KefirBatchSectionKind {
    fileprivate var sortComparator: (KefirBatch, KefirBatch) -> Bool {
        switch self {
        case .warning:
            return { lhs, rhs in
                let lhsKey = (lhs.urgencyRank, lhs.nextManagementAt ?? .distantFuture, lhs.lastManagedAt)
                let rhsKey = (rhs.urgencyRank, rhs.nextManagementAt ?? .distantFuture, rhs.lastManagedAt)
                if lhsKey.0 != rhsKey.0 { return lhsKey.0 < rhsKey.0 }
                if lhsKey.1 != rhsKey.1 { return lhsKey.1 < rhsKey.1 }
                return lhsKey.2 > rhsKey.2
            }
        case .active:
            return { lhs, rhs in
                let lhsDate = lhs.nextManagementAt ?? .distantFuture
                let rhsDate = rhs.nextManagementAt ?? .distantFuture
                if lhsDate != rhsDate { return lhsDate < rhsDate }
                return lhs.lastManagedAt > rhs.lastManagedAt
            }
        case .paused:
            return { lhs, rhs in
                let lhsDate = lhs.nextManagementAt ?? .distantFuture
                let rhsDate = rhs.nextManagementAt ?? .distantFuture
                if lhsDate != rhsDate { return lhsDate < rhsDate }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        case .archived:
            return { lhs, rhs in
                let lhsDate = lhs.archivedAt ?? lhs.lastManagedAt
                let rhsDate = rhs.archivedAt ?? rhs.lastManagedAt
                if lhsDate != rhsDate { return lhsDate > rhsDate }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }
}

extension KefirBatch {
    func lineageSummary(in batches: [KefirBatch]) -> KefirBatchLineageSummary {
        KefirLineageIndex(batches: batches).lineageSummary(for: self)
    }

    var sectionKind: KefirBatchSectionKind {
        switch derivedState {
        case .dueSoon, .dueNow, .overdue:
            .warning
        case .active:
            .active
        case .pausedFridge, .pausedFreezer:
            .paused
        case .archived:
            .archived
        }
    }

    var urgencyRank: Int {
        switch derivedState {
        case .overdue:
            0
        case .dueNow:
            1
        case .dueSoon:
            2
        case .active:
            3
        case .pausedFridge:
            4
        case .pausedFreezer:
            5
        case .archived:
            6
        }
    }

    var cardEmphasis: SectionCardEmphasis {
        switch derivedState {
        case .overdue:
            .surface
        case .dueSoon, .dueNow:
            .tinted
        default:
            .surface
        }
    }

    var primaryNavigationLabel: String {
        switch primaryAction {
        case .renew:
            "Rinnova"
        case .manage:
            "Apri"
        case .reactivate:
            "Riattiva"
        case .open:
            "Apri"
        }
    }

    var primaryActionSystemImage: String {
        switch primaryAction {
        case .renew:
            "arrow.clockwise"
        case .manage:
            "slider.horizontal.3"
        case .reactivate:
            "snowflake"
        case .open:
            "arrow.right.circle"
        }
    }

    var primaryActionPrompt: String {
        switch primaryAction {
        case .renew:
            "È il momento di rinnovarlo."
        case .manage:
            "Tutto regolare. Puoi aggiornare la conservazione o aggiungere una nota."
        case .reactivate:
            "Pianifica la riattivazione o falla subito."
        case .open:
            "Il batch è in archivio. Puoi aprirlo o crearne uno nuovo da questo."
        }
    }

    var contextSummary: String? {
        let trimmedUse = useLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDifference = differentiationNote.trimmingCharacters(in: .whitespacesAndNewlines)

        return [trimmedUse, trimmedDifference]
            .filter { $0.isEmpty == false }
            .joined(separator: " · ")
            .nilIfEmpty
    }

    var routineSummary: String {
        switch storageMode {
        case .roomTemperature:
            return "Ogni \(expectedRoutineHours) ore"
        case .fridge:
            let days = max(expectedRoutineHours / 24, 1)
            return "Ogni \(days) gg"
        case .freezer:
            return plannedReactivationAt == nil ? "In pausa" : "Pianificata"
        }
    }

    var lastManagedSummary: String {
        DateFormattingService.smartDayTime(lastManagedAt)
    }

    var nextManagementLabel: String {
        storageMode == .freezer ? "Riattiva" : "Prossimo"
    }

    var nextManagementSummary: String {
        guard let nextManagementAt else {
            return "Non pianificato"
        }
        return DateFormattingService.smartDayTime(nextManagementAt)
    }

    var nextManagementTone: StateBadge.Tone {
        switch derivedState {
        case .active:
            .info
        case .dueSoon:
            .warning
        case .dueNow:
            .overdue
        case .overdue:
            .overdue
        case .pausedFridge, .pausedFreezer:
            .done
        case .archived:
            .done
        }
    }

    var statusHeadline: String {
        switch derivedState {
        case .active:
            "In corso"
        case .dueSoon:
            "Da rinnovare presto"
        case .dueNow:
            "Da rinnovare adesso"
        case .overdue:
            "In ritardo"
        case .pausedFridge:
            "In frigo"
        case .pausedFreezer:
            "In freezer"
        case .archived:
            "Archiviato"
        }
    }

    var operationalSummary: String {
        switch derivedState {
        case .active:
            guard let nextManagementAt else {
                return "Procede bene."
            }
            return "Procede bene. Prossimo rinnovo \(DateFormattingService.smartDayTime(nextManagementAt))."
        case .dueSoon:
            guard let nextManagementAt else {
                return "Si avvicina il momento del rinnovo."
            }
            return "Da rinnovare entro \(DateFormattingService.smartDayTime(nextManagementAt))."
        case .dueNow:
            guard let nextManagementAt else {
                return "Pronto per il rinnovo."
            }
            return "Pronto per il rinnovo — scadenza \(DateFormattingService.smartDayTime(nextManagementAt))."
        case .overdue:
            guard let nextManagementAt else {
                return "Oltre la scadenza prevista."
            }
            return "In ritardo \(KefirRelativeDateFormatter.string(for: nextManagementAt))."
        case .pausedFridge:
            guard let nextManagementAt else {
                return "In frigo."
            }
            return "In frigo. Prossimo rinnovo \(DateFormattingService.smartDayTime(nextManagementAt))."
        case .pausedFreezer:
            if let plannedReactivationAt {
                return "In freezer. Riattivazione prevista \(DateFormattingService.smartDayTime(plannedReactivationAt))."
            }
            return "In freezer, senza data di riattivazione."
        case .archived:
            if let archivedAt {
                return "Archiviato \(DateFormattingService.smartDayTime(archivedAt))."
            }
            return "Archiviato."
        }
    }

    var accessibilityStem: String {
        name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
    }
}

extension KefirEvent {
    func presentation(batchName: String? = nil) -> KefirEventPresentation {
        switch kind {
        case .created:
            return KefirEventPresentation(
                badgeText: "Avvio",
                badgeTone: .running,
                title: "Batch avviato",
                detail: batchName,
                secondaryText: storageSummary
            )
        case .derivedFromBatch:
            return KefirEventPresentation(
                badgeText: "Derivazione",
                badgeTone: .info,
                title: relatedBatchName.map { "Derivato da \($0)" } ?? "Batch derivato",
                detail: note.nilIfEmpty,
                secondaryText: storageSummary
            )
        case .spawnedDerivedBatch:
            return KefirEventPresentation(
                badgeText: "Derivato",
                badgeTone: .info,
                title: relatedBatchName.map { "Ha generato \($0)" } ?? "Ha generato un derivato",
                detail: note.nilIfEmpty,
                secondaryText: nil
            )
        case .renewed:
            return KefirEventPresentation(
                badgeText: "Rinnovo",
                badgeTone: .running,
                title: "Batch rinnovato",
                detail: nil,
                secondaryText: storageSummary
            )
        case .managementUpdated:
            return KefirEventPresentation(
                badgeText: "Gestione",
                badgeTone: .schedule,
                title: "Gestione aggiornata",
                detail: note.nilIfEmpty,
                secondaryText: storageSummary
            )
        case .storageChanged:
            return KefirEventPresentation(
                badgeText: "Conservazione",
                badgeTone: .schedule,
                title: "Conservazione cambiata",
                detail: storageChangeSummary ?? note.nilIfEmpty,
                secondaryText: storageSummary
            )
        case .reactivated:
            return KefirEventPresentation(
                badgeText: "Riattivazione",
                badgeTone: .running,
                title: "Batch riattivato",
                detail: storageChangeSummary,
                secondaryText: storageSummary
            )
        case .archived:
            return KefirEventPresentation(
                badgeText: "Archivio",
                badgeTone: .done,
                title: "Batch archiviato",
                detail: note.nilIfEmpty,
                secondaryText: storageSummary
            )
        case .noteAdded:
            return KefirEventPresentation(
                badgeText: "Nota",
                badgeTone: .info,
                title: "Nota salvata",
                detail: note.nilIfEmpty,
                secondaryText: nil
            )
        }
    }

    var timestampSummary: String {
        DateFormattingService.smartDayTime(createdAt)
    }

    private var storageSummary: String? {
        guard let storageMode else {
            return nil
        }

        switch storageMode {
        case .roomTemperature:
            if let expectedRoutineHours {
                return "\(storageMode.title) · ogni \(expectedRoutineHours) ore"
            }
            return storageMode.title
        case .fridge:
            if let expectedRoutineHours {
                let days = max(expectedRoutineHours / 24, 1)
                return "\(storageMode.title) · ogni \(days) gg"
            }
            return storageMode.title
        case .freezer:
            if let plannedReactivationAt {
                return "\(storageMode.title) · riattiva \(DateFormattingService.smartDayTime(plannedReactivationAt))"
            }
            return "\(storageMode.title) · pausa lunga"
        }
    }

    private var storageChangeSummary: String? {
        guard let previousStorageMode, let storageMode else {
            return note.nilIfEmpty
        }

        return "Da \(previousStorageMode.title) a \(storageMode.title)"
    }
}

extension StateBadge {
    init(kefirState: KefirBatchState) {
        self.text = kefirState.title
        switch kefirState {
        case .active:
            tone = .running
        case .dueSoon:
            tone = .warning
        case .dueNow:
            tone = .overdue
        case .overdue:
            tone = .overdue
        case .pausedFridge, .pausedFreezer:
            tone = .done
        case .archived:
            tone = .done
        }
    }
}

private enum KefirRelativeDateFormatter {
    static func string(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter.makeItalian()
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

private func journalSectionTitle(for date: Date, calendar: Calendar) -> String {
    if calendar.isDateInToday(date) {
        return "Oggi"
    }

    if calendar.isDateInYesterday(date) {
        return "Ieri"
    }

    return DateFormattingService.day(date)
}

private extension RelativeDateTimeFormatter {
    static func makeItalian() -> RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

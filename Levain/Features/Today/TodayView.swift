import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.lastRefresh, order: .reverse) private var starters: [Starter]

    @State private var refreshStarter: Starter?
    @State private var detailSelection: TodayBakeSelection?
    @State private var shiftSelection: TodayBakeSelection?

    var body: some View {
        let snapshot = TodaySnapshot.make(bakes: Array(bakes), starters: Array(starters))

        ZStack(alignment: .topLeading) {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Forno operativo")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)

                    SectionCard {
                        Text("Cosa richiede attenzione adesso?")
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.ink)

                        Text(snapshot.heroSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)

                        HStack(spacing: 12) {
                            StateBadge(text: "\(snapshot.actionCount) fronti")
                            StateBadge(text: "\(snapshot.inProgressCount) impasti attivi")
                        }
                    }

                    if snapshot.actionCount == 0 {
                        MultiActionEmptyStateView(
                            title: "Giornata leggera",
                            message: "Nessuna azione urgente. Da qui puoi iniziare.",
                            actions: [
                                .init(title: "Nuovo bake", systemImage: "plus.circle.fill") {
                                    router.selectedTab = .bakes
                                },
                                .init(title: "Aggiungi starter", systemImage: "drop.fill") {
                                    router.selectedTab = .starter
                                },
                                .init(title: "Esplora consigli", systemImage: "book.pages.fill") {
                                    router.showingKnowledge = true
                                }
                            ]
                        )
                    } else {
                        ForEach(TodayAgendaItem.Section.allCases) { section in
                            if let items = snapshot.agenda[section], items.isEmpty == false {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(section.title)
                                            .font(.headline)
                                            .foregroundStyle(Theme.ink)
                                        Spacer()
                                        Text("\(items.count)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Theme.muted)
                                    }

                                    ForEach(items) { item in
                                        switch item.kind {
                                        case let .bake(summary):
                                            if let selection = resolve(summary) {
                                                TodayStepCardView(
                                                    bake: selection.bake,
                                                    step: selection.step,
                                                    section: item.section,
                                                    onPrimaryAction: {
                                                        handlePrimary(selection)
                                                    },
                                                    onOpenDetail: {
                                                        detailSelection = selection
                                                    },
                                                    onOpenShift: {
                                                        shiftSelection = selection
                                                    },
                                                    onQuickShift: { minutes in
                                                        shift(selection, by: minutes)
                                                    }
                                                )
                                            }
                                        case let .starter(starterID):
                                            TodayStarterReminderRow(item: item) {
                                                openStarter(starterID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)

                    Button {
                        router.showingKnowledge = true
                    } label: {
                        HStack {
                            Image(systemName: "book.pages.fill")
                            Text("Sfoglia la Knowledge base")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .contentMargins(.bottom, 88, for: .scrollContent)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityIdentifier("TodayScrollView")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $refreshStarter) { starter in
            NavigationStack {
                RefreshLogView(starter: starter)
            }
        }
        .sheet(item: $detailSelection) { selection in
            NavigationStack {
                BakeStepDetailView(step: selection.step)
            }
        }
        .sheet(item: $shiftSelection) { selection in
            NavigationStack {
                ShiftTimelineView(bake: selection.bake, anchorStep: selection.step)
            }
        }
    }

    private func resolve(_ summary: TodayAgendaItem.BakeSummary) -> TodayBakeSelection? {
        guard let bake = bakes.first(where: { $0.id == summary.bakeID }),
              let step = bake.steps.first(where: { $0.id == summary.stepID }) else {
            return nil
        }

        return TodayBakeSelection(bake: bake, step: step)
    }

    private func handlePrimary(_ selection: TodayBakeSelection) {
        let step = selection.step

        if step.status == .running {
            step.complete()
        } else if step.isTerminal == false {
            step.start()
        }

        persistAndSync(for: selection.bake)
    }

    private func shift(_ selection: TodayBakeSelection, by minutes: Int) {
        BakeScheduler.shiftFutureSteps(in: selection.bake, after: selection.step, by: minutes)
        persistAndSync(for: selection.bake)
    }

    private func openStarter(_ starterID: UUID) {
        refreshStarter = starters.first(where: { $0.id == starterID })
    }

    private func persistAndSync(for bake: Bake) {
        try? modelContext.save()

        Task {
            await environment.notificationService.syncNotifications(for: bake)
        }
    }
}

private struct TodayBakeSelection: Identifiable {
    let bake: Bake
    let step: BakeStep

    var id: UUID { step.id }
}

private struct TodaySnapshot {
    let agenda: [TodayAgendaItem.Section: [TodayAgendaItem]]
    let actionCount: Int
    let inProgressCount: Int
    let heroSubtitle: String

    static func make(bakes: [Bake], starters: [Starter]) -> TodaySnapshot {
        let agenda = TodayAgendaBuilder.build(bakes: bakes, starters: starters)
        let actionCount = agenda.values.reduce(0) { $0 + $1.count }
        let inProgressCount = bakes.reduce(into: 0) { count, bake in
            if bake.derivedStatus == .inProgress {
                count += 1
            }
        }

        let heroSubtitle: String
        if let first = agenda[.now]?.first, let summary = first.bakeSummary {
            heroSubtitle = "\(summary.stepName) in \(summary.bakeName.lowercased()): guarda il timer e decidi se completare o riallineare."
        } else if let first = agenda[.upcoming]?.first, let summary = first.bakeSummary {
            heroSubtitle = "Il prossimo step è \(summary.stepName.lowercased()) per \(summary.bakeName.lowercased())."
        } else if let first = agenda[.starter]?.first {
            heroSubtitle = "Hai uno starter da controllare: \(first.title.lowercased())."
        } else {
            heroSubtitle = "Tutto sotto controllo per ora."
        }

        return TodaySnapshot(
            agenda: agenda,
            actionCount: actionCount,
            inProgressCount: inProgressCount,
            heroSubtitle: heroSubtitle
        )
    }
}

import SwiftData
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var router: AppRouter
    
    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.lastRefresh, order: .reverse) private var starters: [Starter]
    
    @State private var refreshStarter: Starter?

    var body: some View {
        let snapshot = TodaySnapshot.make(bakes: Array(bakes), starters: Array(starters))

        ZStack(alignment: .topLeading) {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Home")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.ink)
                    
                    SectionCard {
                        Text("Cosa devi fare adesso?")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.ink)
                        
                        Text(snapshot.heroSubtitle)
                            .foregroundStyle(Theme.muted)
                        
                        HStack(spacing: 12) {
                            StateBadge(text: "\(snapshot.actionCount) azioni")
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
                                    Text(section.title)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    
                                    ForEach(items) { item in
                                        switch item.kind {
                                        case .bake:
                                            TodayStepCardView(item: item) {
                                                handle(item)
                                            }
                                        case .starter:
                                            TodayStarterReminderRow(item: item) {
                                                handle(item)
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
    }

    private func handle(_ item: TodayAgendaItem) {
        switch item.kind {
        case let .bake(bakeID):
            router.openBake(bakeID)
        case let .starter(starterID):
            refreshStarter = starters.first(where: { $0.id == starterID })
        }
    }
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
        if let first = agenda[.now]?.first {
            heroSubtitle = "Priorita attuale: \(first.title.lowercased())."
        } else if let first = agenda[.upcoming]?.first {
            heroSubtitle = "Prossimo step: \(first.title.lowercased())."
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

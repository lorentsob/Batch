import SwiftData
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.lastRefresh, order: .reverse) private var starters: [Starter]

    @State private var refreshStarter: Starter?

    private var agenda: [TodayAgendaItem.Section: [TodayAgendaItem]] {
        TodayAgendaBuilder.build(bakes: Array(bakes), starters: Array(starters))
    }

    private var actionCount: Int {
        agenda.values.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Oggi")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.ink)

                SectionCard {
                    Text("Cosa devi fare adesso?")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)

                    Text(heroSubtitle)
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 12) {
                        StateBadge(text: "\(actionCount) azioni")
                        StateBadge(text: "\(bakes.filter { $0.derivedStatus == .inProgress }.count) impasti attivi")
                    }
                }

                if actionCount == 0 {
                    EmptyStateView(
                        title: "Giornata leggera",
                        message: "Non ci sono step urgenti o starter da rinfrescare. Puoi creare un nuovo bake dalla tab Impasti.",
                        actionTitle: "Vai a Impasti"
                    ) {
                        router.selectedTab = .bakes
                    }
                } else {
                    ForEach(TodayAgendaItem.Section.allCases) { section in
                        if let items = agenda[section], items.isEmpty == false {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.title)
                                    .font(.headline)
                                    .foregroundStyle(Theme.ink)

                                ForEach(items) { item in
                                    SectionCard {
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(item.title)
                                                    .font(.headline)
                                                    .foregroundStyle(Theme.ink)
                                                Text(item.subtitle)
                                                    .font(.subheadline)
                                                    .foregroundStyle(Theme.muted)
                                            }

                                            Spacer()
                                            StateBadge(text: item.state)
                                        }

                                        Button(item.actionTitle) {
                                            handle(item)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(Theme.accent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .sheet(item: $refreshStarter) { starter in
            NavigationStack {
                RefreshLogView(starter: starter)
            }
        }
    }

    private var heroSubtitle: String {
        if let first = agenda[.now]?.first {
            return "Priorita attuale: \(first.title.lowercased())."
        }
        if let first = agenda[.upcoming]?.first {
            return "Prossimo step: \(first.title.lowercased())."
        }
        if let first = agenda[.starter]?.first {
            return "Hai uno starter da controllare: \(first.title.lowercased())."
        }
        return "Tutto sotto controllo per ora."
    }

    private func handle(_ item: TodayAgendaItem) {
        switch item.kind {
        case let .bakeStep(bakeID, _):
            router.openBake(bakeID)
        case let .starter(starterID):
            refreshStarter = starters.first(where: { $0.id == starterID })
        }
    }
}

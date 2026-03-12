import SwiftUI
import SwiftData

struct StarterDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let starter: Starter

    @State private var showingEditor = false
    @State private var showingRefreshSheet = false

    private var sortedRefreshes: [StarterRefresh] {
        starter.refreshes.sorted { $0.dateTime > $1.dateTime }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StarterDetailHeaderView(starter: starter)

                SectionCard {
                    HStack {
                        Text("Ultimi rinfreschi")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        StateBadge(text: "\(sortedRefreshes.count)", tone: .count)
                    }

                    if sortedRefreshes.isEmpty {
                        Text("Ancora nessun log.")
                            .foregroundStyle(Theme.muted)
                    } else {
                        ForEach(sortedRefreshes.prefix(6)) { refresh in
                            RefreshHistoryRow(refresh: refresh)
                        }
                    }
                }

                if starter.bakes.isEmpty == false {
                    SectionCard {
                        HStack {
                            Text("Bake collegati")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            StateBadge(text: "\(starter.bakes.count)", tone: .count)
                        }

                        ForEach(starter.bakes.sorted { $0.targetBakeDateTime > $1.targetBakeDateTime }.prefix(4)) { bake in
                            Button {
                                router.openBake(bake.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(bake.name)
                                            .foregroundStyle(Theme.ink)
                                        HStack(spacing: 8) {
                                            StateBadge(bakeStatus: bake.derivedStatus)
                                            Text(DateFormattingService.dayTime(bake.targetBakeDateTime))
                                                .font(.footnote)
                                                .foregroundStyle(Theme.muted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Theme.muted)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                TipGroupView(items: environment.knowledgeLibrary.tips(for: starter.dueState())) { id in
                    router.openKnowledge(id)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Starter")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Modifica") {
                    showingEditor = true
                }
                Button("Rinfresca") {
                    showingRefreshSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                StarterEditorView(starter: starter)
            }
        }
        .sheet(isPresented: $showingRefreshSheet) {
            NavigationStack {
                RefreshLogView(starter: starter)
            }
        }
    }
}

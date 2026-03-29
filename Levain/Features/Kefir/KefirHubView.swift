import SwiftUI

/// Placeholder hub for Milk Kefir — full batch management ships in Phase 19.
struct KefirHubView: View {
    var body: some View {
        List {
            SectionCard(emphasis: .tinted) {
                Text("Milk kefir")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Gestisci i tuoi batch di kefir.")
                    .foregroundStyle(Theme.muted)
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                EmptyStateView(
                    title: "Nessun batch attivo",
                    message: "Il kefir arriverà presto. Per ora puoi gestire pane e lievito madre.",
                    actionTitle: "Nuovo batch"
                ) {
                    // Kefir batch creation — Phase 19
                }
            }
            .listRowInsets(.init(top: 16, leading: 20, bottom: 16, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .background(Theme.Surface.app)
        .navigationTitle("Milk kefir")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("KefirHubView")
    }
}

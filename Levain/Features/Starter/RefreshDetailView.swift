import SwiftUI
import SwiftData

struct RefreshDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let refresh: StarterRefresh

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with date
                SectionCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(DateFormattingService.dayTime(refresh.dateTime))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            if let starterName = refresh.starter?.name {
                                Text(starterName)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        Spacer()
                        if refresh.putInFridgeAt != nil {
                            StateBadge(text: "In frigo", tone: .info)
                        }
                    }
                }

                // Weights
                SectionCard {
                    Text("Pesi")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 94), spacing: 8)], alignment: .leading, spacing: 8) {
                        MetricChip(label: "Starter", value: "\(Int(refresh.starterWeightUsed)) g", tone: .info)
                        MetricChip(label: "Farina", value: "\(Int(refresh.flourWeight)) g", tone: .schedule)
                        MetricChip(label: "Acqua", value: "\(Int(refresh.waterWeight)) g", tone: .schedule)
                    }

                    if !refresh.ratioText.isEmpty {
                        StateBadge(text: "Rapporto \(refresh.ratioText)", tone: .info)
                    }
                }

                // Flour mix
                if !refresh.selectedFlours.isEmpty {
                    SectionCard {
                        Text("Mix Farine")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)

                        ForEach(refresh.selectedFlours) { flour in
                            HStack {
                                Text(flour.displayName)
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("\(Int(flour.percentage.rounded()))%")
                                    .foregroundStyle(Theme.muted)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // Details
                if refresh.ambientTemp > 0 || !refresh.notes.isEmpty {
                    SectionCard {
                        Text("Dettagli")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)

                        if refresh.ambientTemp > 0 {
                            HStack {
                                Text("Temperatura ambiente")
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("\(Int(refresh.ambientTemp))°C")
                                    .foregroundStyle(Theme.muted)
                            }
                        }

                        if !refresh.notes.isEmpty {
                            Text(refresh.notes)
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }

                // Fridge section
                SectionCard {
                    Text("Passaggio in frigo")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if let fridgeDate = refresh.putInFridgeAt {
                        HStack {
                            Image(systemName: "snowflake")
                                .foregroundStyle(Theme.accent)
                            Text("Messo in frigo alle \(DateFormattingService.dayTime(fridgeDate))")
                                .foregroundStyle(Theme.ink)
                        }
                    } else {
                        Text("Non ancora in frigo")
                            .foregroundStyle(Theme.muted)

                        Button {
                            registerFridgeTransfer()
                        } label: {
                            Label("Registra passaggio in frigo", systemImage: "snowflake")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.Control.primaryFill)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Dettaglio rinfresco")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
    }

    private func registerFridgeTransfer() {
        refresh.putInFridgeAt = Date.now
        try? modelContext.save()

        // Cancel the fridge reminder since it's been done
        Task {
            await environment.notificationService.cancelFridgeReminder(for: refresh)
        }

        environment.showBanner("Passaggio in frigo registrato", duration: 3)
    }
}

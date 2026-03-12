import SwiftUI
import SwiftData

struct RefreshLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let starter: Starter

    @State private var dateTime = Date.now
    @State private var flourWeight = 80.0
    @State private var waterWeight = 80.0
    @State private var starterWeightUsed = 20.0
    @State private var ratioText = "1:4:4"
    @State private var notes = ""
    @State private var ambientTemp = 0.0
    @State private var putInFridgeAt = Date.now
    @State private var recordFridgeTime = false
    @State private var showingAdvanced = false

    var body: some View {
        Form {
            Section("Rinfresco rapido") {
                NumericField(title: "Farina (g)", value: $flourWeight)
                NumericField(title: "Acqua (g)", value: $waterWeight)
                NumericField(title: "Starter usato (g)", value: $starterWeightUsed)
            }

            Section {
                DisclosureGroup(isExpanded: $showingAdvanced) {
                    DatePicker("Quando", selection: $dateTime)
                    TextField("Rapporto", text: $ratioText)
                    NumericField(title: "Temperatura ambiente (°C)", value: $ambientTemp)
                    Toggle("Registra passaggio in frigo", isOn: $recordFridgeTime)
                    if recordFridgeTime {
                        DatePicker("Messo in frigo alle", selection: $putInFridgeAt)
                    }
                    TextField("Note", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                } label: {
                    Text("Aggiungi dettagli")
                }
            }
        }
        .navigationTitle("Log rinfresco")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { save() }
            }
        }
    }

    private func save() {
        let refresh = StarterRefresh(
            dateTime: dateTime,
            flourWeight: flourWeight,
            waterWeight: waterWeight,
            starterWeightUsed: starterWeightUsed,
            ratioText: ratioText,
            putInFridgeAt: recordFridgeTime ? putInFridgeAt : nil,
            notes: notes,
            ambientTemp: ambientTemp,
            starter: starter
        )
        starter.lastRefresh = dateTime
        starter.refreshes.append(refresh)
        modelContext.insert(refresh)
        try? modelContext.save()

        Task {
            await environment.notificationService.syncNotifications(for: starter)
        }
        dismiss()
    }
}

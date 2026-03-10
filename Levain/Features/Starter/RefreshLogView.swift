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

    var body: some View {
        Form {
            Section("Rinfresco") {
                DatePicker("Quando", selection: $dateTime)
                NumericField(title: "Farina (g)", value: $flourWeight)
                NumericField(title: "Acqua (g)", value: $waterWeight)
                NumericField(title: "Starter usato (g)", value: $starterWeightUsed)
                TextField("Rapporto", text: $ratioText)
            }

            Section("Note") {
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle("Log rinfresco")
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
            notes: notes,
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

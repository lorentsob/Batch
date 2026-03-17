import SwiftUI
import SwiftData

struct RefreshLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let starter: Starter

    @State private var dateTime = Date.now
    @State private var flourWeight: Double
    @State private var waterWeight: Double
    @State private var starterWeightUsed: Double
    @State private var ratioText: String
    @State private var notes = ""
    @State private var ambientTemp = 0.0
    @State private var putInFridgeAt = Date.now
    @State private var recordFridgeTime = false
    @State private var flours: [FlourSelection]
    @State private var editingFlourID: UUID?

    init(starter: Starter) {
        self.starter = starter
        let last = starter.refreshes.max(by: { $0.dateTime < $1.dateTime })
        _flourWeight = State(initialValue: last?.flourWeight ?? 80.0)
        _waterWeight = State(initialValue: last?.waterWeight ?? 80.0)
        _starterWeightUsed = State(initialValue: last?.starterWeightUsed ?? 20.0)
        _ratioText = State(initialValue: last.flatMap { $0.ratioText.isEmpty ? nil : $0.ratioText } ?? "1:4:4")
        let lastFlours = last?.selectedFlours ?? []
        _flours = State(initialValue: lastFlours.isEmpty ? starter.selectedFlours : lastFlours)
    }

    var body: some View {
        Form {
            Section("Pesi") {
                NumericField(title: "Farina (g)", value: $flourWeight)
                NumericField(title: "Acqua (g)", value: $waterWeight)
                NumericField(title: "Starter usato (g)", value: $starterWeightUsed)
            }

            Section("Dettagli") {
                DatePicker("Quando", selection: $dateTime)
                TextField("Rapporto", text: $ratioText)
                NumericField(title: "Temperatura ambiente (°C)", value: $ambientTemp)
            }

            Section("Mix Farine") {
                ForEach(flours) { flour in
                    Button {
                        editingFlourID = flour.id
                    } label: {
                        HStack {
                            Text(flour.displayName)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text("\(Int(flour.percentage.rounded()))%")
                                .foregroundStyle(Theme.muted)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indices in
                    flours.remove(atOffsets: indices)
                }
                Button {
                    let newFlour = FlourSelection(
                        categoryRaw: FlourCategory.strong.rawValue,
                        customName: "",
                        percentage: 100
                    )
                    flours.append(newFlour)
                    editingFlourID = newFlour.id
                } label: {
                    Label("Aggiungi farina", systemImage: "plus")
                }

                let sum = flours.reduce(0) { $0 + $1.percentage }
                if sum != 100 && !flours.isEmpty {
                    Text("Attenzione: il totale è \(sum, specifier: "%.1f")% (dovrebbe essere 100%)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("Passaggio in frigo") {
                Toggle("Messo subito in frigo", isOn: $recordFridgeTime)
                if recordFridgeTime {
                    DatePicker("Messo in frigo alle", selection: $putInFridgeAt)
                }
            }

            Section("Note") {
                TextField("Note sul rinfresco", text: $notes, axis: .vertical)
                    .lineLimit(2...5)
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
        .sheet(isPresented: editingFlourSheetBinding) {
            NavigationStack {
                if let editingFlourIndex {
                    FlourSelectionEditorView(flour: $flours[editingFlourIndex])
                }
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
            flours: flours,
            starter: starter
        )
        starter.lastRefresh = dateTime
        starter.refreshes.append(refresh)
        modelContext.insert(refresh)
        try? modelContext.save()

        let starterID = starter.id
        let ctx = modelContext
        Task {
            await environment.notificationService.syncNotifications(for: starterID, in: ctx)
            if !recordFridgeTime {
                await environment.notificationService.scheduleFridgeReminder(for: refresh, starterName: starter.name)
            }
        }
        environment.showBanner("Rinfresco salvato per \(starter.name)", duration: 3)
        dismiss()
    }

    private var editingFlourSheetBinding: Binding<Bool> {
        Binding(
            get: { editingFlourIndex != nil },
            set: { isPresented in
                if isPresented == false {
                    editingFlourID = nil
                }
            }
        )
    }

    private var editingFlourIndex: Int? {
        guard let editingFlourID else { return nil }
        return flours.firstIndex(where: { $0.id == editingFlourID })
    }
}

import SwiftData
import SwiftUI

struct StarterView: View {
    @Query(sort: \Starter.name) private var starters: [Starter]

    @State private var showingEditor = false
    @State private var editingStarter: Starter?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Starter")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Gestisci routine, stato di salute e cronologia rinfreschi.")
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: "\(starters.count) starter")
                }

                if starters.isEmpty {
                    EmptyStateView(
                        title: "Nessuno starter configurato",
                        message: "Crea il primo starter per far emergere promemoria e log di rinfresco.",
                        actionTitle: "Nuovo starter"
                    ) {
                        editingStarter = nil
                        showingEditor = true
                    }
                } else {
                    ForEach(starters) { starter in
                        NavigationLink(value: StarterRoute.detail(starter.id)) {
                            SectionCard {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(starter.name)
                                            .font(.headline)
                                            .foregroundStyle(Theme.ink)
                                        Text("\(starter.type.title) · \(Int(starter.hydration.rounded()))% idratazione")
                                            .font(.subheadline)
                                            .foregroundStyle(Theme.muted)
                                        Text("Prossimo rinfresco: \(DateFormattingService.dayTime(starter.nextDueDate))")
                                            .font(.footnote)
                                            .foregroundStyle(Theme.muted)
                                    }
                                    Spacer()
                                    StateBadge(text: starter.dueState().title)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Modifica") {
                                editingStarter = starter
                                showingEditor = true
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
        .navigationTitle("Starter")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingStarter = nil
                    showingEditor = true
                } label: {
                    Label("Nuovo starter", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                StarterEditorView(starter: editingStarter)
            }
        }
    }
}

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
                SectionCard {
                    Text(starter.name)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("\(starter.type.title) · \(starter.storageMode.title)")
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 12) {
                        StateBadge(text: starter.dueState().title)
                        StateBadge(text: "ogni \(starter.refreshIntervalDays) gg")
                    }

                    if starter.flourMix.isEmpty == false {
                        Text("Farina: \(starter.flourMix)")
                            .foregroundStyle(Theme.muted)
                    }
                    if starter.notes.isEmpty == false {
                        Text(starter.notes)
                            .foregroundStyle(Theme.muted)
                    }
                }

                SectionCard {
                    Text("Ultimi rinfreschi")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if sortedRefreshes.isEmpty {
                        Text("Ancora nessun log.")
                            .foregroundStyle(Theme.muted)
                    } else {
                        ForEach(sortedRefreshes.prefix(6)) { refresh in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(DateFormattingService.dayTime(refresh.dateTime))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Text("\(Int(refresh.starterWeightUsed)) g starter · \(Int(refresh.flourWeight)) g farina · \(Int(refresh.waterWeight)) g acqua")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                                if refresh.ratioText.isEmpty == false {
                                    Text("Rapporto \(refresh.ratioText)")
                                        .font(.footnote)
                                        .foregroundStyle(Theme.muted)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }

                if starter.bakes.isEmpty == false {
                    SectionCard {
                        Text("Bake collegati")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)

                        ForEach(starter.bakes.sorted { $0.targetBakeDateTime > $1.targetBakeDateTime }.prefix(4)) { bake in
                            Button {
                                router.openBake(bake.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(bake.name)
                                            .foregroundStyle(Theme.ink)
                                        Text(DateFormattingService.dayTime(bake.targetBakeDateTime))
                                            .font(.footnote)
                                            .foregroundStyle(Theme.muted)
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

struct StarterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let starter: Starter?

    @State private var name: String
    @State private var type: StarterType
    @State private var hydration: Double
    @State private var flourMix: String
    @State private var containerWeight: Double
    @State private var storageMode: StorageMode
    @State private var refreshIntervalDays: Int
    @State private var remindersEnabled: Bool
    @State private var notes: String

    init(starter: Starter?) {
        self.starter = starter
        _name = State(initialValue: starter?.name ?? "")
        _type = State(initialValue: starter?.type ?? .mixed)
        _hydration = State(initialValue: starter?.hydration ?? 100)
        _flourMix = State(initialValue: starter?.flourMix ?? "")
        _containerWeight = State(initialValue: starter?.containerWeight ?? 0)
        _storageMode = State(initialValue: starter?.storageMode ?? .fridge)
        _refreshIntervalDays = State(initialValue: starter?.refreshIntervalDays ?? 7)
        _remindersEnabled = State(initialValue: starter?.remindersEnabled ?? true)
        _notes = State(initialValue: starter?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Identita") {
                TextField("Nome starter", text: $name)
                Picker("Tipo", selection: $type) {
                    ForEach(StarterType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            }

            Section("Setup") {
                NumericField(title: "Idratazione (%)", value: $hydration)
                TextField("Mix farine", text: $flourMix)
                NumericField(title: "Peso contenitore (g)", value: $containerWeight)
                Picker("Conservazione", selection: $storageMode) {
                    ForEach(StorageMode.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Stepper("Intervallo rinfresco: \(refreshIntervalDays) giorni", value: $refreshIntervalDays, in: 1...14)
                Toggle("Reminder attivi", isOn: $remindersEnabled)
            }

            Section("Note") {
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(starter == nil ? "Nuovo starter" : "Modifica starter")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        if let starter {
            starter.name = name
            starter.type = type
            starter.hydration = hydration
            starter.flourMix = flourMix
            starter.containerWeight = containerWeight
            starter.storageMode = storageMode
            starter.refreshIntervalDays = refreshIntervalDays
            starter.remindersEnabled = remindersEnabled
            starter.notes = notes
        } else {
            let newStarter = Starter(
                name: name,
                type: type,
                hydration: hydration,
                flourMix: flourMix,
                containerWeight: containerWeight,
                storageMode: storageMode,
                refreshIntervalDays: refreshIntervalDays,
                remindersEnabled: remindersEnabled,
                notes: notes
            )
            modelContext.insert(newStarter)
        }

        try? modelContext.save()
        dismiss()
    }
}

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

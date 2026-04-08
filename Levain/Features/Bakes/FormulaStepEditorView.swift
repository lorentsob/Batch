import SwiftUI

struct FormulaStepEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let initialStep: FormulaStepTemplate
    let onSave: (FormulaStepTemplate) -> Void

    @State private var type: BakeStepType
    @State private var name: String
    @State private var details: String
    @State private var durationMinutes: Int
    @State private var reminderOffsetMinutes: Int
    @State private var temperatureRange: String
    @State private var volumeTarget: String
    @State private var notes: String
    @State private var showingDurationPicker = false
    @State private var showingReminderPicker = false

    init(step: FormulaStepTemplate, onSave: @escaping (FormulaStepTemplate) -> Void) {
        initialStep = step
        self.onSave = onSave
        _type = State(initialValue: step.type)
        _name = State(initialValue: step.name)
        _details = State(initialValue: step.details)
        _durationMinutes = State(initialValue: step.durationMinutes)
        _reminderOffsetMinutes = State(initialValue: step.reminderOffsetMinutes)
        _temperatureRange = State(initialValue: step.temperatureRange)
        _volumeTarget = State(initialValue: step.volumeTarget)
        _notes = State(initialValue: step.notes)
    }

    var body: some View {
        Form {
            Section("Fase") {
                Picker("Tipo", selection: $type) {
                    ForEach(BakeStepType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                LabeledContent("Nome della fase") {
                    TextField("es. Autolisi", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Dettagli")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    TextEditor(text: $details)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }

            Section("Timing") {
                Button {
                    showingDurationPicker = true
                } label: {
                    HStack {
                        Text("Durata")
                        Spacer()
                        Text(DateFormattingService.duration(minutes: durationMinutes))
                            .foregroundStyle(Theme.muted)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    showingReminderPicker = true
                } label: {
                    HStack {
                        Text("Promemoria")
                        Spacer()
                        Text(reminderOffsetMinutes == 0 ? "Nessun promemoria" : "\(reminderOffsetMinutes) min prima")
                            .foregroundStyle(Theme.muted)
                    }
                }
                .buttonStyle(.plain)
            }

            Section("Target qualitativi") {
                LabeledContent("Temperatura") {
                    TextField("es. 24-26°C", text: $temperatureRange)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Target volume") {
                    TextField("es. Raddoppio", text: $volumeTarget)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    TextEditor(text: $notes)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
        }
        .navigationTitle(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Fase" : name)
        .scrollContentBackground(.hidden)
        .background(Theme.Surface.app)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") {
                    onSave(
                        FormulaStepTemplate(
                            id: initialStep.id,
                            type: type,
                            name: name,
                            details: details,
                            durationMinutes: durationMinutes,
                            reminderOffsetMinutes: reminderOffsetMinutes,
                            temperatureRange: temperatureRange,
                            volumeTarget: volumeTarget,
                            notes: notes,
                            ingredients: initialStep.ingredients
                        )
                    )
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $showingDurationPicker) {
            DurationPickerSheet(selection: $durationMinutes)
        }
        .sheet(isPresented: $showingReminderPicker) {
            ReminderOffsetPickerSheet(selection: $reminderOffsetMinutes)
        }
    }
}

private struct DurationPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: Int
    private let values: [Int] = Array(stride(from: 5, through: 24 * 60, by: 5))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Durata fase", selection: $selection) {
                    ForEach(values, id: \.self) { value in
                        Text(DateFormattingService.duration(minutes: value))
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Theme.Surface.app.ignoresSafeArea())
            .navigationTitle("Durata fase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Conferma") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.38)])
    }
}

private struct ReminderOffsetPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: Int

    private let values: [Int] = Array(stride(from: 0, through: 180, by: 5))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Promemoria", selection: $selection) {
                    ForEach(values, id: \.self) { value in
                        if value == 0 {
                            Text("Nessun promemoria")
                                .tag(value)
                        } else {
                            Text("\(value) min prima")
                                .tag(value)
                        }
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Theme.Surface.app.ignoresSafeArea())
            .navigationTitle("Promemoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Conferma") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.38)])
    }
}

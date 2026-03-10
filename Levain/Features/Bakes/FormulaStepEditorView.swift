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
            Section("Step") {
                Picker("Tipo", selection: $type) {
                    ForEach(BakeStepType.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                TextField("Nome", text: $name)
                TextField("Descrizione", text: $details, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Timing") {
                Stepper("Durata: \(DateFormattingService.duration(minutes: durationMinutes))", value: $durationMinutes, in: 5...24 * 60, step: 5)
                Stepper("Reminder: \(reminderOffsetMinutes) min prima", value: $reminderOffsetMinutes, in: 0...180, step: 5)
            }

            Section("Target qualitativi") {
                TextField("Temperatura", text: $temperatureRange)
                TextField("Target volume", text: $volumeTarget)
                TextField("Note", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle("Step formula")
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
                            notes: notes
                        )
                    )
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

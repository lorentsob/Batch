import SwiftUI

struct FlourSelectionEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var flour: FlourSelection
    @State private var showingPercentagePicker = false

    private let percentageValues = Array(stride(from: 0, through: 100, by: 5))

    var body: some View {
        Form {
            Section("Tipo farina") {
                ForEach(FlourCategory.allCases) { category in
                    Button {
                        flour.category = category
                    } label: {
                        HStack {
                            Text(category.title)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            if flour.category == category {
                                Image(systemName: "checkmark")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Theme.Control.primaryFill)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if flour.category == .custom {
                    TextField("Nome personalizzato", text: $flour.customName)
                }
            }

            Section("Quantità") {
                Button {
                    showingPercentagePicker = true
                } label: {
                    SelectionFormRow(
                        title: "Percentuale sul totale flour",
                        value: "\(Int(flour.percentage.rounded()))%"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Farina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Conferma") { dismiss() }
            }
        }
        .sheet(isPresented: $showingPercentagePicker) {
            StepValuePickerSheet(
                title: "Percentuale",
                values: percentageValues,
                selection: percentageSelection,
                unit: "%"
            )
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Theme.Surface.app)
    }

    private var percentageSelection: Binding<Int> {
        Binding(
            get: { Int(flour.percentage.rounded()) },
            set: { flour.percentage = Double($0) }
        )
    }
}

struct SelectionFormRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.ink)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.muted)
        }
    }
}

struct StepValuePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let values: [Int]
    @Binding var selection: Int
    let unit: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(title, selection: $selection) {
                    ForEach(values, id: \.self) { value in
                        Text("\(value)\(unit)")
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(title)
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
        .presentationBackground(Theme.Surface.app)
    }
}

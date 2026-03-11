import SwiftUI

struct FlourSelectionEditorView: View {
    @Binding var flour: FlourSelection

    var body: some View {
        Form {
            Section("Tipo farina") {
                Picker("Categoria", selection: $flour.category) {
                    ForEach(FlourCategory.allCases) { category in
                        Text(category.title).tag(category)
                    }
                }
                
                if flour.category == .custom {
                    TextField("Nome personalizzato", text: $flour.customName)
                }
            }
            
            Section("Quantità") {
                HStack {
                    Text("Percentuale sul totale flour")
                    Spacer()
                    TextField("0", value: $flour.percentage, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("%")
                }
            }
        }
        .navigationTitle("Modifica Farina")
        .navigationBarTitleDisplayMode(.inline)
    }
}

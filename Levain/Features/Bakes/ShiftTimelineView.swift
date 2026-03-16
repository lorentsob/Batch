import SwiftData
import SwiftUI

struct ShiftTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    let bake: Bake
    let anchorStep: BakeStep

    @State private var shiftMinutes = 15

    var body: some View {
        Form {
            Section("Fase selezionata") {
                Text(anchorStep.displayName)
                Text("Sposterai la fase selezionata e tutte le fasi successive non completate.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }

            Section("Spostamento") {
                Stepper("Sposta di: \(shiftMinutes) min", value: $shiftMinutes, in: -120...240, step: 5)

                HStack {
                    ForEach([-30, -15, 15, 30, 60], id: \.self) { option in
                        Button(option > 0 ? "+\(option)" : "\(option)") {
                            shiftMinutes = option
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("Sposta gli orari")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Applica") {
                    BakeScheduler.shiftFutureSteps(in: bake, after: anchorStep, by: shiftMinutes)
                    try? modelContext.save()
                    Task {
                        await environment.notificationService.syncNotifications(for: bake)
                    }
                    dismiss()
                }
            }
        }
    }
}

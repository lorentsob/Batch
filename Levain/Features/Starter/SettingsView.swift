import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment

    @Query private var appSettingsList: [AppSettings]

    @State private var exportURL: URL?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var pendingImportURL: URL?
    @State private var showingRestoreConfirmation = false
    @State private var errorMessage: String?
    @State private var isProcessing = false

    private var appSettings: AppSettings? { appSettingsList.first }

    var body: some View {
        Form {
            if let settings = appSettings {
                Section("Sezioni attive") {
                    Text("Attiva o disattiva le sezioni. Le sezioni disattivate non compaiono in Oggi o in Batch.")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)

                    Toggle(isOn: Binding(
                        get: { settings.isBakeEnabled },
                        set: { settings.isBakeEnabled = $0 }
                    )) {
                        Label {
                            Text("Impasti")
                        } icon: {
                            Image("navbar-bake")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }

                    Toggle(isOn: Binding(
                        get: { settings.isStarterEnabled },
                        set: { settings.isStarterEnabled = $0 }
                    )) {
                        Label {
                            Text("Starter (lievito madre)")
                        } icon: {
                            Image("navbar-starter")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }

                    Toggle(isOn: Binding(
                        get: { settings.isKefirEnabled },
                        set: { settings.isKefirEnabled = $0 }
                    )) {
                        Label("Kefir", systemImage: "drop.fill")
                    }
                }
            }

            Section("Backup") {
                Text("Esporta o ripristina solo i dati utente. Guide e modelli di sistema restano nell'app.")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)

                Button {
                    exportBackup()
                } label: {
                    Label("Esporta backup", systemImage: "square.and.arrow.up")
                }
                .disabled(isProcessing)

                Button(role: .destructive) {
                    showingImporter = true
                } label: {
                    Label("Importa backup", systemImage: "arrow.down.doc")
                }
                .disabled(isProcessing)
            }

            Section("Contenuto incluso") {
                Text("Starter, rinfreschi, ricette salvate, impasti e fasi.")
                Text("Non include guide, modelli di sistema o preferenze dell'app.")
                    .foregroundStyle(Theme.muted)
            }
        }
        .navigationTitle("Impostazioni")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingExporter) {
            if let exportURL {
                ActivityView(items: [exportURL])
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                pendingImportURL = urls.first
                showingRestoreConfirmation = pendingImportURL != nil
            case let .failure(error):
                errorMessage = error.localizedDescription
            }
        }
        .alert("Sostituire i dati correnti?", isPresented: $showingRestoreConfirmation, presenting: pendingImportURL) { url in
            Button("Annulla", role: .cancel) {
                pendingImportURL = nil
            }
            Button("Importa", role: .destructive) {
                restoreBackup(from: url)
            }
        } message: { _ in
            Text("L'import sostituirà starter, ricette, impasti e fasi attuali con il contenuto del backup selezionato.")
        }
        .alert("Operazione non riuscita", isPresented: Binding(
            get: { errorMessage != nil },
            set: { newValue in
                if newValue == false {
                    errorMessage = nil
                }
            }
        )) {
            Button("Chiudi", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func exportBackup() {
        do {
            let data = try BackupService.exportData(using: modelContext)
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(defaultFilename)
                .appendingPathExtension("json")
            try data.write(to: fileURL, options: .atomic)
            exportURL = fileURL
            showingExporter = true
            environment.showBanner("Backup pronto per l'esportazione.")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restoreBackup(from url: URL) {
        isProcessing = true

        defer {
            isProcessing = false
            pendingImportURL = nil
        }

        let didAccessScopedResource = url.startAccessingSecurityScopedResource()
        defer {
            if didAccessScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            try BackupService.restore(from: data, into: modelContext)
            Task {
                await environment.notificationService.resyncAll(using: modelContext)
            }
            environment.showBanner("Backup importato. Notifiche riallineate.")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var defaultFilename: String {
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: .now)
            .replacingOccurrences(of: ":", with: "-")
        return "levain-backup-\(timestamp)"
    }
}

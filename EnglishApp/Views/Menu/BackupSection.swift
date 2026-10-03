import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BackupSection: View {
    @Environment(\.modelContext) private var context
    @State private var exportDocument: BackupDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var pendingRestore: Backup?
    @State private var errorMessage: String?

    var body: some View {
        Section("Backup") {
            Button("Create backup", action: createBackup)
            Button("Restore from backup") { isImporting = true }
        }
        .listRowBackground(Theme.card)
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "english-backup-\(Date.now.formatted(.iso8601.year().month().day()))"
        ) { result in
            if case .failure(let error) = result { errorMessage = error.localizedDescription }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: readBackup)
        .confirmationDialog(
            "Restore this backup?", isPresented: restoreDialogBinding, titleVisibility: .visible
        ) {
            Button("Restore", role: .destructive, action: restore)
        } message: {
            Text("Current progress and history will be replaced.")
        }
        .alert("Backup failed", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var restoreDialogBinding: Binding<Bool> {
        Binding(get: { pendingRestore != nil }, set: { if !$0 { pendingRestore = nil } })
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func createBackup() {
        do {
            exportDocument = BackupDocument(backup: try BackupService.make(from: context))
            isExporting = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func readBackup(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else { throw CocoaError(.fileReadNoPermission) }
            defer { url.stopAccessingSecurityScopedResource() }
            pendingRestore = try Backup.decoded(from: Data(contentsOf: url))
        } catch {
            errorMessage = "This file is not a valid backup."
        }
    }

    private func restore() {
        guard let backup = pendingRestore else { return }
        do {
            try BackupService.restore(backup, into: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

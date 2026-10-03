import SwiftData
import SwiftUI

struct MenuView: View {
    @Environment(\.modelContext) private var context
    @AppStorage(Preferences.userName) private var userName = ""
    @AppStorage(Preferences.theme) private var theme = AppTheme.system
    @State private var confirmingReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your name", text: $userName)
                        .onChange(of: userName, initial: true) { _, name in
                            if name.count > Preferences.maxNameLength {
                                userName = String(name.prefix(Preferences.maxNameLength))
                            }
                        }
                }
                .listRowBackground(Theme.card)
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        ForEach(AppTheme.allCases, id: \.self) { Text($0.label) }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Theme.card)
                BackupSection()
                Section {
                    Button("Reset progress", role: .destructive) { confirmingReset = true }
                }
                .listRowBackground(Theme.card)
                Section {
                    LabeledContent("Version", value: version)
                }
                .listRowBackground(Theme.card)
            }
            .themedScreen()
            .navigationTitle("Menu")
            .confirmationDialog("Reset all progress?", isPresented: $confirmingReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive, action: resetProgress)
            }
        }
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private func resetProgress() {
        try? context.fetch(FetchDescriptor<Word>()).forEach { $0.resetProgress() }
        try? context.delete(model: StudyEvent.self)
    }
}

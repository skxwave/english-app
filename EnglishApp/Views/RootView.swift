import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var context
    @AppStorage(Preferences.theme) private var theme = AppTheme.system
    @AppStorage(Preferences.remindersEnabled) private var remindersEnabled = true

    var body: some View {
        TabView {
            LearnView()
                .tabItem { Label("Learn", systemImage: "graduationcap") }
            VocabularyView()
                .tabItem { Label("Vocabulary", systemImage: "books.vertical") }
            MenuView()
                .tabItem { Label("Menu", systemImage: "line.3.horizontal") }
        }
        .tint(Theme.accent)
        .preferredColorScheme(theme.colorScheme)
        .task {
            if remindersEnabled { await ReminderScheduler.requestAuthorization() }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active: ReminderScheduler.clear()
            case .background where remindersEnabled: ReminderScheduler.refresh(in: context)
            default: break
            }
        }
    }
}

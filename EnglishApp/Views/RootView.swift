import SwiftUI

struct RootView: View {
    @AppStorage(Preferences.theme) private var theme = AppTheme.system

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
    }
}

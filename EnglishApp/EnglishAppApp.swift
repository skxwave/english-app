import SwiftData
import SwiftUI

@main
struct EnglishAppApp: App {
    let container: ModelContainer = {
        let container = try! ModelContainer(for: Pack.self, Word.self, StudyEvent.self)
        Seeder.syncIfNeeded(container.mainContext)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

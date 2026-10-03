import SwiftData
import SwiftUI

@main
struct EnglishAppApp: App {
    let container: ModelContainer = {
        let container = try! ModelContainer(for: Pack.self, Word.self)
        Seeder.seedIfEmpty(container.mainContext)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            PackListView()
        }
        .modelContainer(container)
    }
}

import Foundation
import SwiftData

enum Seeder {
    private struct PackDTO: Decodable {
        struct WordDTO: Decodable {
            let term: String
            let meaning: String
        }
        let name: String
        let summary: String
        let words: [WordDTO]
    }

    static func seedIfEmpty(_ context: ModelContext) {
        guard (try? context.fetchCount(FetchDescriptor<Pack>())) == 0 else { return }
        let url = Bundle.main.url(forResource: "packs", withExtension: "json")!
        let packs = try! JSONDecoder().decode([PackDTO].self, from: Data(contentsOf: url))
        for dto in packs {
            let pack = Pack(name: dto.name, summary: dto.summary)
            context.insert(pack)
            pack.words = dto.words.map { Word(term: $0.term, meaning: $0.meaning) }
        }
        try? context.save()
    }
}

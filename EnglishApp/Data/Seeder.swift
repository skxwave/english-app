import Foundation
import SwiftData

enum Seeder {
    private struct PackDTO: Decodable {
        struct WordDTO: Decodable {
            let term: String
            let pos: String
            let translation: String
            let ipaUK: String
            let ipaUS: String
            let audioUK: String
            let audioUS: String
            let image: String
            let examples: [WordExample]
        }
        let name: String
        let level: String
        let icon: String
        let words: [WordDTO]
    }

    // Bump when packs.json changes; the import is heavy so it only runs on a version change.
    private static let contentVersion = 3
    private static let versionKey = "contentVersion"

    static func syncIfNeeded(_ context: ModelContext, defaults: UserDefaults = .standard) {
        guard defaults.integer(forKey: versionKey) != contentVersion else { return }
        sync(context)
        defaults.set(contentVersion, forKey: versionKey)
    }

    // Upserts by pack name and word (term + part of speech) so progress survives content edits.
    // Packs missing from the bundle are deleted together with their words.
    private static func sync(_ context: ModelContext) {
        let bundled = bundledPacks()
        let existing = (try? context.fetch(FetchDescriptor<Pack>())) ?? []
        let bundledNames = Set(bundled.map(\.name))
        existing.filter { !bundledNames.contains($0.name) }.forEach(context.delete)

        let packsByName = Dictionary(uniqueKeysWithValues: existing.filter { bundledNames.contains($0.name) }.map { ($0.name, $0) })
        var packs: [Pack] = []
        for dto in bundled {
            let pack = packsByName[dto.name] ?? insertPack(dto, in: context)
            pack.level = dto.level
            pack.icon = dto.icon
            merge(dto.words, into: pack)
            packs.append(pack)
        }
        if !packs.contains(where: \.isSelected) {
            packs.first?.isSelected = true
        }
        try? context.save()
    }

    private static func bundledPacks() -> [PackDTO] {
        let url = Bundle.main.url(forResource: "packs", withExtension: "json")!
        return try! JSONDecoder().decode([PackDTO].self, from: Data(contentsOf: url))
    }

    private static func insertPack(_ dto: PackDTO, in context: ModelContext) -> Pack {
        let pack = Pack(name: dto.name, level: dto.level, icon: dto.icon)
        context.insert(pack)
        return pack
    }

    private static func merge(_ dtos: [PackDTO.WordDTO], into pack: Pack) {
        let wordsByKey = Dictionary(pack.words.map { (key($0.term, $0.partOfSpeech), $0) }, uniquingKeysWith: { first, _ in first })
        for dto in dtos {
            let word = wordsByKey[key(dto.term, dto.pos)] ?? makeWord(dto, in: pack)
            apply(dto, to: word)
        }
    }

    private static func makeWord(_ dto: PackDTO.WordDTO, in pack: Pack) -> Word {
        let word = Word(term: dto.term, partOfSpeech: dto.pos)
        pack.words.append(word)
        return word
    }

    private static func apply(_ dto: PackDTO.WordDTO, to word: Word) {
        word.translation = dto.translation
        word.ipaUK = dto.ipaUK
        word.ipaUS = dto.ipaUS
        word.audioUK = dto.audioUK
        word.audioUS = dto.audioUS
        word.imageURL = dto.image
        word.examples = dto.examples
    }

    private static func key(_ term: String, _ partOfSpeech: String) -> String {
        "\(term)|\(partOfSpeech)"
    }
}

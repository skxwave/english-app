import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct Backup: Codable {
    struct WordProgress: Codable {
        let pack: String
        let term: String
        let partOfSpeech: String
        let status: WordStatus
        let step: Int
        let dueDate: Date?
    }

    struct PackSelection: Codable {
        let name: String
        let isSelected: Bool
    }

    struct EventRecord: Codable {
        let date: Date
        let kind: StudyEventKind
    }

    struct Settings: Codable {
        let userName: String?
        let dailyGoal: Int?
        let theme: String?
    }

    let version: Int
    let createdAt: Date
    let words: [WordProgress]
    let packs: [PackSelection]
    let events: [EventRecord]
    let settings: Settings

    static let currentVersion = 2

    static func encoded(_ backup: Backup) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(backup)
    }

    static func decoded(from data: Data) throws -> Backup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Backup.self, from: data)
    }
}

enum BackupService {
    static func make(from context: ModelContext, defaults: UserDefaults = .standard) throws -> Backup {
        let packs = try context.fetch(FetchDescriptor<Pack>())
        let events = try context.fetch(FetchDescriptor<StudyEvent>())
        return Backup(
            version: Backup.currentVersion,
            createdAt: .now,
            words: packs.flatMap { pack in
                pack.words.filter { $0.status != .new }.map {
                    Backup.WordProgress(pack: pack.name, term: $0.term, partOfSpeech: $0.partOfSpeech, status: $0.status, step: $0.step, dueDate: $0.dueDate)
                }
            },
            packs: packs.map { Backup.PackSelection(name: $0.name, isSelected: $0.isSelected) },
            events: events.map { Backup.EventRecord(date: $0.date, kind: $0.kind) },
            settings: Backup.Settings(
                userName: defaults.string(forKey: Preferences.userName),
                dailyGoal: defaults.object(forKey: Preferences.dailyGoal) as? Int,
                theme: defaults.string(forKey: Preferences.theme)
            )
        )
    }

    // Full replace: progress and history not in the backup are discarded.
    static func restore(_ backup: Backup, into context: ModelContext, defaults: UserDefaults = .standard) throws {
        let packs = try context.fetch(FetchDescriptor<Pack>())
        packs.flatMap(\.words).forEach { $0.resetProgress() }
        applyProgress(backup.words, to: packs)
        applySelection(backup.packs, to: packs)
        try context.delete(model: StudyEvent.self)
        backup.events.forEach { context.insert(StudyEvent(kind: $0.kind, date: $0.date)) }
        apply(backup.settings, to: defaults)
        try context.save()
    }

    private static func applyProgress(_ progress: [Backup.WordProgress], to packs: [Pack]) {
        let wordsByKey = Dictionary(
            packs.flatMap { pack in pack.words.map { (Key(pack: pack.name, term: $0.term, partOfSpeech: $0.partOfSpeech), $0) } },
            uniquingKeysWith: { first, _ in first }
        )
        for entry in progress {
            guard let word = wordsByKey[Key(pack: entry.pack, term: entry.term, partOfSpeech: entry.partOfSpeech)] else { continue }
            word.status = entry.status
            word.step = entry.step
            word.dueDate = entry.dueDate
        }
    }

    private static func applySelection(_ selection: [Backup.PackSelection], to packs: [Pack]) {
        for pack in packs {
            pack.isSelected = selection.first { $0.name == pack.name }?.isSelected ?? pack.isSelected
        }
    }

    private static func apply(_ settings: Backup.Settings, to defaults: UserDefaults) {
        if let name = settings.userName { defaults.set(name, forKey: Preferences.userName) }
        if let goal = settings.dailyGoal { defaults.set(goal, forKey: Preferences.dailyGoal) }
        if let theme = settings.theme { defaults.set(theme, forKey: Preferences.theme) }
    }

    private struct Key: Hashable {
        let pack: String
        let term: String
        let partOfSpeech: String
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let backup: Backup

    init(backup: Backup) {
        self.backup = backup
    }

    init(configuration: ReadConfiguration) throws {
        backup = try Backup.decoded(from: configuration.file.regularFileContents ?? Data())
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: try Backup.encoded(backup))
    }
}

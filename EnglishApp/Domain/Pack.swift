import Foundation
import SwiftData

@Model
final class Pack {
    var name: String
    var summary: String
    @Relationship(deleteRule: .cascade, inverse: \Word.pack) var words: [Word] = []

    init(name: String, summary: String) {
        self.name = name
        self.summary = summary
    }

    var masteredCount: Int {
        words.filter(\.isMastered).count
    }

    func nextWord(now: Date = .now) -> Word? {
        dueWord(at: now) ?? words.filter { $0.status == .new }.randomElement()
    }

    var nextReviewDate: Date? {
        words.filter { $0.status == .learning }.compactMap(\.dueDate).min()
    }

    private func dueWord(at now: Date) -> Word? {
        words
            .filter { $0.isDue(at: now) }
            .min { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
    }
}

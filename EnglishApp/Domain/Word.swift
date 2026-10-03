import Foundation
import SwiftData

enum WordStatus: String, Codable {
    case new, learning, known, learned
}

@Model
final class Word {
    var term: String
    var meaning: String
    var status: WordStatus = WordStatus.new
    var step: Int = 0
    var dueDate: Date?
    var pack: Pack?

    init(term: String, meaning: String) {
        self.term = term
        self.meaning = meaning
    }

    var isMastered: Bool {
        status == .known || status == .learned
    }

    func isDue(at now: Date) -> Bool {
        status == .learning && (dueDate ?? .distantPast) <= now
    }
}

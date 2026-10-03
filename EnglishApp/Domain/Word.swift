import Foundation
import SwiftData

enum WordStatus: String, Codable {
    case new, learning, known, learned
}

struct WordExample: Codable, Hashable {
    let en: String
    let uk: String
}

@Model
final class Word {
    var term: String
    var partOfSpeech: String = ""
    var translation: String = ""
    var ipaUK: String = ""
    var ipaUS: String = ""
    var audioUK: String = ""
    var audioUS: String = ""
    var imageURL: String = ""
    var examples: [WordExample] = []
    var status: WordStatus = WordStatus.new
    var step: Int = 0
    var dueDate: Date?
    var pack: Pack?

    init(term: String, partOfSpeech: String) {
        self.term = term
        self.partOfSpeech = partOfSpeech
    }

    var isMastered: Bool {
        status == .known || status == .learned
    }

    func resetProgress() {
        status = .new
        step = 0
        dueDate = nil
    }

    func isDue(at now: Date) -> Bool {
        status == .learning && (dueDate ?? .distantPast) <= now
    }
}

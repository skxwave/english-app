import Foundation

enum StudyMode: Hashable {
    case learnNew
    case review
}

enum StudyQueue {
    static func dueWords(in words: [Word], now: Date = .now) -> [Word] {
        words.filter { $0.isDue(at: now) }
    }

    static func nextReviewDate(in words: [Word]) -> Date? {
        words.filter { $0.status == .learning }.compactMap(\.dueDate).min()
    }
}

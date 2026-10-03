import Foundation

enum StudyMode: Hashable {
    case learnNew
    case review
}

enum StudyQueue {
    static func next(_ mode: StudyMode, in words: [Word], now: Date = .now) -> Word? {
        switch mode {
        case .learnNew:
            return words.filter { $0.status == .new && $0.pack?.isSelected == true }.randomElement()
        case .review:
            return dueWords(in: words, now: now)
                .min { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
        }
    }

    static func dueWords(in words: [Word], now: Date = .now) -> [Word] {
        words.filter { $0.isDue(at: now) }
    }

    static func nextReviewDate(in words: [Word]) -> Date? {
        words.filter { $0.status == .learning }.compactMap(\.dueDate).min()
    }
}

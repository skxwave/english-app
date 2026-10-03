import Foundation
import Observation

// A study round as an in-memory queue. A missed word goes back into the queue, nearer to
// the front each time it is missed, and the round ends only when every word was recalled.
@Observable
final class StudySession {
    private struct Entry {
        let word: Word
        var misses = 0
    }

    // Other cards shown before a missed word returns, by number of misses so far.
    private static let requeueGaps = [5, 3, 1]

    private var queue: [Entry]
    private var fresh: [Word]

    init(mode: StudyMode, words: [Word], remainingGoal: Int, now: Date = .now) {
        switch mode {
        case .learnNew:
            let pool = words.filter { $0.status == .new && $0.pack?.isSelected == true }.shuffled()
            queue = pool.prefix(remainingGoal).map { Entry(word: $0) }
            fresh = Array(pool.dropFirst(remainingGoal))
        case .review:
            queue = StudyQueue.dueWords(in: words, now: now)
                .sorted { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
                .map { Entry(word: $0) }
            fresh = []
        }
    }

    var current: Word? {
        queue.first?.word
    }

    func swipe(_ direction: SwipeDirection, now: Date = .now) -> StudyEventKind? {
        guard var entry = queue.first else { return nil }
        queue.removeFirst()
        let wasNew = entry.word.status == .new
        let kind = entry.word.swipe(direction, now: now)
        switch direction {
        case .left:
            entry.misses += 1
            requeue(entry)
        case .right where wasNew:
            drawFresh()
        case .right:
            break
        }
        return kind
    }

    private func requeue(_ entry: Entry) {
        let gap = Self.requeueGaps[min(entry.misses, Self.requeueGaps.count) - 1]
        queue.insert(entry, at: min(gap, queue.count))
    }

    // Already-known words don't count toward the daily goal, so each one is replaced.
    private func drawFresh() {
        guard !fresh.isEmpty else { return }
        queue.append(Entry(word: fresh.removeFirst()))
    }
}

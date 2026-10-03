import Foundation

enum SwipeDirection {
    case left, right
}

// Ebbinghaus-style ladder. `Word.step` counts successful recalls: step 0 means "not recalled
// yet" (due now), and after the k-th recall the next review is `intervals[k - 1]` away.
// A word recalled after the last interval is learned.
enum SRS {
    static let intervals: [TimeInterval] = [
        30 * 60, 2 * 3600, 24 * 3600, 3 * 24 * 3600, 7 * 24 * 3600, 30 * 24 * 3600,
    ]
}

extension Word {
    func swipe(_ direction: SwipeDirection, now: Date = .now) -> StudyEventKind {
        let kind = eventKind(for: direction)
        switch direction {
        case .right: markRemembered(now: now)
        case .left: markForgotten(now: now)
        }
        return kind
    }

    private func eventKind(for direction: SwipeDirection) -> StudyEventKind {
        guard status == .new else { return .repeated }
        return direction == .right ? .known : .learned
    }

    private func markRemembered(now: Date) {
        guard status == .learning else {
            status = .known
            return
        }
        let next = step + 1
        guard next <= SRS.intervals.count else {
            status = .learned
            dueDate = nil
            return
        }
        step = next
        dueDate = now.addingTimeInterval(SRS.intervals[next - 1])
    }

    // Persisted immediately so a missed word isn't lost if the round is abandoned.
    private func markForgotten(now: Date) {
        status = .learning
        step = 0
        dueDate = now
    }
}

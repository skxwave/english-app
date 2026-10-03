import Foundation

enum SwipeDirection {
    case left, right
}

// Ebbinghaus-style ladder. Index = step the word is currently on; the value is the wait
// before its next review. Step 0 is the immediate in-session repeat.
enum SRS {
    static let intervals: [TimeInterval] = [
        60, 20 * 60, 24 * 3600, 3 * 24 * 3600, 7 * 24 * 3600, 30 * 24 * 3600,
    ]
}

extension Word {
    func swipe(_ direction: SwipeDirection, now: Date = .now) {
        switch direction {
        case .right: markRemembered(now: now)
        case .left: markForgotten(now: now)
        }
    }

    private func markRemembered(now: Date) {
        guard status == .learning else {
            status = .known
            return
        }
        let next = step + 1
        guard next < SRS.intervals.count else {
            status = .learned
            dueDate = nil
            return
        }
        step = next
        dueDate = now.addingTimeInterval(SRS.intervals[next])
    }

    private func markForgotten(now: Date) {
        status = .learning
        step = 0
        dueDate = now.addingTimeInterval(SRS.intervals[0])
    }
}

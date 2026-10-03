import Foundation

struct DailyKindCount: Identifiable {
    let day: Date
    let kind: StudyEventKind
    let count: Int

    var id: String { "\(day.timeIntervalSince1970)-\(kind.rawValue)" }
}

enum ActivityStats {
    static func totalsByDay(_ events: [StudyEvent], calendar: Calendar = .current) -> [Date: Int] {
        Dictionary(grouping: events) { calendar.startOfDay(for: $0.date) }.mapValues(\.count)
    }

    // A streak stays alive through today until the day ends, so an idle today doesn't zero it.
    static func streak(totals: [Date: Int], now: Date = .now, calendar: Calendar = .current) -> Int {
        var day = calendar.startOfDay(for: now)
        if totals[day] == nil {
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        var streak = 0
        while totals[day] != nil {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    static func newWordsToday(
        _ events: [StudyEvent], now: Date = .now, calendar: Calendar = .current
    ) -> Int {
        events.filter { $0.kind == .learned && calendar.isDate($0.date, inSameDayAs: now) }.count
    }

    static func lastWeek(
        _ events: [StudyEvent], now: Date = .now, calendar: Calendar = .current
    ) -> [DailyKindCount] {
        let today = calendar.startOfDay(for: now)
        let days = (0..<7).reversed().map { calendar.date(byAdding: .day, value: -$0, to: today)! }
        let counts = Dictionary(grouping: events) { Key(day: calendar.startOfDay(for: $0.date), kind: $0.kind) }
        return days.flatMap { day in
            StudyEventKind.allCases.map {
                DailyKindCount(day: day, kind: $0, count: counts[Key(day: day, kind: $0)]?.count ?? 0)
            }
        }
    }

    private struct Key: Hashable {
        let day: Date
        let kind: StudyEventKind
    }
}

import Foundation

struct Reminder: Equatable {
    let id: String
    let date: Date
    let title: String
    let body: String
}

enum ReminderPlan {
    // Each reminder fires as a burst of pings; opening the app cancels the rest.
    static let pingOffsets: [TimeInterval] = [0, 15 * 60, 45 * 60]
    static let learnHours = [10, 19]
    static let learnDays = 3
    static let maxReviewBursts = 10
    static let quietStartHour = 22
    static let quietEndHour = 8
    static var quietHoursLabel: String {
        String(format: "%02d:00–%02d:00", quietStartHour, quietEndHour)
    }

    static func make(
        now: Date,
        dueDates: [Date],
        canLearn: Bool,
        goalReached: Bool,
        calendar: Calendar = .current
    ) -> [Reminder] {
        let reminders = reviewReminders(now: now, dueDates: dueDates, calendar: calendar)
            + (canLearn ? learnReminders(now: now, goalReached: goalReached, calendar: calendar) : [])
        return reminders.sorted { $0.date < $1.date }
    }

    static func isQuiet(_ date: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return hour >= quietStartHour || hour < quietEndHour
    }

    static func outsideQuietHours(_ date: Date, calendar: Calendar = .current) -> Date {
        guard isQuiet(date, calendar: calendar) else { return date }
        let hour = calendar.component(.hour, from: date)
        let morning = calendar.date(bySettingHour: quietEndHour, minute: 0, second: 0, of: date)!
        return hour >= quietStartHour ? calendar.date(byAdding: .day, value: 1, to: morning)! : morning
    }

    private static func reviewReminders(now: Date, dueDates: [Date], calendar: Calendar) -> [Reminder] {
        let burstSpan = pingOffsets.last ?? 0
        var bursts: [Date] = []
        for due in dueDates.sorted() {
            let start = outsideQuietHours(max(due, now.addingTimeInterval(60)), calendar: calendar)
            if let last = bursts.last, start < last.addingTimeInterval(burstSpan) { continue }
            bursts.append(start)
        }
        return bursts.prefix(maxReviewBursts).flatMap { burst in
            pingOffsets.enumerated().compactMap { index, offset -> Reminder? in
                // Follow-ups that land in quiet hours are dropped, not deferred: they'd arrive stale.
                let date = burst.addingTimeInterval(offset)
                guard !isQuiet(date, calendar: calendar) else { return nil }
                let count = dueDates.filter { $0 <= date }.count
                return Reminder(
                    id: "review-\(Int(burst.timeIntervalSince1970))-\(index)",
                    date: date,
                    title: "Time to repeat",
                    body: reviewBody(count: count, ping: index)
                )
            }
        }
    }

    private static func learnReminders(now: Date, goalReached: Bool, calendar: Calendar) -> [Reminder] {
        let today = calendar.startOfDay(for: now)
        return (0..<learnDays).flatMap { day -> [Reminder] in
            learnHours.flatMap { hour -> [Reminder] in
                let start = calendar.date(byAdding: .day, value: day, to: today)!
                let slot = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: start)!
                guard slot > now, !(day == 0 && goalReached) else { return [] }
                return pingOffsets.enumerated().map { index, offset in
                    Reminder(
                        id: "learn-\(Int(slot.timeIntervalSince1970))-\(index)",
                        date: slot.addingTimeInterval(offset),
                        title: "Time to learn",
                        body: learnBody(ping: index)
                    )
                }
            }
        }
    }

    private static func reviewBody(count: Int, ping: Int) -> String {
        let words = count == 1 ? "1 word is" : "\(count) words are"
        switch ping {
        case 0: return "\(words) due. Two minutes keeps them in memory."
        case 1: return "Still waiting: \(words) due for review."
        default: return "Last nudge: repeat now before they fade."
        }
    }

    private static func learnBody(ping: Int) -> String {
        switch ping {
        case 0: return "New words are waiting. Hit your daily goal."
        case 1: return "Your daily words are still waiting."
        default: return "Last nudge: learn a few words today."
        }
    }
}

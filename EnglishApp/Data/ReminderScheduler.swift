import Foundation
import SwiftData
import UserNotifications

@MainActor
enum ReminderScheduler {
    private static let center = UNUserNotificationCenter.current()

    static func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    static func clear() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // Rebuilds the whole schedule from current progress; call when the app leaves the foreground.
    static func refresh(in context: ModelContext, now: Date = .now) {
        clear()
        guard let words = try? context.fetch(FetchDescriptor<Word>()),
              let packs = try? context.fetch(FetchDescriptor<Pack>()),
              let events = try? context.fetch(FetchDescriptor<StudyEvent>())
        else { return }

        let goal = UserDefaults.standard.object(forKey: Preferences.dailyGoal) as? Int ?? Preferences.defaultDailyGoal
        let reminders = ReminderPlan.make(
            now: now,
            dueDates: words.filter { $0.status == .learning }.compactMap(\.dueDate),
            canLearn: packs.contains { $0.isSelected && $0.newCount > 0 },
            goalReached: ActivityStats.newWordsToday(events, now: now) >= goal
        )
        reminders.forEach(schedule)
    }

    private static func schedule(_ reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
    }
}

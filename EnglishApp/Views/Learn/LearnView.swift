import SwiftData
import SwiftUI

struct LearnView: View {
    @Query(sort: \Pack.name) private var packs: [Pack]
    @Query private var words: [Word]
    @Query private var events: [StudyEvent]
    @AppStorage(Preferences.userName) private var userName = ""
    @AppStorage(Preferences.dailyGoal) private var dailyGoal = Preferences.defaultDailyGoal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    DailyGoalCard(learnedToday: ActivityStats.newWordsToday(events), goal: $dailyGoal)
                    actions
                    ActivityHeatmap(totals: totals)
                    WeeklyChart(days: ActivityStats.lastWeek(events))
                }
                .padding()
            }
            .themedScreen()
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: StudyMode.self) { StudyView(mode: $0) }
        }
    }

    private var totals: [Date: Int] {
        ActivityStats.totalsByDay(events)
    }

    private var header: some View {
        HStack {
            Text(userName.isEmpty ? "Hello!" : "Hello, \(userName)!")
                .font(.largeTitle.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer()
            Label("\(ActivityStats.streak(totals: totals))", systemImage: "flame.fill")
                .font(.title3.bold())
                .foregroundStyle(.orange)
                .fixedSize()
        }
    }

    private var selectedPacks: [Pack] {
        packs.filter(\.isSelected)
    }

    private var learnSubtitle: String {
        guard !selectedPacks.isEmpty else { return "Select vocabularies in the Vocabulary tab" }
        let newCount = selectedPacks.map(\.newCount).reduce(0, +)
        return "\(selectedPacks.count) selected · \(newCount) new"
    }

    private var actions: some View {
        VStack(spacing: 12) {
            ActionLink(
                mode: .learnNew,
                title: "Learn new words",
                subtitle: learnSubtitle,
                systemImage: "sparkles"
            )
            ActionLink(
                mode: .review,
                title: "Repeat words",
                subtitle: "\(StudyQueue.dueWords(in: words).count) due",
                systemImage: "arrow.triangle.2.circlepath"
            )
        }
    }
}

private struct ActionLink: View {
    let mode: StudyMode
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        NavigationLink(value: mode) {
            HStack(spacing: 14) {
                Image(systemName: systemImage).font(.title2)
                VStack(alignment: .leading) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).opacity(0.8)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .foregroundStyle(.white)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.accent))
        }
    }
}

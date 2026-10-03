import SwiftUI

struct DailyGoalCard: View {
    let learnedToday: Int
    @Binding var goal: Int

    private var reached: Bool { learnedToday >= goal }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily goal").font(.headline)
                Spacer()
                Picker("Daily goal", selection: $goal) {
                    ForEach(Preferences.dailyGoalOptions, id: \.self) { Text("\($0) words").tag($0) }
                }
                .pickerStyle(.menu)
            }
            ProgressView(value: Double(min(learnedToday, goal)), total: Double(goal))
                .tint(reached ? Theme.highlight : Theme.accent)
            Text(reached ? "Goal reached. You're a great learner!" : "\(learnedToday) / \(goal) new words today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
    }
}

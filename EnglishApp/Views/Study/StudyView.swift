import SwiftData
import SwiftUI

struct StudyView: View {
    let mode: StudyMode
    @Environment(\.modelContext) private var context
    @Query private var words: [Word]
    @Query private var events: [StudyEvent]
    @AppStorage(Preferences.dailyGoal) private var dailyGoal = Preferences.defaultDailyGoal
    @State private var current: Word?
    @State private var loaded = false

    var body: some View {
        VStack(spacing: 16) {
            if goalReached {
                StatusMessage(
                    systemImage: "trophy.fill", tint: Theme.highlight,
                    title: "Daily goal reached",
                    detail: "You're a great learner! See you tomorrow."
                )
            } else if let current {
                SwipeCard(word: current, onSwipe: handleSwipe)
                    .id(ObjectIdentifier(current))
                Text("← don't know      know →")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if loaded {
                StatusMessage(
                    systemImage: "checkmark.circle", tint: Theme.accent,
                    title: "All caught up", detail: caughtUpDetail,
                    retry: advance
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(mode == .learnNew ? "Learn" : "Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: advance)
    }

    private var goalReached: Bool {
        mode == .learnNew && ActivityStats.newWordsToday(events) >= dailyGoal
    }

    private var caughtUpDetail: String? {
        switch mode {
        case .learnNew:
            return "No new words left in the selected vocabularies"
        case .review:
            guard let next = StudyQueue.nextReviewDate(in: words) else { return nil }
            return "Next review \(next.formatted(.relative(presentation: .named)))"
        }
    }

    private func handleSwipe(_ direction: SwipeDirection) {
        guard let current else { return }
        context.insert(StudyEvent(kind: current.swipe(direction)))
        advance()
    }

    private func advance() {
        current = StudyQueue.next(mode, in: words)
        loaded = true
    }
}

private struct StatusMessage: View {
    let systemImage: String
    let tint: Color
    let title: String
    var detail: String?
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage).font(.system(size: 56)).foregroundStyle(tint)
            Text(title).font(.title2.bold())
            if let detail {
                Text(detail).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            if let retry {
                Button("Check again", action: retry).buttonStyle(.bordered)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

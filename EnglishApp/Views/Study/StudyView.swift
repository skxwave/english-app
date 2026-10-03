import SwiftData
import SwiftUI

struct StudyView: View {
    let mode: StudyMode
    @Environment(\.modelContext) private var context
    @Query private var words: [Word]
    @Query private var events: [StudyEvent]
    @AppStorage(Preferences.dailyGoal) private var dailyGoal = Preferences.defaultDailyGoal
    @State private var session: StudySession?
    // Distinct per card so a missed word shown again right away still gets a fresh card view.
    @State private var cardNumber = 0

    var body: some View {
        VStack(spacing: 16) {
            if let current = session?.current {
                SwipeCard(word: current, onSwipe: handleSwipe)
                    .id(cardNumber)
                Text("← don't know      know →")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if session != nil {
                finished
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(mode == .learnNew ? "Learn" : "Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: startSession)
    }

    private var goalReached: Bool {
        mode == .learnNew && ActivityStats.newWordsToday(events) >= dailyGoal
    }

    @ViewBuilder
    private var finished: some View {
        if goalReached {
            StatusMessage(
                systemImage: "trophy.fill", tint: Theme.highlight,
                title: "Daily goal reached",
                detail: "You're a great learner! See you tomorrow."
            )
        } else {
            StatusMessage(
                systemImage: "checkmark.circle", tint: Theme.accent,
                title: "All caught up", detail: caughtUpDetail,
                retry: retryAction
            )
        }
    }

    private var retryAction: (() -> Void)? {
        mode == .review ? { startSession() } : nil
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
        guard let kind = session?.swipe(direction) else { return }
        context.insert(StudyEvent(kind: kind))
        cardNumber += 1
    }

    private func startSession() {
        session = StudySession(
            mode: mode,
            words: words,
            remainingGoal: max(0, dailyGoal - ActivityStats.newWordsToday(events))
        )
        cardNumber += 1
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

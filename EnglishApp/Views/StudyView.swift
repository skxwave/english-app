import SwiftUI

struct StudyView: View {
    let pack: Pack
    @State private var current: Word?
    @State private var loaded = false

    var body: some View {
        VStack(spacing: 16) {
            if let current {
                SwipeCard(word: current, onSwipe: handleSwipe)
                    .id(ObjectIdentifier(current))
                Text("← don't know      know →")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if loaded {
                caughtUp
            }
        }
        .padding()
        .navigationTitle(pack.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: advance)
    }

    private var caughtUp: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle").font(.system(size: 56)).foregroundStyle(.green)
            Text("All caught up").font(.title2.bold())
            if let next = pack.nextReviewDate {
                Text("Next review \(next.formatted(.relative(presentation: .named)))")
                    .foregroundStyle(.secondary)
            }
            Button("Check again", action: advance).buttonStyle(.bordered)
        }
        .frame(maxHeight: .infinity)
    }

    private func handleSwipe(_ direction: SwipeDirection) {
        current?.swipe(direction)
        advance()
    }

    private func advance() {
        current = pack.nextWord()
        loaded = true
    }
}

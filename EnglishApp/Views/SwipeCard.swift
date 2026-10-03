import SwiftUI

struct SwipeCard: View {
    let word: Word
    let onSwipe: (SwipeDirection) -> Void

    @State private var revealed = false
    @State private var offset: CGSize = .zero
    private let threshold: CGFloat = 110

    var body: some View {
        WordFace(word: word, revealed: revealed)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(.secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 24).fill(swipeTint))
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .contentShape(Rectangle())
            .onTapGesture { revealed = true }
            .gesture(
                DragGesture()
                    .onChanged { offset = $0.translation }
                    .onEnded(finishDrag)
            )
    }

    private var swipeTint: Color {
        let strength = min(abs(offset.width) / threshold, 1) * 0.35
        return (offset.width > 0 ? Color.green : Color.red).opacity(strength)
    }

    private func finishDrag(_ value: DragGesture.Value) {
        guard abs(value.translation.width) > threshold else {
            withAnimation(.spring) { offset = .zero }
            return
        }
        let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
        withAnimation(.easeOut(duration: 0.2)) {
            offset.width = direction == .right ? 600 : -600
        } completion: {
            onSwipe(direction)
        }
    }
}

private struct WordFace: View {
    let word: Word
    let revealed: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(word.term).font(.largeTitle.bold())
            if revealed {
                Text(word.meaning).font(.title3).multilineTextAlignment(.center)
            } else {
                Text("Tap to reveal").foregroundStyle(.secondary)
            }
            if word.status == .learning {
                Text("Review · step \(word.step + 1)/\(SRS.intervals.count)")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

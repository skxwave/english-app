import SwiftUI

struct SwipeCard: View {
    let word: Word
    let onSwipe: (SwipeDirection) -> Void

    @State private var revealed = false
    @State private var offset: CGSize = .zero
    private let threshold: CGFloat = 110

    var body: some View {
        FlipCard(angle: revealed ? 180 : 0, front: WordFront(word: word), back: WordBack(word: word))
            .animation(.easeInOut(duration: 0.45), value: revealed)
            .overlay(RoundedRectangle(cornerRadius: 24).fill(swipeTint))
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .contentShape(Rectangle())
            .onTapGesture { revealed.toggle() }
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

// Animatable so the face swaps exactly at the 90° edge-on midpoint of the rotation.
private struct FlipCard<Front: View, Back: View>: View, @preconcurrency Animatable {
    var angle: Double
    let front: Front
    let back: Back

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    var body: some View {
        ZStack {
            if angle < 90 {
                front
            } else {
                back.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
    }
}

private struct CardFace<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
    }
}

private struct WordFront: View {
    let word: Word

    var body: some View {
        CardFace {
            VStack(spacing: 12) {
                Text(word.term).font(.largeTitle.bold())
                Text(word.partOfSpeech).foregroundStyle(.secondary)
                Text("Tap to flip").font(.footnote).foregroundStyle(.secondary)
                if word.status == .learning {
                    Text("Review · step \(word.step + 1)/\(SRS.intervals.count)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

private struct WordBack: View {
    let word: Word

    var body: some View {
        CardFace {
            WordInfo(word: word, exampleLimit: 2)
        }
    }
}

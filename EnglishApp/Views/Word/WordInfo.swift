import SwiftUI

struct WordInfo: View {
    let word: Word
    var exampleLimit: Int?

    var body: some View {
        VStack(spacing: 14) {
            if let url = URL(string: word.imageURL), !word.imageURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFit()
                    case .empty: ProgressView()
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Text(word.translation)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(word.partOfSpeech).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                PronunciationButton(region: "UK", ipa: word.ipaUK, audio: word.audioUK)
                PronunciationButton(region: "US", ipa: word.ipaUS, audio: word.audioUS)
            }
            examples
        }
    }

    private var examples: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(word.examples.prefix(exampleLimit ?? .max)), id: \.self) { example in
                VStack(alignment: .leading, spacing: 2) {
                    Text(highlighted(example.en)).font(.callout)
                    Text(highlighted(example.uk)).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Examples carry **word** markers for the target word (converted from the deck's <u>/<b> tags).
    private func highlighted(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

private struct PronunciationButton: View {
    let region: String
    let ipa: String
    let audio: String

    var body: some View {
        Button { Pronunciation.shared.play(audio) } label: {
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.2.fill")
                Text("\(region) \(ipa)")
            }
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.background))
        }
        .buttonStyle(.plain)
    }
}

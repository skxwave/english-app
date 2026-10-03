import SwiftUI

struct PackWordsView: View {
    let pack: Pack
    @State private var query = ""
    @State private var sort = WordSort.alphabet

    var body: some View {
        List(visibleWords) { word in
            NavigationLink {
                WordDetailView(word: word)
            } label: {
                WordRow(word: word)
            }
            .listRowBackground(Theme.card)
        }
        .themedScreen()
        .searchable(text: $query)
        .navigationTitle(pack.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Sort", selection: $sort) {
                    ForEach(WordSort.allCases, id: \.self) { Text($0.label) }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private var visibleWords: [Word] {
        let matching = query.isEmpty ? pack.words : pack.words.filter {
            $0.term.localizedCaseInsensitiveContains(query) || $0.translation.localizedCaseInsensitiveContains(query)
        }
        return matching.sorted(by: sort.areInIncreasingOrder)
    }
}

private enum WordSort: CaseIterable {
    case alphabet, status

    var label: String {
        switch self {
        case .alphabet: "A–Z"
        case .status: "Status"
        }
    }

    func areInIncreasingOrder(_ lhs: Word, _ rhs: Word) -> Bool {
        switch self {
        case .alphabet:
            return lhs.term.localizedCaseInsensitiveCompare(rhs.term) == .orderedAscending
        case .status:
            guard lhs.status != rhs.status else {
                return lhs.term.localizedCaseInsensitiveCompare(rhs.term) == .orderedAscending
            }
            return lhs.status.sortOrder < rhs.status.sortOrder
        }
    }
}

private struct WordRow: View {
    let word: Word

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(word.term).font(.headline)
                    Text(word.partOfSpeech).font(.caption).foregroundStyle(.secondary)
                }
                Text(word.translation).font(.subheadline)
            }
            Spacer()
            Text(word.status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(word.status.color)
        }
        .opacity(word.isMastered ? 0.4 : 1)
    }
}

private extension WordStatus {
    var sortOrder: Int {
        switch self {
        case .new: 0
        case .learning: 1
        case .known: 2
        case .learned: 3
        }
    }

    var color: Color {
        switch self {
        case .new: .secondary
        case .learning: .orange
        case .known, .learned: Theme.accent
        }
    }
}

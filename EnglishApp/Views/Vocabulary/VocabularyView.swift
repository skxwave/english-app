import SwiftData
import SwiftUI

struct VocabularyView: View {
    @Query(sort: \Pack.name) private var packs: [Pack]
    @State private var path: [Pack] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(packs) { pack in
                HStack {
                    Button { pack.isSelected.toggle() } label: {
                        PackRow(pack: pack)
                    }
                    Button { path.append(pack) } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 44)
                    }
                }
                .buttonStyle(.borderless)
                .tint(.primary)
                .listRowBackground(Theme.card)
            }
            .themedScreen()
            .navigationTitle("Vocabulary")
            .navigationDestination(for: Pack.self) { PackWordsView(pack: $0) }
        }
    }
}

private struct PackRow: View {
    let pack: Pack

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: pack.isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(pack.isSelected ? Theme.accent : .secondary)
            Image(systemName: pack.icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.background))
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pack.name).font(.headline)
                    Text(pack.level)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.background))
                }
                ProgressView(value: Double(pack.masteredCount), total: Double(max(pack.words.count, 1)))
                Text("\(pack.masteredCount) / \(pack.words.count) learned")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

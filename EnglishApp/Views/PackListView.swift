import SwiftData
import SwiftUI

struct PackListView: View {
    @Query(sort: \Pack.name) private var packs: [Pack]

    var body: some View {
        NavigationStack {
            List(packs) { pack in
                NavigationLink(value: pack) { PackRow(pack: pack) }
            }
            .navigationTitle("Packs")
            .navigationDestination(for: Pack.self) { StudyView(pack: $0) }
        }
    }
}

private struct PackRow: View {
    let pack: Pack

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(pack.name).font(.headline)
            Text(pack.summary).font(.subheadline).foregroundStyle(.secondary)
            ProgressView(value: Double(pack.masteredCount), total: Double(max(pack.words.count, 1)))
            Text("\(pack.masteredCount) / \(pack.words.count) learned")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

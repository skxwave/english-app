import SwiftUI

struct WordDetailView: View {
    let word: Word

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(word.term).font(.largeTitle.bold())
                WordInfo(word: word)
            }
            .padding()
        }
        .themedScreen()
        .navigationBarTitleDisplayMode(.inline)
    }
}

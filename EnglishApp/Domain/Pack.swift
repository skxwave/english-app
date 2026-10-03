import Foundation
import SwiftData

@Model
final class Pack {
    var name: String
    var level: String = ""
    var icon: String = "books.vertical.fill"
    var isSelected: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Word.pack) var words: [Word] = []

    init(name: String, level: String, icon: String, isSelected: Bool = false) {
        self.name = name
        self.level = level
        self.icon = icon
        self.isSelected = isSelected
    }

    var masteredCount: Int {
        words.filter(\.isMastered).count
    }

    var newCount: Int {
        words.filter { $0.status == .new }.count
    }
}

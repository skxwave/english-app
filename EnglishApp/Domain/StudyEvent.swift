import Foundation
import SwiftData

enum StudyEventKind: String, Codable, CaseIterable {
    case learned, known, repeated
}

@Model
final class StudyEvent {
    var date: Date
    var kind: StudyEventKind

    init(kind: StudyEventKind, date: Date = .now) {
        self.kind = kind
        self.date = date
    }
}

import Charts
import SwiftUI

struct WeeklyChart: View {
    let days: [DailyKindCount]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This week").font(.headline)
            Chart(days) {
                BarMark(
                    x: .value("Day", $0.day, unit: .day),
                    y: .value("Words", $0.count)
                )
                .foregroundStyle(by: .value("Kind", $0.kind.label))
            }
            .chartForegroundStyleScale([
                StudyEventKind.learned.label: Theme.accent,
                StudyEventKind.known.label: Theme.highlight,
                StudyEventKind.repeated.label: Color.primary.opacity(0.45),
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 180)
        }
    }
}

private extension StudyEventKind {
    var label: String { rawValue.capitalized }
}

import SwiftUI

private let cellSize: CGFloat = 16
private let cellSpacing: CGFloat = 3

struct ActivityHeatmap: View {
    let totals: [Date: Int]

    private let monthCount = 6
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity").font(.headline)
            HStack(alignment: .top, spacing: 6) {
                weekdayLabels
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(months, id: \.self) { MonthBlock(monthStart: $0, totals: totals) }
                    }
                }
                .defaultScrollAnchor(.trailing)
            }
        }
    }

    private var months: [Date] {
        let thisMonth = calendar.dateInterval(of: .month, for: .now)!.start
        return (0..<monthCount).reversed().map { calendar.date(byAdding: .month, value: -$0, to: thisMonth)! }
    }

    private var weekdayLabels: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        let ordered = (0..<7).map { symbols[(calendar.firstWeekday - 1 + $0) % 7] }
        return VStack(spacing: cellSpacing) {
            ForEach(Array(ordered.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .frame(width: 12, height: cellSize)
            }
        }
    }
}

private struct MonthBlock: View {
    let monthStart: Date
    let totals: [Date: Int]

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: cellSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { row in cell(offset: week * 7 + row - leadingBlanks) }
                    }
                }
            }
            Text(monthStart.formatted(.dateTime.month(.abbreviated)))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var dayCount: Int {
        calendar.range(of: .day, in: .month, for: monthStart)!.count
    }

    private var leadingBlanks: Int {
        (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
    }

    private var weekCount: Int {
        (leadingBlanks + dayCount + 6) / 7
    }

    @ViewBuilder
    private func cell(offset: Int) -> some View {
        let date = calendar.date(byAdding: .day, value: offset, to: monthStart)!
        if offset < 0 || offset >= dayCount || date > .now {
            Color.clear.frame(width: cellSize, height: cellSize)
        } else {
            RoundedRectangle(cornerRadius: 3)
                .fill(color(for: totals[date] ?? 0))
                .frame(width: cellSize, height: cellSize)
        }
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: Theme.card.opacity(0.6)
        case 1...4: Theme.accent.opacity(0.45)
        case 5...9: Theme.accent.opacity(0.65)
        case 10...19: Theme.accent.opacity(0.85)
        default: Theme.accent
        }
    }
}

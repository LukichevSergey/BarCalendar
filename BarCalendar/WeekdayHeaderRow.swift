import SwiftUI

struct WeekdayHeaderRow: View {
    let startOfWeek: Int

    private struct WeekdayItem: Identifiable {
        let id: Int
        let name: String
    }

    private var weekdays: [WeekdayItem] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let ordered: [String]
        if startOfWeek == 2 {
            ordered = Array(symbols[1...]) + [symbols[0]]
        } else {
            ordered = Array(symbols)
        }
        return ordered.enumerated().map { WeekdayItem(id: $0.offset, name: $0.element) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays) { weekday in
                Text(weekday.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

import SwiftUI

struct WeekdayHeaderRow: View {
    let startOfWeek: Int

    private var weekdays: [String] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        if startOfWeek == 2 {
            return Array(symbols[1...]) + [symbols[0]]
        }
        return symbols
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { _, day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

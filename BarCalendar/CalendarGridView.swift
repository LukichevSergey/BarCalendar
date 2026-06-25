import SwiftUI

struct CalendarGridView: View {
    @Bindable var state: CalendarState

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var daysInMonth: [Date] {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: state.displayedMonth)
        guard let startOfMonth = cal.date(from: components),
              let range = cal.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        return range.compactMap { day in
            cal.date(bySetting: .day, value: day, of: startOfMonth)
        }
    }

    private var leadingEmptyDays: Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: state.displayedMonth)
        guard let startOfMonth = cal.date(from: components) else { return 0 }
        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        return (firstWeekday - state.startOfWeek + 7) % 7
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                Color.clear
                    .frame(height: 28)
            }

            ForEach(daysInMonth, id: \.self) { date in
                DayCell(
                    date: date,
                    isToday: Calendar.current.isDateInToday(date),
                    hasEvents: !state.eventsForDay(date).isEmpty
                )
            }
        }
    }
}

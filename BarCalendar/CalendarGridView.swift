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

    private var trailingEmptyDays: Int {
        let total = leadingEmptyDays + daysInMonth.count
        let rows = Int(ceil(Double(total) / 7.0))
        return (rows * 7) - total
    }

    private var leadingDates: [Date] {
        let cal = Calendar.current
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: state.displayedMonth)),
              leadingEmptyDays > 0 else { return [] }
        return (1...leadingEmptyDays).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: startOfMonth)
        }
    }

    private var trailingDates: [Date] {
        let cal = Calendar.current
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: state.displayedMonth)),
              let range = cal.range(of: .day, in: .month, for: startOfMonth),
              let lastDay = cal.date(bySetting: .day, value: range.upperBound - 1, of: startOfMonth),
              trailingEmptyDays > 0 else { return [] }
        return (1...trailingEmptyDays).compactMap { offset in
            cal.date(byAdding: .day, value: offset, to: lastDay)
        }
    }

    private var allDates: [(date: Date, isCurrentMonth: Bool)] {
        leadingDates.map { (date: $0, isCurrentMonth: false) }
        + daysInMonth.map { (date: $0, isCurrentMonth: true) }
        + trailingDates.map { (date: $0, isCurrentMonth: false) }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: Layout.gridSpacing) {
            ForEach(allDates, id: \.date) { item in
                DayCell(
                    date: item.date,
                    isToday: Calendar.current.isDateInToday(item.date),
                    events: state.eventsForDay(item.date),
                    isCurrentMonth: item.isCurrentMonth
                )
            }
        }
    }
}

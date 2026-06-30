import SwiftUI

struct CalendarDropdownView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: Layout.padding) {
            MonthHeaderView(state: state)

            WeekdayHeaderRow(startOfWeek: state.startOfWeek)
            CalendarGridView(state: state)

            CountdownView(text: state.countdownText)

            Divider()

            EventsSectionView(state: state)
        }
        .padding(Layout.padding)
        .frame(width: Layout.popoverWidth)
    }
}

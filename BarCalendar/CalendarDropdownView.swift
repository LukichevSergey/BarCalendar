import SwiftUI

struct CalendarDropdownView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: 8) {
            MonthHeaderView(state: state)
            WeekdayHeaderRow(startOfWeek: state.startOfWeek)
            CalendarGridView(state: state)

            Divider()

            EventsSectionView(state: state)

            Divider()

            SettingsView(state: state)
        }
        .padding(12)
        .frame(width: 280)
    }
}

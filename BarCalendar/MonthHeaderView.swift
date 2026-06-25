import SwiftUI

struct MonthHeaderView: View {
    @Bindable var state: CalendarState

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: state.displayedMonth)
    }

    var body: some View {
        HStack {
            Button {
                state.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.headline)
                .contentTransition(.numericText())

            Spacer()

            Button {
                state.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
        }
    }
}

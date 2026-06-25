import SwiftUI

struct MonthHeaderView: View {
    @Bindable var state: CalendarState

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private var monthTitle: String {
        Self.monthFormatter.string(from: state.displayedMonth)
    }

    var body: some View {
        HStack {
            Button {
                state.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            .help("Previous month")

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
            .help("Next month")
        }
    }
}

import SwiftUI

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let hasEvents: Bool

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(isToday ? .white : .primary)
                .frame(width: Layout.dayCellSize, height: Layout.dayCellSize)
                .background(
                    isToday ? Circle().fill(.blue) : nil
                )
                .animation(.easeInOut, value: isToday)

            if hasEvents {
                Circle()
                    .fill(.orange)
                    .frame(width: Layout.eventDotSize, height: Layout.eventDotSize)
            } else {
                Color.clear.frame(width: Layout.eventDotSize, height: Layout.eventDotSize)
            }
        }
        .contentShape(Rectangle())
    }
}

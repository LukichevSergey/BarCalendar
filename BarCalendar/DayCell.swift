import SwiftUI
import EventKit

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let events: [EKEvent]
    let isCurrentMonth: Bool

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    private var calendarColors: [Color] {
        var seen = Set<String>()
        var colors: [Color] = []
        for event in events {
            let id = event.calendar.calendarIdentifier
            if !seen.contains(id) {
                seen.insert(id)
                colors.append(Color(event.calendar.color))
            }
        }
        return colors
    }

    private var visibleDots: [Color] {
        Array(calendarColors.prefix(3))
    }

    private var extraCount: Int {
        max(0, calendarColors.count - 3)
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(isToday ? .white : (isCurrentMonth ? .primary : .secondary.opacity(0.5)))
                .frame(width: Layout.dayCellSize, height: Layout.dayCellSize)
                .background(
                    Group {
                        if isToday {
                            Circle().fill(.blue)
                        } else if isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor, lineWidth: 1.5)
                        }
                    }
                )
                .animation(.easeInOut, value: isToday)
                .animation(.easeInOut, value: isSelected)

            HStack(spacing: 2) {
                ForEach(visibleDots.indices, id: \.self) { i in
                    Circle()
                        .fill(visibleDots[i])
                        .frame(width: Layout.eventDotSize, height: Layout.eventDotSize)
                }
                if extraCount > 0 {
                    Text("+\(extraCount)")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: Layout.eventDotSize)
        }
        .contentShape(Rectangle())
    }
}

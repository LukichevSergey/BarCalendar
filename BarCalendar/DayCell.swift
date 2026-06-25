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
                .frame(width: 28, height: 28)
                .background(
                    isToday ? Circle().fill(.blue) : nil
                )

            if hasEvents {
                Circle()
                    .fill(.orange)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear.frame(width: 4, height: 4)
            }
        }
        .contentShape(Rectangle())
    }
}

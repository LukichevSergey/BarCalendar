import SwiftUI
import EventKit

struct DayEventsPopover: View {
    let date: Date
    let events: [EKEvent]

    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter
    }()

    fileprivate static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text(Self.dateFormatter.string(from: date))
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            if events.isEmpty {
                Text("No events")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(events, id: \.eventIdentifier) { event in
                    DayEventRow(event: event)
                }
            }
        }
        .padding(Layout.padding)
        .frame(minWidth: Layout.popoverWidth)
    }
}

private struct DayEventRow: View {
    let event: EKEvent
    @State private var now = Date()

    private var isPast: Bool {
        event.endDate < now
    }

    private var timeString: String {
        let start = DayEventsPopover.timeFormatter.string(from: event.startDate)
        let end = DayEventsPopover.timeFormatter.string(from: event.endDate)
        if start == "00:00" && end == "00:00" {
            return "All day"
        }
        return "\(start)–\(end)"
    }

    var body: some View {
        HStack(spacing: Layout.eventRowSpacing) {
            Circle()
                .fill(Color(event.calendar.color))
                .frame(width: Layout.eventColorDotSize, height: Layout.eventColorDotSize)
            Text(event.title ?? "Untitled")
                .font(.caption)
                .lineLimit(1)
                .strikethrough(isPast)
                .foregroundStyle(isPast ? .secondary : .primary)
            Spacer()
            Text(timeString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .task { now = Date() }
    }
}

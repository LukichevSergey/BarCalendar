import SwiftUI
import EventKit

struct EventGroupView: View {
    let title: String
    let events: [EKEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ForEach(events, id: \.eventIdentifier) { event in
                EventRowView(event: event)
            }
        }
    }
}

struct EventRowView: View {
    let event: EKEvent
    @State private var now = Date()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var timeString: String {
        let start = Self.timeFormatter.string(from: event.startDate)
        let end = Self.timeFormatter.string(from: event.endDate)
        if start == "00:00" && end == "00:00" {
            return "All day"
        }
        return "\(start)–\(end)"
    }

    private var isPast: Bool {
        event.endDate < now
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

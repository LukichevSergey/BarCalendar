import SwiftUI
import EventKit

struct DayEventsPopover: View {
    let date: Date
    let events: [EKEvent]
    let showLocation: Bool
    @State private var now = Date()

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
                    DayEventRow(event: event, showLocation: showLocation, now: now)
                }
            }
        }
        .padding(Layout.padding)
        .frame(minWidth: Layout.popoverWidth)
        .onAppear { now = Date() }
    }
}

private struct DayEventRow: View {
    let event: EKEvent
    let showLocation: Bool
    let now: Date

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

    private var locationURL: URL? {
        guard let loc = event.location?.trimmingCharacters(in: .whitespacesAndNewlines),
              !loc.isEmpty,
              (loc.hasPrefix("http://") || loc.hasPrefix("https://")),
              let url = URL(string: loc) else { return nil }
        return url
    }

    private var hasLocation: Bool {
        guard let loc = event.location?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !loc.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
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
            if showLocation && hasLocation {
                if let url = locationURL {
                    Link(url.absoluteString, destination: url)
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .foregroundStyle(.blue)
                        .padding(.leading, Layout.eventColorDotSize + Layout.eventRowSpacing)
                } else {
                    Text(event.location!.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .padding(.leading, Layout.eventColorDotSize + Layout.eventRowSpacing)
                }
            }
        }
    }
}

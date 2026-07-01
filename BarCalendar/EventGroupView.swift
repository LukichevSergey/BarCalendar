import SwiftUI
import EventKit

struct EventGroupView: View {
    let title: String
    let events: [EKEvent]
    let showLocation: Bool
    @State private var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ForEach(events, id: \.eventIdentifier) { event in
                EventRowView(event: event, showLocation: showLocation, now: now)
            }
        }
        .onAppear { now = Date() }
    }
}

struct EventRowView: View {
    let event: EKEvent
    let showLocation: Bool
    let now: Date

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

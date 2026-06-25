import SwiftUI
import EventKit
import AppKit

struct EventsSectionView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !state.hasCalendarAccess {
                PermissionPromptView(state: state)
            } else if state.eventsDaysToShow == 0 {
                Text("Events hidden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                let dayGroups = upcomingDayGroups
                ForEach(dayGroups, id: \.label) { group in
                    if group.events.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.label)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text("—")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        EventGroupView(title: group.label, events: group.events)
                    }
                }
            }
        }
    }

    private var upcomingDayGroups: [(label: String, events: [EKEvent])] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var groups: [(label: String, events: [EKEvent])] = []

        for offset in 0..<state.eventsDaysToShow {
            guard let date = cal.date(byAdding: .day, value: offset, to: today) else { continue }
            let dayEvents = state.eventsForDay(date)
            let label: String
            if offset == 0 {
                label = "Today"
            } else if offset == 1 {
                label = "Tomorrow"
            } else {
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateFormat = "EEEE"
                label = formatter.string(from: date)
            }
            groups.append((label: label, events: dayEvents))
        }
        return groups
    }
}

struct EventGroupView: View {
    let title: String
    let events: [EKEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        return "\(start)–\(end)"
    }

    private var isPast: Bool {
        event.endDate < Date()
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(event.calendar.color))
                .frame(width: 6, height: 6)
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
    }
}

struct PermissionPromptView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Calendar access required")
                .font(.caption)
            Text("Allow BarCalendar to read your calendar events.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Grant Access") {
                state.requestCalendarAccess()
            }
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
            HStack(spacing: 8) {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .controlSize(.small)
                Button("Check again") {
                    NotificationCenter.default.post(name: .checkCalendarAccess, object: nil)
                }
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

import SwiftUI
import EventKit
import AppKit

struct EventsSectionView: View {
    @Bindable var state: CalendarState

    private var todayEvents: [EKEvent] {
        state.eventsForDay(Date())
    }

    private var tomorrowEvents: [EKEvent] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return state.eventsForDay(tomorrow)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !state.hasCalendarAccess {
                PermissionPromptView(state: state)
            } else if todayEvents.isEmpty && tomorrowEvents.isEmpty {
                Text("No upcoming events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                if !todayEvents.isEmpty {
                    EventGroupView(title: "Today", events: todayEvents)
                }
                if !tomorrowEvents.isEmpty {
                    EventGroupView(title: "Tomorrow", events: tomorrowEvents)
                }
            }
        }
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
        return formatter.string(from: event.startDate)
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(event.calendar.color))
                .frame(width: 6, height: 6)
            Text(event.title ?? "Untitled")
                .font(.caption)
                .lineLimit(1)
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

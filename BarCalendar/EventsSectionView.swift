import SwiftUI
import EventKit

struct EventsSectionView: View {
    @Bindable var state: CalendarState

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
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
                        VStack(alignment: .leading, spacing: Layout.groupSpacing) {
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
            let dayNumber = cal.component(.day, from: date)
            let month = Self.monthFormatter.string(from: date)
            let label: String
            if offset == 0 {
                label = "Today, \(dayNumber) \(month)"
            } else if offset == 1 {
                label = "Tomorrow, \(dayNumber) \(month)"
            } else {
                label = "\(Self.weekdayFormatter.string(from: date)), \(dayNumber) \(month)"
            }
            groups.append((label: label, events: dayEvents))
        }
        return groups
    }
}

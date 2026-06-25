import SwiftUI
import EventKit

extension Notification.Name {
    static let checkCalendarAccess = Notification.Name("checkCalendarAccess")
}

@Observable
final class CalendarState {
    var displayedMonth: Date
    var events: [EKEvent] = []
    var hasCalendarAccess = false
    var startOfWeek: Int
    var eventsDaysToShow: Int

    private let eventStore = EKEventStore()

    init() {
        let savedStart = UserDefaults.standard.integer(forKey: "startOfWeek")
        self.startOfWeek = savedStart == 1 ? 1 : 2
        let savedDays = UserDefaults.standard.integer(forKey: "eventsDaysToShow")
        self.eventsDaysToShow = savedDays >= 0 && savedDays <= 7 ? savedDays : 2
        self.displayedMonth = Date()
        requestCalendarAccess()

        NotificationCenter.default.addObserver(
            forName: .checkCalendarAccess,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.requestCalendarAccess()
        }
    }

    var menuBarDateText: String {
        let day = Calendar.current.component(.day, from: Date())
        return "\(day)"
    }

    func requestCalendarAccess() {
        Task { @MainActor in
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                hasCalendarAccess = granted
                if granted {
                    fetchEvents()
                }
            } catch {
                print("Calendar access error: \(error)")
                hasCalendarAccess = false
            }
        }
    }

    func fetchEvents() {
        guard hasCalendarAccess else { return }
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let monthStart = cal.date(from: components),
              let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) else { return }

        let today = cal.startOfDay(for: Date())
        let upcomingEnd = cal.date(byAdding: .day, value: max(eventsDaysToShow, 1), to: today)!

        let rangeStart = min(monthStart, today)
        let rangeEnd = max(monthEnd, upcomingEnd)

        let predicate = eventStore.predicateForEvents(withStart: rangeStart, end: rangeEnd, calendars: nil)
        events = eventStore.events(matching: predicate)
    }

    func previousMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth)!
        fetchEvents()
    }

    func nextMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth)!
        fetchEvents()
    }

    func eventsForDay(_ date: Date) -> [EKEvent] {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
        return events.filter { event in
            event.startDate < dayEnd && event.endDate > dayStart
        }
    }

    func saveStartOfWeek(_ value: Int) {
        startOfWeek = value
        UserDefaults.standard.set(value, forKey: "startOfWeek")
    }

    func saveEventsDaysToShow(_ value: Int) {
        eventsDaysToShow = value
        UserDefaults.standard.set(value, forKey: "eventsDaysToShow")
        fetchEvents()
    }
}

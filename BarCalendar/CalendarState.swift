import SwiftUI
import EventKit

extension Notification.Name {
    static let checkCalendarAccess = Notification.Name("checkCalendarAccess")
}

// MARK: - CalendarState

/// Manages calendar data, access permissions, and month navigation for the menu bar calendar.
@Observable @MainActor
final class CalendarState {

    // MARK: - Properties

    /// The month currently displayed in the calendar grid.
    var displayedMonth: Date
    /// Cached events covering the displayed month and upcoming window.
    var events: [EKEvent] = []
    /// Whether the app has been granted calendar read access.
    var hasCalendarAccess = false
    /// Weekday that starts the calendar grid (1 = Sunday, 2 = Monday).
    var startOfWeek: Int
    /// Number of upcoming days to show events for (0–7); 0 hides the events section.
    var eventsDaysToShow: Int

    private let eventStore = EKEventStore()
    private var observerTask: Task<Void, Never>?

    /// Current day number as a string, for display in the menu bar.
    var menuBarDateText: String {
        let day = Calendar.current.component(.day, from: Date())
        return "\(day)"
    }

    // MARK: - Access

    /// Requests full calendar access from the system. On grant, automatically fetches events.
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

    // MARK: - Fetching

    /// Re-fetches events for the displayed month union the upcoming events window.
    func fetchEvents() {
        guard hasCalendarAccess else { return }
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let monthStart = cal.date(from: components),
              let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) else { return }

        let today = cal.startOfDay(for: Date())
        guard let upcomingEnd = cal.date(byAdding: .day, value: max(eventsDaysToShow, 1), to: today) else { return }

        let rangeStart = min(monthStart, today)
        let rangeEnd = max(monthEnd, upcomingEnd)

        let predicate = eventStore.predicateForEvents(withStart: rangeStart, end: rangeEnd, calendars: nil)
        events = eventStore.events(matching: predicate)
    }

    /// Returns cached events that overlap the given day.
    func eventsForDay(_ date: Date) -> [EKEvent] {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return events.filter { event in
            event.startDate < dayEnd && event.endDate > dayStart
        }
    }

    // MARK: - Navigation

    /// Moves the displayed month one month earlier and re-fetches events.
    func previousMonth() {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
        displayedMonth = newMonth
        fetchEvents()
    }

    /// Moves the displayed month one month forward and re-fetches events.
    func nextMonth() {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        displayedMonth = newMonth
        fetchEvents()
    }

    // MARK: - Persistence

    /// Persists the start-of-week preference and updates the property.
    func saveStartOfWeek(_ value: Int) {
        startOfWeek = value
        UserDefaults.standard.set(value, forKey: "startOfWeek")
    }

    /// Persists the events-days-to-show preference, updates the property, and re-fetches events.
    func saveEventsDaysToShow(_ value: Int) {
        eventsDaysToShow = value
        UserDefaults.standard.set(value, forKey: "eventsDaysToShow")
        fetchEvents()
    }

    // MARK: - Init

    init() {
        let savedStart = UserDefaults.standard.integer(forKey: "startOfWeek")
        self.startOfWeek = savedStart == 1 ? 1 : 2
        let savedDays = UserDefaults.standard.integer(forKey: "eventsDaysToShow")
        self.eventsDaysToShow = savedDays >= 0 && savedDays <= 7 ? savedDays : 2
        self.displayedMonth = Date()

        observerTask = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .checkCalendarAccess) {
                self?.requestCalendarAccess()
            }
        }

        requestCalendarAccess()
    }
}

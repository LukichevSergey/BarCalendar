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

    private let eventStore = EKEventStore()

    init() {
        let saved = UserDefaults.standard.integer(forKey: "startOfWeek")
        self.startOfWeek = saved == 1 ? 1 : 2
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
        guard let start = cal.date(from: components),
              let end = cal.date(byAdding: .month, value: 1, to: start) else { return }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
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
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }

    func saveStartOfWeek(_ value: Int) {
        startOfWeek = value
        UserDefaults.standard.set(value, forKey: "startOfWeek")
    }
}

import SwiftUI
import EventKit

extension Notification.Name {
    static let checkCalendarAccess = Notification.Name("checkCalendarAccess")
    static let countdownUpdated = Notification.Name("countdownUpdated")
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
    /// Whether the countdown timer is shown in the menu bar and popover.
    var countdownEnabled: Bool
    /// Threshold in minutes; countdown shown only when less than this much time remains.
    var countdownThreshold: Int
    /// Cached countdown text, e.g. "45m" or "1h 23m". Empty when no countdown is active.
    var countdownText: String = ""
    /// Whether event alert overlays are enabled.
    var alertEnabled: Bool
    /// Minutes before an event to show the alert overlay.
    var alertMinutesBefore: Int
    /// Whether to play a sound when the alert appears.
    var alertSoundEnabled: Bool
    /// Selected app language code: "en", "ru", or "" for system default.
    var languageCode: String
    /// Whether to show event location in event rows.
    var showEventLocation: Bool
    /// Date selected by clicking a day cell, or nil.
    var selectedDate: Date?

    private let eventStore = EKEventStore()
    private var observerTask: Task<Void, Never>?
    private var calendarChangeTask: Task<Void, Never>?
    private var countdownTimer: Task<Void, Never>?
    private var alertTimer: Task<Void, Never>?
    private var alertedEventIDs: Set<String> = []

    /// Countdown text for the menu bar. Empty when no countdown is active.
    var menuBarDateText: String {
        if countdownEnabled && !countdownText.isEmpty {
            return countdownText
        }
        return ""
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
        updateCountdown()
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

    /// Resets the displayed month to the current month and re-fetches events.
    func resetToCurrentMonth() {
        displayedMonth = Date()
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

    // MARK: - Countdown

    /// Persists the countdown-enabled preference and starts/stops the timer.
    func saveCountdownEnabled(_ value: Bool) {
        countdownEnabled = value
        UserDefaults.standard.set(value, forKey: "countdownEnabled")
        if value {
            startCountdownTimer()
        } else {
            stopCountdownTimer()
            countdownText = ""
            NotificationCenter.default.post(name: .countdownUpdated, object: nil)
        }
    }

    /// Persists the countdown threshold preference and immediately recalculates.
    func saveCountdownThreshold(_ value: Int) {
        countdownThreshold = value
        UserDefaults.standard.set(value, forKey: "countdownThreshold")
        updateCountdown()
    }

    /// Starts the countdown timer that updates every 60 seconds.
    private func startCountdownTimer() {
        countdownTimer?.cancel()
        countdownTimer = Task { @MainActor [weak self] in
            self?.updateCountdown()
            while !Task.isCancelled {
                let secondsToNextMinute = 60 - Calendar.current.component(.second, from: Date())
                try? await Task.sleep(for: .seconds(secondsToNextMinute))
                guard !Task.isCancelled else { break }
                self?.updateCountdown()
            }
        }
    }

    /// Stops the countdown timer.
    private func stopCountdownTimer() {
        countdownTimer?.cancel()
        countdownTimer = nil
    }

    /// Calculates the time remaining to the next upcoming event and formats the countdown text.
    private func updateCountdown() {
        let now = Date()
        let upcoming = events
            .filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }

        guard let next = upcoming.first else {
            if !countdownText.isEmpty {
                countdownText = ""
                NotificationCenter.default.post(name: .countdownUpdated, object: nil)
            }
            return
        }

        let remaining = next.startDate.timeIntervalSince(now)
        let thresholdSeconds = Double(countdownThreshold) * 60

        guard remaining <= thresholdSeconds else {
            if !countdownText.isEmpty {
                countdownText = ""
                NotificationCenter.default.post(name: .countdownUpdated, object: nil)
            }
            return
        }

        let totalMinutes = Int(ceil(remaining / 60))
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            countdownText = minutes > 0
                ? "\(hours)\(String(localized: "h")) \(minutes)\(String(localized: "m"))"
                : "\(hours)\(String(localized: "h"))"
        } else {
            countdownText = "\(totalMinutes)\(String(localized: "m"))"
        }
        NotificationCenter.default.post(name: .countdownUpdated, object: nil)
    }

    // MARK: - Alerts

    func saveAlertEnabled(_ value: Bool) {
        alertEnabled = value
        UserDefaults.standard.set(value, forKey: "alertEnabled")
        if value {
            startAlertTimer()
        } else {
            stopAlertTimer()
            EventAlertManager.shared.dismissAll()
        }
    }

    func saveAlertMinutesBefore(_ value: Int) {
        alertMinutesBefore = value
        UserDefaults.standard.set(value, forKey: "alertMinutesBefore")
    }

    func saveAlertSoundEnabled(_ value: Bool) {
        alertSoundEnabled = value
        UserDefaults.standard.set(value, forKey: "alertSoundEnabled")
    }

    func saveShowEventLocation(_ value: Bool) {
        showEventLocation = value
        UserDefaults.standard.set(value, forKey: "showEventLocation")
    }

    func saveLanguage(_ code: String) {
        languageCode = code
        UserDefaults.standard.set(code, forKey: "appLanguage")
        if code.isEmpty {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
        }
    }

    private func startAlertTimer() {
        alertTimer?.cancel()
        alertTimer = Task { @MainActor [weak self] in
            self?.checkAlerts()
            while !Task.isCancelled {
                let secondsToNextMinute = 60 - Calendar.current.component(.second, from: Date())
                try? await Task.sleep(for: .seconds(secondsToNextMinute))
                guard !Task.isCancelled else { break }
                self?.checkAlerts()
            }
        }
    }

    private func stopAlertTimer() {
        alertTimer?.cancel()
        alertTimer = nil
    }

    private func checkAlerts() {
        let now = Date()
        let threshold = Double(alertMinutesBefore) * 60

        let upcoming = events
            .filter { $0.startDate > now && $0.startDate.timeIntervalSince(now) <= threshold }

        for event in upcoming {
            guard let id = event.calendarItemIdentifier as String?,
                  !alertedEventIDs.contains(id) else { continue }
            alertedEventIDs.insert(id)
            EventAlertManager.shared.show(event: event, soundEnabled: alertSoundEnabled)
        }
    }

    // MARK: - Init

    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? ""
        self.languageCode = savedLanguage
        if !savedLanguage.isEmpty {
            UserDefaults.standard.set([savedLanguage], forKey: "AppleLanguages")
        }

        let savedStart = UserDefaults.standard.integer(forKey: "startOfWeek")
        self.startOfWeek = savedStart == 1 ? 1 : 2
        let savedDays = UserDefaults.standard.integer(forKey: "eventsDaysToShow")
        self.eventsDaysToShow = savedDays >= 0 && savedDays <= 7 ? savedDays : 2
        self.countdownEnabled = UserDefaults.standard.bool(forKey: "countdownEnabled")
        let savedThreshold = UserDefaults.standard.integer(forKey: "countdownThreshold")
        self.countdownThreshold = savedThreshold > 0 ? savedThreshold : Layout.defaultCountdownThreshold
        self.displayedMonth = Date()

        self.showEventLocation = UserDefaults.standard.bool(forKey: "showEventLocation")
        self.alertEnabled = UserDefaults.standard.bool(forKey: "alertEnabled")
        let savedAlertMinutes = UserDefaults.standard.integer(forKey: "alertMinutesBefore")
        self.alertMinutesBefore = savedAlertMinutes > 0 ? savedAlertMinutes : 5
        self.alertSoundEnabled = UserDefaults.standard.bool(forKey: "alertSoundEnabled")

        observerTask = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .checkCalendarAccess) {
                self?.requestCalendarAccess()
            }
        }

        calendarChangeTask = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .EKEventStoreChanged) {
                self?.fetchEvents()
            }
        }

        requestCalendarAccess()

        if countdownEnabled {
            startCountdownTimer()
        }

        if alertEnabled {
            startAlertTimer()
        }
    }
}

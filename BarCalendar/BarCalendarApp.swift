import SwiftUI

@main
struct BarCalendarApp: App {
    @State private var calendarState = CalendarState()

    var body: some Scene {
        MenuBarExtra {
            CalendarDropdownView(state: calendarState)
        } label: {
            Text(calendarState.menuBarDateText)
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}

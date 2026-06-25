import SwiftUI

@MainActor let sharedState = CalendarState()

@main
struct BarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(state: sharedState)
        }
    }
}

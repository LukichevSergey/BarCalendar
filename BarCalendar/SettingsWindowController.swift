import SwiftUI

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show(_ state: CalendarState) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if let existing = window {
            (existing.contentViewController as? NSHostingController<SettingsView>)?.rootView = SettingsView(state: state)
            existing.center()
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingController(rootView: SettingsView(state: state))
        hosting.view.frame = NSRect(x: 0, y: 0, width: Layout.settingsWindowWidth, height: Layout.settingsWindowHeight)
        let newWindow = NSWindow(contentViewController: hosting)
        newWindow.title = String(localized: "Settings")
        newWindow.styleMask = [.titled, .closable, .resizable]
        newWindow.setContentSize(NSSize(width: Layout.settingsWindowWidth, height: Layout.settingsWindowHeight))
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
    }
}

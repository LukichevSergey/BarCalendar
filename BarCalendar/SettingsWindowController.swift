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

        let newWindow: NSWindow
        if let existing = window {
            newWindow = existing
            (existing.contentViewController as? NSHostingController<SettingsView>)?.rootView = SettingsView(state: state)
        } else {
            let hosting = NSHostingController(rootView: SettingsView(state: state))
            hosting.view.frame = NSRect(x: 0, y: 0, width: 300, height: 200)
            newWindow = NSWindow(contentViewController: hosting)
            newWindow.title = "Settings"
            newWindow.styleMask = [.titled, .closable, .resizable]
            newWindow.setContentSize(hosting.view.fittingSize)
            self.window = newWindow
        }

        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

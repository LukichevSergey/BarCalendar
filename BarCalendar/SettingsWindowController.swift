import SwiftUI

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?
    private var hostingController: NSHostingController<SettingsView>?

    func show(_ state: CalendarState) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if let existing = hostingController {
            existing.rootView = SettingsView(state: state)
            let newSize = existing.view.fittingSize
            if let window {
                window.setContentSize(newSize)
                window.center()
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }

        let hosting = NSHostingController(rootView: SettingsView(state: state))
        hosting.view.frame = NSRect(x: 0, y: 0, width: 300, height: 200)
        let newWindow = NSWindow(contentViewController: hosting)
        newWindow.title = "Settings"
        newWindow.styleMask = [.titled, .closable, .resizable]
        newWindow.setContentSize(hosting.view.fittingSize)
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
        self.hostingController = hosting
    }
}

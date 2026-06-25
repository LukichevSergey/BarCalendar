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
        let hostingController = NSHostingController(rootView: SettingsView(state: state))
        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "Settings"
        newWindow.styleMask = [.titled, .closable]
        newWindow.setContentSize(hostingController.view.fittingSize)
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
    }
}

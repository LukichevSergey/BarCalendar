import SwiftUI

let sharedState = CalendarState()

@main
struct BarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(state: sharedState)
        }
    }
}

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
        newWindow.setContentSize(NSSize(width: 300, height: 100))
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = sharedState.menuBarDateText
            button.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 400)
        popover?.behavior = .transient
        popover?.animates = true

        let hostingController = NSHostingController(rootView: CalendarDropdownView(state: sharedState))
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 280, height: 400)
        popover?.contentViewController = hostingController
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover?.contentViewController?.view.window?.makeKey()
        }
    }
}

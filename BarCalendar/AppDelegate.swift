import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = sharedState.menuBarDateText
            button.font = NSFont.systemFont(ofSize: Layout.statusBarFontSize, weight: .medium)
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: Layout.popoverWidth, height: Layout.popoverHeight)
        popover?.behavior = .transient
        popover?.animates = true

        let hostingController = NSHostingController(rootView: CalendarDropdownView(state: sharedState))
        hostingController.view.frame = NSRect(x: 0, y: 0, width: Layout.popoverWidth, height: Layout.popoverHeight)
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

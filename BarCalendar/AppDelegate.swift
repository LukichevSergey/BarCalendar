import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            let size = NSSize(width: 20, height: 20)
            let image = NSImage(size: size, flipped: false) { rect in
                if let symbol = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar") {
                    let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
                    let sized = symbol.withSymbolConfiguration(config) ?? symbol
                    sized.draw(in: rect)
                    return true
                }
                return false
            }
            image.isTemplate = true
            button.image = image
            button.title = sharedState.menuBarDateText
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

        NotificationCenter.default.addObserver(
            forName: .countdownUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.statusItem?.button?.title = sharedState.menuBarDateText
        }
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

import SwiftUI
import EventKit

// MARK: - EventAlertWindow

final class EventAlertWindow: NSWindow {
    let eventID: String

    init(eventID: String, screen: NSScreen) {
        self.eventID = eventID
        super.init(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
        self.ignoresMouseEvents = false
        self.animationBehavior = .utilityWindow
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - EventAlertView

struct EventAlertView: View {
    let event: EKEvent
    let onClose: () -> Void

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: event.startDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text(event.title ?? "Event")
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text(timeString)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button {
                onClose()
            } label: {
                Text("Close")
                    .font(.system(size: 17, weight: .medium))
                    .frame(height: Layout.alertButtonHeight)
                    .padding(.horizontal, 32)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: Layout.alertButtonCornerRadius))
            }
            .buttonStyle(.plain)
            .padding(.bottom, Layout.alertWindowPadding)
        }
        .padding(Layout.alertWindowPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Layout.alertWindowCornerRadius))
        .clipShape(RoundedRectangle(cornerRadius: Layout.alertWindowCornerRadius))
        .shadow(color: .black.opacity(0.25), radius: 40, y: 10)
        .padding(Layout.screenEdgePadding)
    }
}

// MARK: - EventAlertManager

@MainActor
final class EventAlertManager {
    static let shared = EventAlertManager()

    private var windows: [String: [EventAlertWindow]] = [:]

    func show(event: EKEvent, soundEnabled: Bool) {
        guard let id = event.calendarItemIdentifier as String? else { return }
        dismiss(eventID: id)

        if soundEnabled {
            NSSound.beep()
        }

        var newWindows: [EventAlertWindow] = []
        for screen in NSScreen.screens {
            let window = EventAlertWindow(eventID: id, screen: screen)
            let hosting = NSHostingController(rootView: EventAlertView(event: event) { [weak self] in
                self?.dismiss(eventID: id)
            })
            hosting.view.frame = screen.frame
            hosting.view.autoresizingMask = [.width, .height]
            window.contentViewController = hosting
            window.orderFront(nil)
            newWindows.append(window)
        }
        windows[id] = newWindows
    }

    func dismiss(eventID: String) {
        guard let existing = windows.removeValue(forKey: eventID) else { return }
        for window in existing {
            window.orderOut(nil)
        }
    }

    func dismissAll() {
        let allIDs = Array(windows.keys)
        for id in allIDs {
            dismiss(eventID: id)
        }
    }

    func dismissIfPast() {
        let now = Date()
        let expiredIDs = windows.keys.filter { id in
            guard let window = windows[id]?.first,
                  let hosting = window.contentViewController as? NSHostingController<EventAlertView> else {
                return true
            }
            return hosting.rootView.event.startDate <= now
        }
        for id in expiredIDs {
            dismiss(eventID: id)
        }
    }
}

import SwiftUI

struct PermissionPromptView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: Layout.padding) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Calendar access required")
                .font(.caption)
            Text("Allow BarCalendar to read your calendar events.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Grant Access") {
                state.requestCalendarAccess()
            }
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
            HStack(spacing: Layout.padding) {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .controlSize(.small)
                Button("Check again") {
                    NotificationCenter.default.post(name: .checkCalendarAccess, object: nil)
                }
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.groupSpacing)
    }
}

import SwiftUI

struct CalendarDropdownView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                MonthHeaderView(state: state)
                Button {
                    SettingsWindowController.shared.show(state)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            WeekdayHeaderRow(startOfWeek: state.startOfWeek)
            CalendarGridView(state: state)

            Divider()

            EventsSectionView(state: state)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .frame(width: 280)
    }
}

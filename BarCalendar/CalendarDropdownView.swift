import SwiftUI

struct CalendarDropdownView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(spacing: Layout.padding) {
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
                .help("Open settings")
            }

            WeekdayHeaderRow(startOfWeek: state.startOfWeek)
            CalendarGridView(state: state)

            CountdownView(text: state.countdownText)

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
        .padding(Layout.padding)
        .frame(width: Layout.popoverWidth)
    }
}

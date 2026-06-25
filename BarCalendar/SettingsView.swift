import SwiftUI

struct SettingsView: View {
    @Bindable var state: CalendarState

    var body: some View {
        Form {
            Picker("Start of Week", selection: Binding(
                get: { state.startOfWeek },
                set: { state.saveStartOfWeek($0) }
            )) {
                Text("Monday").tag(2)
                Text("Sunday").tag(1)
            }

            Picker("Days to Show", selection: Binding(
                get: { state.eventsDaysToShow },
                set: { state.saveEventsDaysToShow($0) }
            )) {
                Text("Off").tag(0)
                Text("1 day").tag(1)
                Text("2 days").tag(2)
                Text("3 days").tag(3)
                Text("4 days").tag(4)
                Text("5 days").tag(5)
                Text("6 days").tag(6)
                Text("7 days").tag(7)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}

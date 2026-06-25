import SwiftUI

struct SettingsView: View {
    @Bindable var state: CalendarState
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Form {
            Picker("Start of Week", selection: Binding(
                get: { state.startOfWeek },
                set: { state.saveStartOfWeek($0) }
            )) {
                Text("Monday").tag(2)
                Text("Sunday").tag(1)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(width: 300)
    }
}

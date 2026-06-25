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

            Section("Countdown") {
                Toggle("Show countdown timer", isOn: Binding(
                    get: { state.countdownEnabled },
                    set: { state.saveCountdownEnabled($0) }
                ))
                if state.countdownEnabled {
                    Picker("Threshold", selection: Binding(
                        get: { state.countdownThreshold },
                        set: { state.saveCountdownThreshold($0) }
                    )) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                        Text("3 hours").tag(180)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}

import SwiftUI

struct SettingsView: View {
    @Bindable var state: CalendarState
    @State private var showRestartAlert = false

    var body: some View {
        Form {
            Section("Language") {
                Picker("Language", selection: Binding(
                    get: { state.languageCode.isEmpty ? "en" : state.languageCode },
                    set: { newValue in
                        guard newValue != state.languageCode else { return }
                        state.saveLanguage(newValue)
                        showRestartAlert = true
                    }
                )) {
                    Text("English").tag("en")
                    Text("Russian").tag("ru")
                }
            }

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

            Toggle("Show event location", isOn: Binding(
                get: { state.showEventLocation },
                set: { state.saveShowEventLocation($0) }
            ))

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

            Section("Alerts") {
                Toggle("Show event alerts", isOn: Binding(
                    get: { state.alertEnabled },
                    set: { state.saveAlertEnabled($0) }
                ))
                if state.alertEnabled {
                    Picker("Alert before", selection: Binding(
                        get: { state.alertMinutesBefore },
                        set: { state.saveAlertMinutesBefore($0) }
                    )) {
                        Text("1 minute").tag(1)
                        Text("3 minutes").tag(3)
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                        Text("15 minutes").tag(15)
                        Text("20 minutes").tag(20)
                        Text("25 minutes").tag(25)
                        Text("30 minutes").tag(30)
                    }
                    Toggle("Play sound", isOn: Binding(
                        get: { state.alertSoundEnabled },
                        set: { state.saveAlertSoundEnabled($0) }
                    ))
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .alert("Restart Required", isPresented: $showRestartAlert) {
            Button("Later") { }
            Button("Restart Now") {
                let appPath = Bundle.main.bundlePath
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                process.arguments = ["-a", appPath]
                try? process.run()
                NSApplication.shared.terminate(nil)
            }
        } message: {
            Text("Please restart BarCalendar to apply the language change.")
        }
    }
}

import SwiftUI

struct SettingsView: View {
    @Bindable var state: CalendarState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Start of Week")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Picker("", selection: Binding(
                get: { state.startOfWeek },
                set: { state.saveStartOfWeek($0) }
            )) {
                Text("Monday").tag(2)
                Text("Sunday").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }
}

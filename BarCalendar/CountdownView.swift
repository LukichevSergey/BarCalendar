import SwiftUI

struct CountdownView: View {
    let text: String

    var body: some View {
        if !text.isEmpty {
            HStack {
                Text("Next event in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.subheadline.monospacedDigit().weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.vertical, Layout.countdownVerticalPadding)
        }
    }
}

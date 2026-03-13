import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ClapFinderViewModel

    var body: some View {
        NavigationView {
            Form {
                Section("Status") {
                    HStack {
                        Circle()
                            .fill(viewModel.isListening ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        Text(viewModel.isListening ? "Listening for claps" : "Not listening")
                    }

                    Text(viewModel.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Detection") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sensitivity")
                            Spacer()
                            Text(viewModel.sensitivityLabel)
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $viewModel.sensitivity, in: 0...1)
                    }

                    Toggle("Blink flashlight on detection", isOn: $viewModel.shouldBlinkFlashlight)
                }

                Section("Controls") {
                    Button(viewModel.isListening ? "Disable Listening" : "Enable Listening") {
                        viewModel.toggleListening()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Button("Stop Alarm", role: .destructive) {
                        viewModel.stopAlarm()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("ClapFinder")
        }
    }
}

#Preview {
    ContentView(viewModel: ClapFinderViewModel())
}

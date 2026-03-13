import Combine
import Foundation

@MainActor
final class ClapFinderViewModel: ObservableObject {
    @Published var isListening = false
    @Published var shouldBlinkFlashlight = false
    @Published var sensitivity: Double = 0.6 {
        didSet {
            detector.sensitivity = Float(sensitivity)
        }
    }
    @Published var statusText = "Tap enable to start listening."

    var sensitivityLabel: String {
        switch sensitivity {
        case ..<0.33: return "Low"
        case ..<0.66: return "Medium"
        default: return "High"
        }
    }

    private let detector = ClapDetectionService()
    private let alarm = AlarmService()
    private let flashlight = FlashlightService()

    init() {
        detector.sensitivity = Float(sensitivity)
        detector.onClapDetected = { [weak self] in
            Task { @MainActor in
                self?.onClapDetected()
            }
        }
    }

    func toggleListening() {
        isListening ? stopListening() : startListening()
    }

    func stopAlarm() {
        alarm.stopAlarm()
        flashlight.stopBlinking()
        statusText = isListening ? "Listening for claps" : "Alarm stopped."
    }

    private func startListening() {
        detector.startListening { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success:
                    self.isListening = true
                    self.statusText = "Listening for claps"
                case .failure(let error):
                    self.isListening = false
                    self.statusText = "Unable to listen: \(error.localizedDescription)"
                }
            }
        }
    }

    private func stopListening() {
        detector.stopListening()
        isListening = false
        statusText = "Listening disabled"
    }

    private func onClapDetected() {
        statusText = "Clap detected! Alarm started."
        alarm.playAlarm()

        if shouldBlinkFlashlight {
            flashlight.startBlinking()
        }
    }
}

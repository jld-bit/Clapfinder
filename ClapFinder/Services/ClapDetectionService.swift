import AVFoundation
import Foundation

final class ClapDetectionService {
    var onClapDetected: (() -> Void)?
    var sensitivity: Float = 0.6

    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var isListening = false
    private var lastClapTimestamp: TimeInterval = 0
    private let minimumClapInterval: TimeInterval = 0.55

    func startListening(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isListening else {
            completion(.success(()))
            return
        }

        session.requestRecordPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                completion(.failure(ClapDetectionError.microphonePermissionDenied))
                return
            }

            do {
                try self.configureAudioSession()
                self.setupInputTap()
                self.engine.prepare()
                try self.engine.start()
                self.isListening = true
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func stopListening() {
        guard isListening else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isListening = false
    }

    private func configureAudioSession() throws {
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
        try session.setMode(.measurement)
        try session.setActive(true)
    }

    private func setupInputTap() {
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
    }

    private func process(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }

        var sum: Float = 0
        var peak: Float = 0

        for i in 0..<frameLength {
            let sample = channelData[i]
            let amplitude = fabsf(sample)
            sum += amplitude * amplitude
            peak = max(peak, amplitude)
        }

        let rms = sqrt(sum / Float(frameLength))
        let threshold = thresholdForSensitivity(sensitivity)

        guard peak > threshold || rms > threshold * 0.5 else { return }

        let now = Date().timeIntervalSince1970
        guard now - lastClapTimestamp > minimumClapInterval else { return }
        lastClapTimestamp = now

        onClapDetected?()
    }

    private func thresholdForSensitivity(_ sensitivity: Float) -> Float {
        let clamped = min(max(sensitivity, 0), 1)
        return 0.35 - (0.3 * clamped)
    }
}

enum ClapDetectionError: LocalizedError {
    case microphonePermissionDenied

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone access is required for clap detection."
        }
    }
}

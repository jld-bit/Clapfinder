import AVFoundation
import Foundation

final class FlashlightService {
    private var timer: Timer?
    private var torchOn = false

    func startBlinking() {
        guard timer == nil else { return }

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
                self?.toggleTorch()
            }
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
        setTorch(enabled: false)
    }

    private func toggleTorch() {
        torchOn.toggle()
        setTorch(enabled: torchOn)
    }

    private func setTorch(enabled: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if enabled {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch configuration failed: \(error.localizedDescription)")
        }
    }
}

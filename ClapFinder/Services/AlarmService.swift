import AVFoundation
import AudioToolbox
import Foundation

final class AlarmService {
    private var player: AVAudioPlayer?

    func playAlarm() {
        if let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.prepareToPlay()
                player?.play()
                return
            } catch {
                print("Failed to play bundled alarm: \(error.localizedDescription)")
            }
        }

        AudioServicesPlaySystemSound(1005)
    }

    func stopAlarm() {
        player?.stop()
        player = nil
    }
}

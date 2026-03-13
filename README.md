# ClapFinder

ClapFinder is a native iPhone app built with SwiftUI that listens for clap sounds and triggers a loud alarm so you can locate your phone quickly.

## Features

- Clap detection using microphone input
- Alarm playback when a clap is detected
- Adjustable sensitivity slider
- Optional flashlight blinking
- Enable/disable listening control

## Open in Xcode

1. Open `ClapFinder.xcodeproj` in Xcode.
2. Select an iOS device target.
3. Run the app.
4. Allow microphone permission when prompted.

## Notes

- Add an `alarm.mp3` sound file to the app target if you want a custom looping alarm sound.
- If `alarm.mp3` is missing, the app falls back to a system alert sound.

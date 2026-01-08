# Simple Radio iOS App

An internet radio streaming iOS app built with SwiftUI.

## Features

- **Two Playback Modes**
  - **채널 선택 모드** (Channel Selection): Manual station selection from categorized list
  - **자동 재생 모드** (Auto Play): Clock-based 24-hour scheduled playback

- **Streaming Support**
  - Direct HLS streams (`.m3u8`)
  - PLS playlist parsing
  - Background audio playback
  - Audio interruption handling (resumes after calls/alarms)

- **Modern UI**
  - SwiftUI with Observation framework
  - Animated waveform indicators
  - Floating mini player
  - 24-hour schedule grid with time-of-day icons

## Supported Stations

International radio stations organized by mood/purpose. Sources: RadioNOS (Brazil) and Public Domain Radio (Switzerland).

| Category | Stations |
|----------|----------|
| 집중/공부 (Focus) | RadioNOS Ambient, RadioNOS Electronica, RadioNOS Chiptune |
| 휴식/수면 (Relaxation) | RadioNOS Relaxing, RadioNOS New Age |
| 클래식 (Classical) | Public Domain Classical, RadioNOS Modern Classical |
| 카페/라운지 (Cafe) | Public Domain Jazz, RadioNOS Jazz, RadioNOS Lounge |

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Build

```bash
# Build the project
xcodebuild -scheme SimpleRadio -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild -scheme SimpleRadio clean
```

## Project Structure

```
SimpleRadio/
├── SimpleRadioApp.swift
├── ContentView.swift
├── Info.plist
├── Models/
│   ├── RadioStation.swift      # Station data with icons and colors
│   └── HourlySchedule.swift    # 24-hour schedule persistence
├── Views/
│   ├── RadioStationListView.swift
│   ├── RadioStationRow.swift
│   ├── NowPlayingView.swift
│   └── ScheduleView.swift
├── Services/
│   ├── RadioPlayer.swift       # AVPlayer wrapper with PLS parsing
│   └── ScheduleManager.swift   # Clock-based auto-switching
└── Assets.xcassets/
```

## License

MIT

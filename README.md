# Simple Radio iOS App

A Korean radio streaming iOS app built with SwiftUI.

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

Korean broadcasters organized by category:

| Category | Stations |
|----------|----------|
| KBS | KBS 1Radio, KBS 2Radio, KBS 3Radio, KBS Classic FM, KBS Cool FM, KBS World Radio |
| MBC | MBC 표준FM, MBC FM4U |
| SBS | SBS 러브FM, SBS 파워FM |
| EBS | EBS FM |
| CBS | CBS 표준FM, CBS 음악FM |
| TBS | TBS FM, TBS eFM |

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

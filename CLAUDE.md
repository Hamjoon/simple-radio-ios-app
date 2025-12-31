# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Korean radio streaming iOS app with two modes:
- **채널 선택 모드**: Manual station selection
- **자동 재생 모드**: Clock-based 24-hour scheduled playback

## Build Commands

```bash
# Build the project
xcodebuild -scheme SimpleRadio -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild -scheme SimpleRadio clean
```

## Architecture

The project uses SwiftUI with the Observation framework (`@Observable`).

### Models
- `RadioStation.swift` - Station data (name, streamURL, category) with static station list; includes `icon` (SF Symbol) and `color` per category
- `HourlySchedule.swift` - 24-hour schedule mapping hours to stations, persisted as JSON

### Views
- `ContentView.swift` - Custom tab-style mode picker with SF Symbols, animated toolbar icon
- `RadioStationListView.swift` - Station list grouped by category with icons and channel counts
- `RadioStationRow.swift` - Station row with category badge, waveform animation (`WaveformView`)
- `NowPlayingView.swift` - Floating card mini player with gradient progress line, stop/play buttons
- `ScheduleView.swift` - 24-hour grid with time-of-day icons, timeline dividers, station picker sheet

### Services
- `RadioPlayer.swift` - Singleton AVPlayer wrapper with PLS parsing, background audio, Now Playing info, interruption handling
- `ScheduleManager.swift` - Clock-based auto-switching with 60-second timer, `activeHour` for real-time tracking

## Project Structure

```
SimpleRadio/
├── SimpleRadioApp.swift
├── ContentView.swift
├── Info.plist                  # ATS exceptions, background audio mode
├── Models/
│   ├── RadioStation.swift
│   └── HourlySchedule.swift
├── Views/
│   ├── RadioStationListView.swift
│   ├── RadioStationRow.swift
│   ├── NowPlayingView.swift
│   └── ScheduleView.swift
├── Services/
│   ├── RadioPlayer.swift
│   └── ScheduleManager.swift
└── Assets.xcassets/
```

## Radio Stations

Korean broadcasters: KBS, MBC, SBS, EBS, CBS, TBS. Stream sources:
- Direct HLS (`.m3u8`): CBS, TBS, EBS
- PLS playlists (`.pls`): KBS, MBC, SBS via `serpent0.duckdns.org`
- Proxy streams: `radio.bsod.kr/stream/`

### Category Icons & Colors
| Category | Icon | Color |
|----------|------|-------|
| KBS | `k.circle.fill` | blue |
| MBC | `m.circle.fill` | purple |
| SBS | `s.circle.fill` | orange |
| EBS | `e.circle.fill` | green |
| CBS | `c.circle.fill` | red |
| TBS | `t.circle.fill` | teal |

## Key Implementation Details

- **PLS Parsing**: `RadioPlayer` fetches and parses `.pls` files to extract `File1=` stream URL
- **Schedule Persistence**: `HourlySchedule` saves to `Documents/hourly_schedule.json`
- **Empty Hour Behavior**: Radio stops when no station is scheduled for current hour
- **Auto-Scroll**: ScheduleView auto-scrolls to current hour on appear and when hour changes
- **Background Audio**: Enabled via `UIBackgroundModes` in Info.plist
- **Audio Interruption**: Resumes playback after interruptions (phone calls, alarms) when system allows
- **UI State Sync**: Switching modes updates UI across both tabs; manual play disables schedule mode via `disableScheduleMode()`
- **Real-time Hour Tracking**: `ScheduleManager.activeHour` triggers UI updates when hour changes during auto-play

## SF Symbols Used

- `antenna.radiowaves.left.and.right` - App branding, animated during playback
- `radio.fill` / `clock.fill` - Mode picker tabs
- `waveform` - Playing state indicator
- `sunrise.fill` / `sun.max.fill` / `sunset.fill` / `moon.stars.fill` - Time-of-day in schedule
- `calendar.badge.clock` - Schedule section header
- `play.circle.fill` / `pause.fill` / `stop.circle.fill` - Playback controls
- `xmark.circle.fill` - Close/stop buttons
- `plus.circle.dashed` - Empty schedule slot
- `checkmark.circle.fill` - Selected item in picker

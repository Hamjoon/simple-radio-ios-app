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
- `RadioStation.swift` - Station data (name, streamURL, category) with static station list
- `HourlySchedule.swift` - 24-hour schedule mapping hours to stations, persisted as JSON

### Views
- `ContentView.swift` - Segmented control switching between modes
- `RadioStationListView.swift` - Station list grouped by category (KBS, MBC, SBS, etc.)
- `RadioStationRow.swift` - Individual station row with playing indicator
- `NowPlayingView.swift` - Bottom mini player bar
- `ScheduleView.swift` - 24-hour grid for schedule setup with station picker sheet

### Services
- `RadioPlayer.swift` - Singleton AVPlayer wrapper with PLS parsing, background audio, Now Playing info
- `ScheduleManager.swift` - Clock-based auto-switching with 60-second timer

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

## Key Implementation Details

- **PLS Parsing**: `RadioPlayer` fetches and parses `.pls` files to extract `File1=` stream URL
- **Schedule Persistence**: `HourlySchedule` saves to `Documents/hourly_schedule.json`
- **Empty Hour Behavior**: Radio stops when no station is scheduled for current hour
- **Background Audio**: Enabled via `UIBackgroundModes` in Info.plist

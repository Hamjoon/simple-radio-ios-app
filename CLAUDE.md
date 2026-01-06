# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Korean radio streaming iOS app with two modes:
- **채널 선택 모드**: Manual station selection
- **자동 재생 모드**: Clock-based 24-hour scheduled playback

## Required Items when implementing code
- Create a work branch from the develop branch.
- Use the work branch to implement the code.
- Before creating this PR with the completed code implementation, verify with the user.

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
- `RadioStationRow.swift` - Station row with category badge, waveform animation (`WaveformView`), loading/error states
- `NowPlayingView.swift` - Floating card mini player with gradient progress line, stop/play buttons, error banner with retry
- `ScheduleView.swift` - 24-hour grid with time-of-day icons, timeline dividers, station picker sheet, error state display

### Services
- `RadioPlayer.swift` - Singleton AVPlayer wrapper with PLS parsing, background audio, Now Playing info, interruption handling, error state management
- `ScheduleManager.swift` - Clock-based auto-switching with minute-aligned timer, `activeHour` for real-time tracking

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

Korean broadcasters: KBS, MBC, SBS, EBS, CBS, TBS. 

**Stream Source**: All stations use `radio.bsod.kr` proxy service (Cloudflare Workers) for reliable global access.

URL format: `https://radio.bsod.kr/stream/?stn={station}&ch={channel}`

| Station | stn | ch |
|---------|-----|-----|
| KBS 1Radio | kbs | 1radio |
| KBS HappyFM | kbs | 2radio |
| KBS ClassicFM | kbs | 1fm |
| KBS CoolFM | kbs | 2fm |
| MBC 표준FM | mbc | sfm |
| MBC FM4U | mbc | fm4u |
| SBS 파워FM | sbs | powerfm |
| SBS 러브FM | sbs | lovefm |
| SBS 고릴라디오M | sbs | dmb |
| EBS FM | ebs | (none) |
| CBS 표준FM | cbs | sfm |
| CBS 음악FM | cbs | mfm |
| CBS JOY4U | cbs | joy4u |
| TBS FM | tbs | fm |
| TBS eFM | tbs | efm |

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

- **Stream Proxy**: Uses `radio.bsod.kr` Cloudflare Workers proxy for reliable access from any location (including App Store reviewers in US)
- **Error Handling**: RadioPlayer includes `error` state with AVPlayerItem status monitoring; UI displays error banner with retry button
- **Schedule Persistence**: `HourlySchedule` saves to `Documents/hourly_schedule.json`
- **Empty Hour Behavior**: Radio stops when no station is scheduled for current hour
- **Auto-Scroll**: ScheduleView auto-scrolls to current hour on appear and when hour changes
- **Background Audio**: Enabled via `UIBackgroundModes` in Info.plist
- **Audio Interruption**: Resumes playback after interruptions (phone calls, alarms) when system allows
- **UI State Sync**: Switching modes updates UI across both tabs; manual play disables schedule mode via `disableScheduleMode()`
- **Real-time Hour Tracking**: `ScheduleManager.activeHour` triggers UI updates when hour changes during auto-play
- **Timer Sync**: Schedule timer aligns to minute boundaries (fires at :00 seconds) for precise hour-change detection
- **Loading States**: UI shows ProgressView during stream connection
- **Error States**: Red error banner, retry button, "연결 실패" status text

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
- `exclamationmark.triangle.fill` - Error state indicator
- `arrow.clockwise` - Retry button

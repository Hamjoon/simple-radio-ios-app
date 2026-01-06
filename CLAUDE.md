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
xcodebuild -scheme SimpleRadio -destination 'platform=iOS Simulator,name=iPhone 17' build

# Clean build
xcodebuild -scheme SimpleRadio clean
```

## Architecture

The project uses SwiftUI with the Observation framework (`@Observable`).

### Data Source
- **Radio Browser API** (radio-browser.info): Community-maintained public radio station database
- Korean stations fetched via `countrycode=KR` filter
- API servers: `de2.api.radio-browser.info`, `fi1.api.radio-browser.info`

### Models
- `RadioStation.swift` - Station data from Radio Browser API (stationuuid, name, streamURL, urlResolved, codec, bitrate, tags, favicon); category inferred from name/tags
- `HourlySchedule.swift` - 24-hour schedule mapping hours to station UUIDs, persisted as JSON (v2 format)

### Views
- `ContentView.swift` - Custom tab-style mode picker with SF Symbols, animated toolbar icon
- `RadioStationListView.swift` - Station list grouped by category with icons and channel counts; loading/error states
- `RadioStationRow.swift` - Station row with category badge, waveform animation (`WaveformView`), loading/error states
- `NowPlayingView.swift` - Floating card mini player with gradient progress line, stop/play buttons, error banner with retry
- `ScheduleView.swift` - 24-hour grid with time-of-day icons, timeline dividers, station picker sheet, error state display

### Services
- `RadioBrowserAPI.swift` - Actor-based API client for Radio Browser; fetches Korean stations, records clicks, station lookup by UUID
- `StationRepository.swift` - Singleton station cache with 24-hour expiry; loads from API, falls back to cache; provides category filtering
- `RadioPlayer.swift` - Singleton AVPlayer wrapper with PLS/M3U parsing, background audio, Now Playing info, interruption handling, error state management
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
│   ├── RadioBrowserAPI.swift
│   ├── StationRepository.swift
│   ├── RadioPlayer.swift
│   └── ScheduleManager.swift
└── Assets.xcassets/
```

## Radio Browser API

**Base URL**: `https://{server}/json/stations/search`

**Endpoints Used**:
- `GET /json/stations/search?countrycode=KR&limit=200&hidebroken=true` - Fetch Korean stations
- `GET /json/url/{stationuuid}` - Record click and get resolved URL
- `GET /json/stations/byuuid/{uuid}` - Get station by UUID

**Station Fields**:
- `stationuuid`: Unique identifier (used for schedule persistence)
- `name`: Display name
- `url`: Original stream URL
- `url_resolved`: Resolved/redirected stream URL (preferred)
- `codec`: Audio codec (MP3, AAC, etc.)
- `bitrate`: Stream bitrate
- `favicon`: Station icon URL
- `tags`: Comma-separated tags for categorization

### Category Icons & Colors
| Category | Icon | Color | Detection |
|----------|------|-------|-----------|
| KBS | `k.circle.fill` | blue | Name starts with "KBS" |
| MBC | `m.circle.fill` | purple | Name contains "MBC" |
| SBS | `s.circle.fill` | orange | Name starts with "SBS" |
| EBS | `e.circle.fill` | green | Name contains "EBS" |
| CBS | `c.circle.fill` | red | Name contains "CBS" |
| TBS | `t.circle.fill` | teal | Name contains "TBS" |
| Other | `radio.fill` | gray | Default |

## Key Implementation Details

- **Radio Browser API**: Uses public API for station data; no copyright issues
- **Station Caching**: `StationRepository` caches stations for 24 hours in `stations_cache.json`
- **Error Handling**: RadioPlayer includes `error` state with AVPlayerItem status monitoring; UI displays error banner with retry button
- **Schedule Persistence**: `HourlySchedule` saves to `Documents/hourly_schedule_v2.json` using station UUIDs
- **Stream Format Support**: Handles direct streams, PLS playlists, and M3U/M3U8 (HLS) playlists
- **Click Recording**: Records station clicks to Radio Browser API for community statistics
- **Empty Hour Behavior**: Radio stops when no station is scheduled for current hour
- **Auto-Scroll**: ScheduleView auto-scrolls to current hour on appear and when hour changes
- **Background Audio**: Enabled via `UIBackgroundModes` in Info.plist
- **Audio Interruption**: Resumes playback after interruptions (phone calls, alarms) when system allows
- **UI State Sync**: Switching modes updates UI across both tabs; manual play disables schedule mode via `disableScheduleMode()`
- **Real-time Hour Tracking**: `ScheduleManager.activeHour` triggers UI updates when hour changes during auto-play
- **Timer Sync**: Schedule timer aligns to minute boundaries (fires at :00 seconds) for precise hour-change detection
- **Loading States**: UI shows ProgressView during stream connection and station list loading
- **Error States**: Red error banner, retry button, "연결 실패" status text
- **Pull-to-Refresh**: Station list supports pull-to-refresh to reload from API

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
- `wifi.exclamationmark` - Network error state

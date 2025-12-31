# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple radio streaming iOS application built with Swift and SwiftUI.

## Build Commands

```bash
# Build the project
xcodebuild -scheme SimpleRadio -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme SimpleRadio -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean build
xcodebuild -scheme SimpleRadio clean
```

## Architecture

This project follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Data structures representing radio stations and playback state
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management connecting models to views

### Audio Streaming

The app uses AVFoundation's `AVPlayer` for streaming radio content. Key considerations:
- Handle audio session configuration for background playback
- Implement proper audio interruption handling (calls, other apps)
- Support Now Playing info and remote control commands via `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter`

## Project Structure

```
SimpleRadio/
├── SimpleRadioApp.swift        # App entry point
├── ContentView.swift           # Main container view
├── Models/
│   └── RadioStation.swift      # Station data model with Korean radio stations
├── Views/
│   ├── RadioStationListView.swift  # Station list grouped by category
│   ├── RadioStationRow.swift       # Individual station row
│   └── NowPlayingView.swift        # Mini player bar
├── Services/
│   └── RadioPlayer.swift       # AVPlayer-based audio streaming service
├── Assets.xcassets/
└── Preview Content/
```

## Radio Stations

Stations are sourced from Korean broadcasters (KBS, MBC, SBS, EBS, CBS, TBS) using streaming URLs from radio.bsod.kr.

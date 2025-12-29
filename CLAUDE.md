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
├── SimpleRadioApp.swift    # App entry point
├── ContentView.swift       # Main view
├── Assets.xcassets/        # App icons and colors
└── Preview Content/        # SwiftUI preview assets
```

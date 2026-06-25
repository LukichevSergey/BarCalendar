<p align="center">
  <img src="https://img.shields.io/badge/macOS-14%2B-blue?logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6.0-orange?logo=swift" alt="Swift 6">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/build-passing-brightgreen" alt="Build">
</p>

<h1 align="center">BarCalendar</h1>

<p align="center">
  A minimal calendar in your menu bar. Events, countdowns, and alerts — always one click away.
</p>

---

## What it does

BarCalendar lives in your menu bar and shows your calendar events at a glance. No bloat, no accounts, no cloud sync — just your local EventKit calendars, beautifully presented.

**Click the icon.** See your month, upcoming events, and time until your next meeting.

**Never miss a thing.** Full-screen alerts appear before each event, even across multiple monitors.

## Features

| Feature | Description |
|---|---|
| **Month grid** | Full calendar with today highlight, colored event dots per calendar, and adjacent month fill |
| **Upcoming events** | Grouped by day with calendar-colored indicators, time ranges, and past event strikethrough |
| **Countdown timer** | Shows time until next event in the menu bar and popover |
| **Event alerts** | Full-screen overlay with event name and time, appears 1–30 min before each event on all monitors |
| **Multi-monitor** | Alerts display on every connected display simultaneously |
| **Configurable** | Start of week, days to show, countdown threshold, alert timing, sound on/off |
| **Zero config** | Reads your existing calendars — no setup, no login, no data leaves your machine |

## Screenshots

<div align="center">
  <em>Popover with month grid, events, and countdown</em>
</div>

<br>

<div align="center">
  <em>Full-screen event alert overlay</em>
</div>

## Requirements

- macOS 14.0 or later
- Xcode 16.0+ (for building)
- Calendar access permission (requested on first launch)

## Install

### Build from source

```bash
git clone https://github.com/LukichevSergey/BarCalendar.git
cd BarCalendar
xcodebuild -project BarCalendar.xcodeproj -scheme BarCalendar -destination 'platform=macOS' build
```

The app will be in `Build/Release/BarCalendar.app`.

### Create DMG

```bash
./create-dmg.sh
```

## Usage

1. Launch BarCalendar — the calendar icon appears in your menu bar
2. Click the icon to open the popover
3. Grant calendar access when prompted
4. Navigate months with the arrow buttons
5. Open settings with the gear icon

### Settings

| Setting | Options |
|---|---|
| **Start of Week** | Monday, Sunday |
| **Days to Show** | Off, 1–7 days |
| **Countdown** | On/Off, threshold 15 min – 3 hours |
| **Alerts** | On/Off, 1–30 min before event, sound on/off |

## Architecture

```
BarCalendar/
├── BarCalendarApp.swift          # App entry point
├── AppDelegate.swift             # Status bar + popover lifecycle
├── CalendarState.swift           # Observable state, EventKit, timers
├── CalendarDropdownView.swift    # Root popover view
├── CalendarGridView.swift        # Month grid (LazyVGrid)
├── DayCell.swift                 # Single day with colored event dots
├── EventsSectionView.swift       # Upcoming events list
├── EventGroupView.swift          # Event group + row components
├── EventAlertWindow.swift        # Full-screen alert overlay
├── SettingsView.swift            # Preferences form
├── SettingsWindowController.swift # Settings window manager
├── CountdownView.swift           # Countdown display
├── MonthHeaderView.swift         # Month navigation
├── WeekdayHeaderRow.swift        # Day-of-week headers
├── PermissionPromptView.swift    # Calendar access prompt
└── Layout.swift                  # Layout constants
```

**State management:** Single `@Observable @MainActor` class (`CalendarState`) holds all app state. No `@EnvironmentObject`, no Combine, no Redux.

**Concurrency:** Swift 6 strict concurrency. All UI on `@MainActor`. EventKit access via `async/await`.

**Windows:** Popover is a fixed-size `NSPopover`. Settings is an `NSWindow` with `NSHostingController`. Alerts are borderless `NSWindow`s at `.screenSaver` level.

## Tech Stack

- **SwiftUI** — all views
- **EventKit** — calendar data
- **AppKit** — `NSPopover`, `NSWindow`, `NSStatusBar`
- **Swift 6** — strict concurrency, `@Observable`

## Contributing

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Build and test: `xcodebuild -project BarCalendar.xcodeproj -scheme BarCalendar -destination 'platform=macOS' build`
5. Open a PR

## License

MIT

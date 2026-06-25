# BarCalendar

macOS menu bar calendar app. SwiftUI views rendered inside an AppKit `NSPopover` (dropdown) and a custom `NSWindow` (settings). Reads events via EventKit.

## Build & Run

```bash
xcodebuild -project BarCalendar.xcodeproj -scheme BarCalendar -destination 'platform=macOS' build
```

No test targets, no linter, no CI. Build is the only verification. After a code change: build, launch, click the menu bar icon, verify visually.

## File Map

All source files are in `BarCalendar/` (flat, no subdirectories).

| File | Contents |
|---|---|
| `BarCalendarApp.swift` | `BarCalendarApp` (@main) and `@MainActor let sharedState` global |
| `AppDelegate.swift` | `AppDelegate` — status bar item + popover lifecycle |
| `SettingsWindowController.swift` | `SettingsWindowController` — singleton that manages the settings NSWindow |
| `Layout.swift` | `Layout` enum — all layout constants (popover size, cell size, spacing) |
| `CalendarState.swift` | `CalendarState` (@Observable @MainActor), `Notification.Name.checkCalendarAccess` |
| `CalendarDropdownView.swift` | `CalendarDropdownView` — root view of the popover |
| `CalendarGridView.swift` | `CalendarGridView` — month grid (LazyVGrid, 7 columns) |
| `DayCell.swift` | `DayCell` — single day cell with today highlight and event dot |
| `EventsSectionView.swift` | `EventsSectionView` — upcoming events grouped by day |
| `EventGroupView.swift` | `EventGroupView` + `EventRowView` — event list group and individual event row |
| `PermissionPromptView.swift` | `PermissionPromptView` — calendar access grant/settings prompt |
| `MonthHeaderView.swift` | `MonthHeaderView` — prev/next month buttons + month title |
| `WeekdayHeaderRow.swift` | `WeekdayHeaderRow` — Mo Tu We … row, respects startOfWeek |
| `SettingsView.swift` | `SettingsView` — Form with two Pickers |

## Architecture

- **Entry point:** `BarCalendarApp.swift` — `@main` app with `@NSApplicationDelegateAdaptor`. The SwiftUI `Settings` scene in the app body is declared but unused at runtime; settings open via `SettingsWindowController`.
- **Global state:** `@MainActor let sharedState = CalendarState()` defined at file scope in `BarCalendarApp.swift`. Passed into views as `@Bindable var state: CalendarState`. Never re-created, never injected via environment.
- **Popover:** Fixed size 280×400 (via `Layout` constants), `.transient` behavior (closes on focus loss). Created in `AppDelegate.applicationDidFinishLaunching`.
- **Settings window:** `SettingsWindowController.shared.show(_:)` creates an `NSWindow` wrapping `NSHostingController<SettingsView>`. Auto-sized via `fittingSize`. Singleton — re-uses window if already visible.
- **Views:** Each file = one primary struct. No NavigationStack. No sheets. Popover is self-contained; settings is a separate window.
- **Layout constants:** All magic numbers live in `Layout` enum in `Layout.swift`. Use these instead of hardcoded values.
- **Swift 6 concurrency:** Project uses `SWIFT_VERSION = 6.0` and `SWIFT_STRICT_CONCURRENCY = complete`. `CalendarState`, `AppDelegate`, and `SettingsWindowController` are explicitly annotated `@MainActor`. The global `sharedState` is also `@MainActor`. Do NOT rely on implicit isolation — always annotate explicitly.

## CalendarState API

```swift
// Stored properties
var displayedMonth: Date        // month currently shown in the grid
var events: [EKEvent]           // flat list covering displayedMonth + upcoming window
var hasCalendarAccess: Bool
var startOfWeek: Int            // 1 = Sunday, 2 = Monday
var eventsDaysToShow: Int       // 0–7; 0 = events section hidden

// Computed
var menuBarDateText: String     // current day number as String, e.g. "25"

// Methods
func requestCalendarAccess()    // async, sets hasCalendarAccess, calls fetchEvents on grant
func fetchEvents()              // re-fetches events for displayedMonth union upcoming window
func previousMonth()            // displayedMonth -= 1 month, then fetchEvents
func nextMonth()                // displayedMonth += 1 month, then fetchEvents
func eventsForDay(_ date: Date) -> [EKEvent]   // filter from cached events[]
func saveStartOfWeek(_ value: Int)             // sets + persists to UserDefaults
func saveEventsDaysToShow(_ value: Int)        // sets + persists + fetchEvents
```

UserDefaults keys: `"startOfWeek"`, `"eventsDaysToShow"`.

## Key Conventions

- State is `@Observable` (not `ObservableObject`). Use `@Bindable var state: CalendarState` in views. Do not use `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`.
- Calendar access uses `eventStore.requestFullAccessToEvents()` (iOS 17+ / macOS 14+ API). Do not use the deprecated `requestAccess(to:)`.
- Past events are struck through: `.strikethrough(isPast)` where `isPast = event.endDate < Date()`.
- Settings are always saved via `saveStartOfWeek(_:)` / `saveEventsDaysToShow(_:)` — never write UserDefaults directly from a view.
- `eventsForDay(_:)` filters the already-fetched `events` array — it does not hit EventKit. Keep it that way; do not add EKEventStore calls inside views.

## Gotchas

- **Popover size is hardcoded.** `NSPopover.contentSize` is set to 280×400 in `AppDelegate` and the hosting controller frame is set to match. If you add UI that changes the height, update both places. SwiftUI's auto-sizing does not apply here.
- **`SettingsWindowController` re-uses its window.** If `window.isVisible`, it just focuses it. Do not call `show(_:)` in a loop or expect a fresh window each time.
- **`startOfWeek` default logic.** `UserDefaults.integer(forKey:)` returns `0` when unset. The init treats `0` as "not set" and defaults to `2` (Monday). `1` is the only value that maps to Sunday. Any other saved value also falls back to Monday.
- **`eventsDaysToShow = 0` hides the events section entirely** — `EventsSectionView` renders "Events hidden" text instead of calling `eventsForDay`.
- **`checkCalendarAccess` notification** is used to re-trigger permission check from `PermissionPromptView` ("Check again" button) without a direct reference to state. Post via `NotificationCenter.default.post(name: .checkCalendarAccess, object: nil)`.
- **No `@State` in `DayCell`.** It receives `isToday` and `hasEvents` as plain `let` — computed by `CalendarGridView`. Keep it stateless.

## Entitlements

App Sandbox enabled. Calendar read access: `com.apple.security.personal-information.calendars`.
## Maintaining This File

Update AGENTS.md after every task, but only after all code changes are done and the build passes.

**What to update:**
- **File Map** — if you added, removed, renamed, or split a file, update the table and list every struct/class/enum inside it
- **CalendarState API** — if you added or removed a property or method, update the list
- **Gotchas** — if you hit a non-obvious problem during implementation, add it
- **Key Conventions** — if you introduced a pattern that should be followed everywhere, add it

**Rules:**
- Only describe what is actually in the code — do not infer build settings or flags you did not explicitly set yourself
- Do not add sections that describe intent — only facts verifiable by reading the source files
- Do not update AGENTS.md mid-task — wait until the build passes

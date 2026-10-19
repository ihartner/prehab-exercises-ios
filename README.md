# Prehab Exercises (iOS)

> The app's display name is **Work** (the home-screen label and the Home title). The repo,
> bundle id (`com.prehab.exercises`), and project names are unchanged.

SwiftUI port of the [Android Prehab Exercises app](https://github.com/ihartner/prehab-exercises) —
a voice-guided, timed pre-surgery exercise plan that progresses lying → sitting → standing,
with weekly and calendar progress tracking.

> **Note on how this was built:** this project was written entirely on Windows, without
> access to a Mac or Xcode. The Swift/SwiftUI source has never been compiled — you are the
> first build. If something doesn't compile, it's likely a small API/name mismatch that's
> quick to fix in Xcode (which gives much better Swift error messages than anything available
> without it).

## Requirements

- A Mac with **Xcode 15+** installed (SwiftUI features here target iOS 17+; Xcode always
  builds against whatever iOS SDK it ships with, so "latest iOS" just means using a
  reasonably current Xcode).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the `.xcodeproj` from
  `project.yml` (the actual Xcode project file isn't checked into git — regenerating it from
  a plain-text spec avoids hand-maintained/merge-conflict-prone `.pbxproj` files).

Install XcodeGen once via Homebrew:

```bash
brew install xcodegen
```

## Building

```bash
cd prehab-exercises-ios
xcodegen generate
open PrehabExercises.xcodeproj
```

Then in Xcode: pick an iPhone simulator (or your own device) from the scheme selector and
press Run (⌘R).

If you change `project.yml` (e.g. bump the deployment target, add a new source folder), rerun
`xcodegen generate` and reopen the project.

## Project structure

```
PrehabExercises/
  App/PrehabExercisesApp.swift     # @main entry point
  Model/Exercise.swift             # Exercise, ExercisePhase, ExerciseType
  Data/ExerciseRepository.swift    # the 15 exercises (mirrors the Android data)
  Voice/VoiceGuide.swift           # AVSpeechSynthesizer wrapper (speak / speakAndWait)
  Session/SessionViewModel.swift   # timer + voice sequencing, Swift concurrency (Task/async)
  Progress/
    ProgressStore.swift            # UserDefaults-backed completed-dates store
    WeekProgress.swift             # Sun-Sat weekly view + streak
    MonthProgress.swift            # full month calendar grid
  Reminder/
    ReminderSettings.swift         # enabled / daily-or-weekly / weekday / time
    ReminderType.swift             # exercise vs. breathing reminder (id, message, default schedule)
    ReminderManager.swift          # persists settings, schedules a repeating notification per type
  Breathing/
    BreathingExercise.swift        # the five techniques and their phase timings
    BreathingSessionViewModel.swift # guided session: 50ms tick loop, voice cues, pause/mute
  Navigation/AppRoute.swift        # NavigationStack route enum
  Views/
    HomeView.swift                 # exercise list, weekly progress card, hamburger menu
    SessionView.swift              # timed session screen with circular countdown
    CalendarView.swift             # month calendar with prev/next navigation
    SettingsView.swift             # reminder settings (switch, daily/weekly, day, time)
    BreathingListView.swift        # the five breathing techniques
    BreathingSessionView.swift     # animated breathing circle with voice cues
  Theme/Theme.swift                # beige background + blue/gray accents, light & dark
  Assets.xcassets/                 # exercise illustrations (blue-tintable template images),
                                    # app icon, accent color
```

## Design parity with the Android app

- Same 15 exercises, same phase order (lying → sitting → standing), same rep/hold/rest
  timings, same illustrations (reused directly from the Android app's asset pipeline as
  alpha-mask PNGs, tinted at render time so they adapt to light/dark mode).
- Same beige background with blue (primary) and neutral gray (secondary) accents.
- Same progress model: a "This week" card resets naturally every Sunday (it always computes
  from the current Sun-Sat range), full history is preserved and browsable via a hamburger
  menu → Calendar screen.
- Same reminders: hamburger menu → Settings → Exercise reminders, with a daily/weekly choice,
  a weekday picker for weekly, and a time picker. On iOS this is a single repeating
  `UNCalendarNotificationTrigger` (the system repeats it, so there's no alarm re-arming
  like on Android). The notification permission prompt appears when you first enable it.
  There's a second, independent **Breathing reminders** section with the same options (its own
  schedule and notification, defaulting to 8:00 PM); tapping that notification opens the
  Breathing section directly.
- Same Breathing section (hamburger menu → Breathing): Box Breathing, 4-7-8, Belly Breathing,
  Coherent Breathing (5-5), and the Physiological Sigh, each as an animated circle with spoken
  phase cues, pause/resume, and a voice mute toggle. It's separate from the prehab plan and
  doesn't count toward the weekly goal.
- Voice guidance uses `AVSpeechSynthesizer` (the iOS equivalent of Android's
  `TextToSpeech`) instead of a specific named voice — it speaks in whatever voice/language is
  set as the device default, matching how the Android app defers to the system's TTS voice.

## Known gaps / things to check on first build

Since this has never been opened in Xcode, keep an eye out for:
- Any SwiftUI API that needs a slightly newer/older iOS availability annotation than assumed.
- The `AVAudioSession` category setup in `VoiceGuide.swift` — background audio behavior may
  need tuning depending on how you want the app to behave when backgrounded mid-session.
- App icon is a simple placeholder (blue square, white cross) generated to match the Android
  launcher icon's style — swap it for real artwork whenever you like.

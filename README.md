# World Clock — Flutter App

A dark, true-black AMOLED-optimized multi-timezone clock with a swipeable
calendar, matching your original HTML design exactly (yellow BD label,
red USA label, green USA time, gray seconds, pure black background).

## Get the APK — no computer setup needed

This project includes a GitHub Actions workflow that builds the release
APK automatically in the cloud. Follow these steps on GitHub.com (works
fine from your phone's browser too):

1. **Create a free GitHub account** at github.com if you don't have one.

2. **Create a new repository.**
   - Click the "+" in the top right → "New repository"
   - Name it anything, e.g. `world-clock-app`
   - Leave it public or private, either works
   - Click "Create repository"

3. **Upload this whole folder.**
   - On the new repo's page, click "uploading an existing file"
   - Drag the entire `world_clock_app` folder (all of it — `lib/`,
     `.github/`, `pubspec.yaml`, everything) into the upload box.
     (If GitHub's web uploader won't accept a nested folder in your
     browser, unzip on your computer first and drag the contents in,
     keeping the same folder structure.)
   - Scroll down, click "Commit changes"

4. **Wait for the build.**
   - Click the "Actions" tab at the top of your repo
   - You'll see a run called "Build APK" — click it, then click the
     "build" job to watch it work. It takes about 5–8 minutes.
   - A green checkmark means it succeeded.

5. **Download the APK.**
   - On that same completed run's page, scroll down to "Artifacts"
   - Click "world-clock-apk" to download a zip
   - Unzip it — inside is `app-release.apk`

6. **Install it on your phone.**
   - Transfer `app-release.apk` to your Android phone (email it to
     yourself, use Google Drive, USB, whatever's easiest)
   - Tap the file on your phone
   - If prompted, allow "install unknown apps" for that app (Files,
     Chrome, Gmail — whichever you used to open it)
   - Tap Install, then Open

That's it — no Flutter, Android Studio, or command line needed on your
end. Every time you push a change to this repo, a fresh APK is built
automatically in the same place.

## What's in this project

- `lib/main.dart` — app entry point, ticking clock timer, layout
- `lib/models/world_clock.dart` — clock data model + your two default clocks
- `lib/services/clock_storage.dart` — saves your added clocks between launches
- `lib/widgets/clock_tile.dart` — renders one clock (colors match your CSS exactly)
- `lib/widgets/add_clock_sheet.dart` — the "+" sheet: name, timezone search, color, seconds toggle
- `lib/widgets/calendar_view.dart` — swipeable month calendar (red header, red "today" circle)
- `.github/workflows/build-apk.yml` — the automation that builds your APK in the cloud
- `android_manifest_snippet/` — reference only; the workflow applies this automatically, you don't need to touch it

## Features delivered

- **Exact UI match**: hex colors taken straight from your CSS
  (`#FFD60A`, `#FF453A`, `#30D158`, `#8E8E93`, `#000000`)
- **Multi-clock + custom names**: tap "+" to add any name with any of
  ~400 IANA timezones; persists across app restarts
- **Swipeable calendar**: swipe left/right (or tap the arrows) to move
  a month at a time
- **Battery/performance**: one shared timer ticks once a second into a
  `ValueNotifier`; each clock's digits repaint independently — the
  calendar, list structure, and buttons never rebuild from the clock
  tick. True black background minimizes lit pixels on AMOLED screens.

## If you'd rather build it yourself locally

You can also do this the traditional way with Flutter installed on
your own machine — run `flutter create .` in an empty folder, copy
`lib/` and `pubspec.yaml` from here over the generated ones, then
`flutter pub get` and `flutter build apk --release`. The APK will be at
`build/app/outputs/flutter-apk/app-release.apk`. The GitHub Actions
route above does exactly this for you automatically, so it's the
easier path if you don't already have Flutter installed.

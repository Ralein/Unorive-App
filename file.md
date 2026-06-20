# Unorive — "You Know When to Arrive"
### Full Build Plan, Master Prompt & Phased Prompts for Antigravity

---

## 1. App Vision

**Unorive** is a geo-based travel companion that replaces the time-based alarm with a *location-based* one. Instead of guessing when you'll arrive, you drop a pin, set a radius, and Unorive wakes you, alerts you, or notifies you the moment you're physically close — whether you're dozing on a night bus, absorbed in work during a train commute, or road-tripping with friends.

**Tagline:** *You know when to arrive.*

**Differentiators to build toward:**
- A genuinely **3D, cinematic map experience** (not a flat Google Maps clone) — tilted camera, extruded buildings, terrain, smooth fly-to animations.
- **Bulletproof background alarm reliability** — the single feature the whole product lives or dies on.
- A **modern, tactile UI** — glassmorphic overlays on the map, fluid motion, haptics, dark-mode-first.

**Platforms:** Android (Play Store) + iOS (App Store), built once in Flutter.

---

## 2. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | **Flutter** (latest stable) | Single codebase, both stores |
| State management | **Riverpod** (+ `riverpod_generator`) | Testable, reactive, scales well with background services |
| Routing | **go_router** | Deep-linking from notifications straight into the alarm screen |
| 3D Map | **Mapbox Maps SDK for Flutter** (`mapbox_maps_flutter`) | True 3D buildings, terrain, the "Standard" style with day/night lighting and atmosphere/globe — Google Maps Flutter's 3D support is far more limited |
| Places search / geocoding | **Mapbox Search Box API** (or Google Places API as fallback) | Autocomplete destination search |
| Routing/ETA | **Mapbox Directions API** | Polyline + ETA along a route |
| Location | **geolocator** | Position streams, distance calculations |
| Background execution | **flutter_background_service** + native foreground service (Android) / background modes (iOS) | Keeps tracking alive while minimized |
| Alarm playback | **alarm** package (gdelataillade) + **flutter_local_notifications** | Full-volume playback bypassing silent/DND, fires even if app was killed |
| Haptics | **vibration** | Alarm + interaction feedback |
| Local storage | **Hive** | Saved places, trip history, alarm configs |
| Cloud backend | **Firebase** — Auth, Firestore, Cloud Functions, Crashlytics, Analytics, Cloud Messaging | Account sync, crash visibility, push for non-alarm notices |
| Permissions | **permission_handler** | Background location, notifications, exact alarms |
| Motion/animation | **flutter_animate**, **Lottie**, optionally **Rive** for the alarm pulse | Modern, "alive" feel |
| Typography | **google_fonts** (e.g. Manrope / Inter / Space Grotesk for headlines) | Modern type system |
| Icons & splash | **flutter_launcher_icons**, **flutter_native_splash** | Store-ready branding |
| Testing | `flutter_test`, `mocktail`, integration_test | Geofence math, trip state machine, full-trip simulation |

**Accounts/keys you'll need before Phase 0:**
- Mapbox account + access token (public + a downloads token for the SDK)
- Firebase project (iOS + Android apps registered, `flutterfire configure`)
- Apple Developer Program membership ($99/yr)
- Google Play Console account ($25 one-time)
- A hosted privacy policy URL (required by both stores — set this up early since Phase 11 needs it, and Android's background location form needs it too)
- Quick trademark/App-Store-name-availability check for "Unorive" before you invest in branding

---

## 3. How to Use This Document With Antigravity

Antigravity works best when you treat it as a sequence of well-scoped, reviewable tasks rather than one giant ask. Suggested workflow:

1. Create an empty git repo, open it in Antigravity, make an initial empty commit (so you always have a clean revert point).
2. Paste the **Master Prompt** (Section 4) as your first task in the Manager Surface. This gives every subsequent agent the full product context, architecture, and non-negotiables — Antigravity will use it to scaffold the project in Phase 0.
3. Run the **Phase prompts** (Section 5) one at a time, in order, as separate tasks. Don't start Phase *N+1* until Phase *N*'s Walkthrough is reviewed and the Definition of Done is actually met — Phases 4, 5, and 6 in particular form a reliability chain, and a shaky foundation there will quietly break the alarm later.
4. After each phase: read the Walkthrough artifact, spot-check the screenshots/code, then **commit** before moving on. If a phase comes back wrong, re-prompt narrowly on the gap rather than re-running the whole phase.
5. Use the agent's browser automation to verify web-testable UI flows, but plan to **manually test on a real device** for anything background/OS-level (Doze mode, app-kill survival, lock screen alarms) — that's outside what in-IDE browser automation can validate.
6. Keep the Master Prompt handy to paste back in if a later agent loses context on conventions (e.g., if you start a fresh Manager Surface session).

---

## 4. Master Prompt

Copy everything in the box below as your first Antigravity task.

```
You are building UNORIVE, a production-grade, cross-platform Flutter mobile
app (Android + iOS) for the Play Store and App Store. Tagline: "You know when
to arrive." Read this entire brief before writing any code — it is the
contract for the whole project, and every later task will refer back to it.

PRODUCT SUMMARY
Unorive lets a traveler set an alarm tied to a LOCATION instead of a time.
The user picks a destination on a 3D map, sets an alert radius, and starts a
trip. The app tracks live location (including in the background, even if the
app is killed by the OS) and fires a full-volume, lock-screen alarm the
moment the user enters that radius. Primary users: commuters who might fall
asleep, long-distance bus/train travelers, road-trippers, and anyone running
errands along a route who doesn't want to babysit a map.

NON-NEGOTIABLES (these override convenience or shortcuts every time)
1. The alarm MUST fire reliably even if the user has swiped the app away
   from recent apps, the phone is locked, or it's in silent/DND mode — just
   like a native alarm clock app. This is the core value proposition; treat
   any compromise here as a P0 bug, not a nice-to-have.
2. Background location must degrade gracefully across aggressive OEM battery
   managers (Samsung, Xiaomi/MIUI, OnePlus, etc.) and iOS background
   throttling. Always prefer a documented workaround over silently failing.
3. Every screen that requests a sensitive permission (location, background
   location, notifications) must show a clear, plain-language "priming"
   explanation BEFORE the native OS permission dialog appears. This is both
   good UX and a hard requirement for Play Store's background location
   policy later.
4. No screen should ever show a raw exception, a blank white screen, or a
   silently-stuck loading spinner. Always have an empty/error/loading state.
5. All location/trip data must work fully offline and sync to the cloud
   opportunistically — never block core functionality on network access.

TECH STACK (use exactly this unless a later task explicitly changes it)
- Flutter (latest stable), Dart, null-safe, strict lints (treat warnings as
  errors in CI).
- State management: Riverpod with riverpod_generator (code-gen providers,
  not raw StateProvider sprawl).
- Routing: go_router, with route guards for auth/onboarding state, and deep
  link support so a tapped notification can open directly to the alarm
  screen even from a cold start.
- Map: mapbox_maps_flutter using the Mapbox "Standard" style (3D buildings,
  terrain, atmosphere, day/night lighting). Do not substitute a flat 2D map
  package — 3D is a core product requirement, not decoration.
- Places autocomplete: Mapbox Search Box API.
- Directions/ETA: Mapbox Directions API.
- Location: geolocator for position streams and distance math.
- Background execution: flutter_background_service, wired to a real Android
  foreground service (persistent notification, ACCESS_BACKGROUND_LOCATION)
  and iOS background location mode (UIBackgroundModes: location, "Always"
  authorization).
- Alarm playback: the `alarm` package for guaranteed full-volume,
  silent-mode-bypassing playback, paired with flutter_local_notifications
  for the alert UI and full-screen intent on Android.
- Local persistence: Hive for saved places, trip history, alarm configs.
- Cloud: Firebase (Auth — Google/Apple/anonymous, Firestore, Cloud
  Functions if needed, Crashlytics, Analytics).
- Permissions: permission_handler.
- Motion: flutter_animate for transitions/micro-interactions, Lottie for
  onboarding/empty-state illustrations.
- Typography: google_fonts — pick one geometric sans for display text (e.g.
  Space Grotesk) and one humanist sans for body text (e.g. Inter), and
  commit to it in the design system, don't mix further fonts later.

ARCHITECTURE & FOLDER STRUCTURE
Use a feature-first structure:

lib/
  main.dart
  app/
    app.dart                 (MaterialApp.router setup, theming)
    router.dart               (go_router config)
  core/
    theme/                    (colors, typography, spacing tokens)
    constants/
    services/
      location_service.dart
      geofence_service.dart
      alarm_service.dart
      notification_service.dart
      background_service.dart
    widgets/                  (shared design-system widgets)
    utils/
  data/
    models/                   (Trip, SavedPlace, AlarmConfig, UserProfile)
    repositories/
    local/                    (Hive boxes/adapters)
    remote/                   (Firestore data sources)
  features/
    onboarding/
    auth/
    home_map/
    trip_tracking/
    alarm_screen/
    saved_places/
    history/
    settings/
  l10n/ (even if English-only at launch, structure for future i18n)

DESIGN DIRECTION
Dark-mode-first (light mode supported, but design dark first). A confident,
saturated accent color against a near-black map-forward background —
something that reads "travel at night" rather than "generic productivity
app." Use glassmorphic translucent cards/sheets that float over the map
rather than opaque full-screen panels, so the map is always the hero. Big,
confident typography for distance/ETA numbers. Generous corner radii,
soft shadows, no harsh borders. The alarm screen is the emotional climax of
the app — it should feel urgent but not stressful: a slow pulsing gradient,
large unmissable buttons, no clutter.

CODING CONVENTIONS
- Every public service/repository has an abstract interface + concrete
  implementation, so it's mockable in tests.
- No business logic in widgets — widgets read Riverpod providers and call
  notifier methods only.
- Write a docstring on every public class/method explaining intent, not
  just signature.
- Commit in small, reviewable units; don't bundle unrelated changes.

DELIVERABLE FOR THIS TASK (Phase 0 scope)
1. Scaffold the Flutter project named `unorive` with the folder structure
   above.
2. Add all dependencies listed to pubspec.yaml with current stable
   versions.
3. Set up flutter_dotenv (or --dart-define, your call, but document which)
   for Mapbox token and Firebase config so secrets never get committed.
4. Wire up Firebase via flutterfire (placeholder config is fine if I
   haven't created the Firebase project yet — note clearly in README what
   I still need to fill in).
5. Set up the base theme (light + dark) using the design direction above,
   even if specific colors are still placeholders — establish the token
   structure, not just hardcoded values.
6. Set up go_router with a minimal route table: splash -> onboarding ->
   home (all placeholder screens for now).
7. Add a strict analysis_options.yaml (very_good_analysis or equivalent).
8. Write a README covering: setup steps, required API keys/accounts, how
   to run, and how to run tests.
9. Confirm the app builds and runs on both an Android emulator and iOS
   simulator showing a blank themed splash/home placeholder.

Do not build any map, location, or alarm functionality yet — that's later
phases. This task is foundation only. When done, produce your Walkthrough
so I can verify the structure before we continue.
```

---

## 5. Build Phases

Each phase below is a standalone prompt — paste it into a new Antigravity task once the previous phase is committed. They assume the Master Prompt has already been run (Phase 0).

### Phase 1 — Design System & Core UI Shell

**Goal:** Turn the placeholder theme into a real, reusable design system before any feature screens get built on top of it.

```
Building on the existing Unorive scaffold and the design direction from the
master brief, build out the design system:

1. Finalize a dark-first color palette (background, surface, surface-glass,
   primary accent, secondary accent, success/warning/error, text
   hierarchy) as Dart constants/ThemeExtension, plus the matching light
   theme.
2. Set up the typography scale (display/headline/title/body/label) using
   Space Grotesk for display/headline and Inter for body/label via
   google_fonts.
3. Define a spacing/radius/elevation scale and use it consistently (no
   magic numbers in widget code).
4. Build the following reusable widgets in core/widgets:
   - GlassCard (translucent blurred container for floating over the map)
   - PrimaryButton / SecondaryButton (with press animation + haptic)
   - BottomSheetScaffold (draggable sheet shell used by trip tracking,
     saved places, etc.)
   - StatusPill (small colored badge, e.g. "Active trip", "Arrived")
   - EmptyStateView (illustration + message + optional CTA, reusable
     across saved places/history)
5. Build a temporary internal "design catalogue" screen (debug-only route)
   that displays every token and widget so I can visually QA the system
   in one place.
6. Implement the splash screen with a simple animated logo treatment
   (placeholder logo is fine — use the app name in the display font with a
   subtle motion/fade, structured so a real logo asset can drop in later).

Definition of done: design catalogue screen renders cleanly in both light
and dark mode, all widgets pass basic widget tests, no hardcoded colors or
font sizes exist outside the theme files.
```

### Phase 2 — Onboarding & Auth

**Goal:** First-run experience plus account system, including permission priming screens (required later for Play Store compliance).

```
Build onboarding and authentication on top of the design system:

1. 3-4 swipeable onboarding screens explaining the value proposition (set
   a destination, get woken up when you arrive) using Lottie placeholder
   illustrations — structure the widget so real Lottie files can be
   dropped in later.
2. A "permission priming" screen pattern: a plain-language explanation
   screen that appears BEFORE any native OS permission dialog is
   triggered, for both location and notifications. Make this a reusable
   flow, not a one-off, since it'll be reused when we request background
   location specifically in a later phase. The copy must clearly mention
   "location" and that it's used in the background to trigger alarms —
   this exact phrasing requirement comes from Play Store policy we'll
   need to satisfy in the submission phase, so bake it in now.
3. Firebase Auth integration: Google Sign-In, Apple Sign-In (required if
   you offer Google on iOS), and anonymous/guest mode so users can try the
   app before creating an account. Allow upgrading from anonymous to a
   real account later without losing local data.
4. Route guarding via go_router redirects: unauthenticated/first-run users
   go to onboarding, returning users skip straight to home.
5. Persist "has completed onboarding" and auth state across app restarts.

Definition of done: fresh install shows onboarding exactly once, guest
mode works without any account, Google/Apple sign-in completes and
persists, and reopening the app after auth goes straight to home.
```

### Phase 3 — 3D Interactive Map Core

**Goal:** The map is the soul of this app — get the "wow" 3D experience right before wiring real tracking logic to it.

```
Implement the home map screen — this is the most important visual moment
in the app, so take care with the motion design:

1. Integrate mapbox_maps_flutter with the Mapbox "Standard" style (3D
   buildings, terrain, atmosphere/lighting). Wire the Mapbox access token
   from the env setup in Phase 0.
2. On first load, animate the camera from a globe/zoomed-out view down to
   the user's current location with a smooth fly-to + pitch-tilt
   transition (globe -> tilted 3D street-level), not an instant cut.
3. Show a live location "puck" with smooth position interpolation (no
   jumpy snapping between updates).
4. Add a floating glass search bar (using GlassCard) overlaying the top of
   the map, wired to the Mapbox Search Box API for destination
   autocomplete.
5. Support long-press-to-drop-a-pin as an alternative to search.
6. When a destination is selected, animate the camera to frame both the
   user's location and the destination, and draw the route polyline via
   the Mapbox Directions API.
7. Add a floating "Start Trip" primary button that appears once a
   destination is chosen (no trip logic yet — just the UI affordance and
   navigation to a placeholder trip screen).
8. Implement pinch/rotate/tilt gesture controls so the user can freely
   explore the 3D map.

Definition of done: 3D buildings and terrain visibly render on a real
device, the intro fly-to animation runs smoothly at a stable frame rate,
search returns results and recenters the map, long-press drops a pin, and
a route polyline draws between two points.
```

### Phase 4 — Live Location Tracking & Trip Engine

**Goal:** Real position tracking and a trip state machine — this is where background reliability work begins.

```
Implement the trip tracking engine:

1. Build LocationService wrapping geolocator position streams, with
   adaptive polling: check every 30-60s when far from the destination,
   tightening to every 5-10s once within 1km (configurable thresholds).
2. Build a TripNotifier (Riverpod) state machine with states: idle,
   active, arrived, cancelled. Starting a trip persists the active trip
   to Hive immediately so it can survive an app restart.
3. Calculate live remaining distance and ETA (using Directions API data,
   falling back to straight-line distance if offline).
4. Build the trip tracking bottom sheet UI: remaining distance, ETA, a
   progress indicator along the route, and a "Cancel Trip" action.
5. Wire flutter_background_service so location tracking continues when
   the app is backgrounded:
   - Android: real foreground service with a persistent, low-priority
     notification showing "Tracking trip to [destination] — Xkm left."
     Request ACCESS_BACKGROUND_LOCATION properly (priming screen from
     Phase 2 must run first).
   - iOS: request "Always" location authorization, enable the `location`
     background mode in Info.plist, and handle iOS's more aggressive
     throttling by relying on significant-location-change updates as a
     supplement when standard updates are paused.
6. Add a "Background Reliability" debug screen (debug builds only)
   showing last-known location, last update timestamp, and current
   service status, to make manual QA easier in later phases.

Definition of done: start a trip, background the app, and walk/drive for
10+ minutes — the foreground notification keeps updating with live
distance, and the debug screen confirms location updates kept arriving
the whole time, on a real device (not just the emulator/simulator).
```

### Phase 5 — Geofencing & Alarm Trigger Engine

**Goal:** The actual "alarm fires when I arrive" logic — the hardest and most important phase. Don't proceed past this one until it's genuinely solid.

```
Implement the geofencing and alarm trigger pipeline on top of the trip
engine from Phase 4:

1. Build GeofenceService: continuously compares current location against
   the trip's destination + user-configured radius (slider range
   100m-5km, sensible default based on travel mode if known, otherwise
   800m).
2. Add hysteresis/debounce logic so a single noisy GPS reading near the
   radius boundary can't cause a false trigger or a flicker of
   re-triggers.
3. Implement redundant triggering: the live foreground location stream is
   the primary trigger, but also schedule a periodic background
   evaluation (e.g. via WorkManager on Android / BGTaskScheduler on iOS,
   whatever the alarm/background_service packages expose) as a backup in
   case the stream gets suspended by the OS.
4. When the geofence condition is met, the trigger must work even if the
   app process was fully killed: use the `alarm` package to schedule/fire
   a guaranteed full-volume alarm, independent of whether the Dart VM is
   still running.
5. On trigger, fire a high-priority notification with a full-screen
   intent (Android) that deep-links directly into the alarm screen route
   (built in the next phase) even from a cold start, and update the
   trip's state to "arrived" once acknowledged.
6. Write unit tests for the geofence math (distance calculation, radius
   boundary behavior, debounce logic) independent of any platform
   service, so the core logic is verifiable without a device.
7. Document, in the README, a manual test matrix to run on real devices:
   kill app from recent apps + arrive in radius; lock screen + arrive in
   radius; airplane-mode-then-reconnect near radius; test on at least one
   aggressive battery-management OEM device if you have access (Samsung/
   Xiaomi/OnePlus) plus iOS.

Definition of done: unit tests for geofence math pass; on a real Android
and a real iOS device, killing the app mid-trip and then physically
entering the radius still fires the alarm. This must work, not just
"usually work" — treat any flakiness here as the top priority bug before
continuing to Phase 6.
```

### Phase 6 — Full-Screen Alarm Experience

**Goal:** The moment the user actually experiences — make it unmissable and make it feel good, not jarring.

```
Build the alarm screen and playback experience triggered by Phase 5:

1. Full-screen alarm UI that can show over the lock screen where the
   platform allows it, using the design system's pulsing-gradient motion
   treatment described in the master brief — urgent but not anxiety-
   inducing.
2. Looping alarm sound at full volume that overrides silent mode and DND,
   the same way a native clock alarm behaves, via the `alarm` package.
3. Vibration pattern via the `vibration` package, synced with the
   visual pulse.
4. Two large, unmistakable actions: "Dismiss" (stops everything, marks
   trip as completed/arrived) and "Snooze" (re-arms the geofence with a
   shrunk radius and/or schedules a short additional check, your call on
   the exact mechanic — document whichever you choose).
5. Accessibility: large tap targets (min 56dp), screen-reader labels on
   both buttons, sufficient color contrast even with the animated
   background.
6. Make sure the alarm screen is reachable via deep link from a cold app
   start (tapping the notification when the app wasn't running at all).
7. After dismiss, route the user to a small "trip summary" moment
   (distance traveled, time taken) before returning to home — a nice
   emotional close rather than an abrupt cut back to the map.

Definition of done: alarm fires and is dismissable/snoozable correctly
from three states — app in foreground, app backgrounded, and app fully
killed — on both platforms, with audio audibly overriding silent mode in
your manual test.
```

### Phase 7 — Saved Places, Trip History & Cloud Sync

**Goal:** Make the app useful beyond a single trip.

```
Build persistence and sync features:

1. Saved Places: CRUD for favorite destinations (Home, Work, custom) with
   an icon picker, stored in Hive locally and synced to Firestore when
   signed in (guest/anonymous users stay local-only with a prompt to sign
   in to enable sync).
2. Trip History: a list screen of past trips showing a small static map
   thumbnail, destination name, date, duration, and completion status
   (arrived vs. cancelled). Support swipe-to-delete.
3. Offline-first sync: all writes go to Hive first and are instantly
   reflected in the UI; Firestore sync happens opportunistically in the
   background and resolves conflicts last-write-wins (note this
   explicitly in code comments since it's a deliberate simplification).
4. Tapping a saved place from the home screen should pre-fill it as the
   destination and jump straight into the trip-start flow from Phase 3/4.
5. Empty states for both screens using the EmptyStateView widget from
   Phase 1 (e.g. "No saved places yet — add your first one").

Definition of done: saved places and trip history both persist across an
app reinstall when signed in, both work fully offline with local-only
data when signed out or disconnected, and sync correctly once back
online/signed in.
```

### Phase 8 — Settings & Permission Management Center

**Goal:** Give users (and you, during support requests) visibility into and control over the reliability-critical settings.

```
Build the settings screen:

1. Alarm sound picker, default alert radius, distance units (km/mi),
   theme toggle (light/dark/system).
2. A "Permission & Reliability" section that actively checks and surfaces
   current status of: location permission level (while-using vs. always),
   notification permission, and (Android) whether battery optimization is
   disabled for the app. For any that aren't correctly configured, show a
   clear inline fix-it card with a one-tap deep link into the relevant OS
   settings screen.
3. Account section: show signed-in identity, sign out, and a delete-
   account flow that actually removes the user's Firestore data (not just
   signs them out) — note clearly in code/comments that this satisfies
   basic data-deletion expectations relevant to store privacy
   requirements.
4. About section with app version, privacy policy link, and terms link
   (placeholder URLs are fine for now, but structure it to be filled in
   before submission).

Definition of done: toggling a setting takes effect immediately elsewhere
in the app (e.g. changing units updates the trip tracking sheet), and the
permission status cards accurately reflect real device state, verified by
manually revoking a permission in OS settings and confirming the app
detects it.
```

### Phase 9 — Motion, Micro-interactions & Polish Pass

**Goal:** Take the functionally-complete app and make it feel premium.

```
Do a full polish pass across the entire app:

1. Add flutter_animate transitions between major navigation events
   (route changes, bottom sheet open/close, card list insert/remove).
2. Add shared-element/hero-style continuity between the home map, the
   trip tracking sheet, and the alarm screen so the experience feels like
   one continuous flow rather than disconnected screens.
3. Add shimmer/skeleton loading states anywhere data is fetched (trip
   history, saved places, search results).
4. Replace any remaining placeholder Lottie/illustration assets with
   final ones (use simple, on-brand placeholder animations if final
   brand assets aren't ready yet — just make sure nothing shows a broken
   asset or default icon).
5. Add haptic feedback on key interactions: starting a trip, dropping a
   pin, dismissing/snoozing the alarm, completing a save.
6. Sweep the app for any raw error text, unhandled exceptions, or stuck
   spinners and replace with the EmptyStateView/error patterns.
7. Generate and wire real app icons (adaptive icon for Android, all
   required sizes for iOS) and a native splash screen via
   flutter_launcher_icons / flutter_native_splash.

Definition of done: navigating the entire app start-to-finish feels
smooth with no visual pop-in or dead states, and the app icon/splash
appear correctly on both a fresh Android and iOS install.
```

### Phase 10 — Testing, QA & Reliability Hardening

**Goal:** Confidence before you ship, with a paper trail.

```
Harden and verify the app before submission prep:

1. Add widget tests for the core screens (home map controls, trip
   tracking sheet, alarm screen actions, settings toggles).
2. Add unit tests for: geofence distance/debounce math, trip state
   machine transitions, ETA calculation.
3. Add an integration test that simulates a full trip using a mocked
   location stream — start trip, simulate movement into the radius,
   assert the alarm trigger fires — so this critical path is covered by
   an automated test, not just manual QA.
4. Wire Firebase Crashlytics and confirm a test crash actually appears in
   the console.
5. Run a frame-timing check on the map screen via Flutter DevTools during
   the fly-to animation and note results in the README; address any
   janky frames.
6. Run a basic accessibility audit (screen reader pass on the main flow,
   contrast check on the alarm screen).
7. Write up the manual device test matrix as an actual checklist file in
   the repo (devices tested, OS versions, pass/fail per scenario from
   Phase 5/6), and run through it at least once on real hardware before
   moving to Phase 11.

Definition of done: automated test suite passes locally, Crashlytics is
confirmed working, and the manual test matrix document exists with at
least one full real-device pass recorded.
```

### Phase 11 — Store Readiness & Submission Prep

**Goal:** Get from "working app" to "submitted app," including the parts that are easy to miss.

```
Prepare Unorive for store submission:

1. Generate all required icon sizes and screenshot dimensions for both
   Play Store and App Store listing pages; place them in a /store-assets
   folder.
2. Draft store listing copy: app title, short description, full
   description, and keywords for both stores. Make sure the description
   explicitly and clearly mentions that the app uses location in the
   background to trigger arrival alarms — this exact disclosure is
   required for Play Store's background location policy, not just good
   practice.
3. Finalize the privacy policy and terms pages (these need to be hosted
   at a real URL before submission — flag clearly if I still need to
   provide that URL).
4. Prepare for Google Play's Permissions Declaration Form (required
   because the app uses ACCESS_BACKGROUND_LOCATION):
   - Write the "app purpose" justification text explaining why
     background location is core to the app's function.
   - Confirm the in-app "prominent disclosure" screen from Phase 2 says,
     verbatim, something containing the words "location" and "background"
     (or "when the app is closed" / "always in use") and names the
     specific feature it enables, since Play Console checks for this
     exact phrasing pattern.
   - Write a script for the required short demo video (Google requires
     one when declaring background location) that shows, in order: the
     prominent disclosure screen, the native OS permission prompt, and
     the background feature actually activating (e.g. the alarm firing
     after backgrounding the app). I'll record the video myself, but
     prepare the exact shot list/script.
5. Prepare Apple's side: write App Review notes explaining the "Always"
   location usage clearly (relevant to Guideline 5.1.1), and fill out the
   App Privacy "nutrition label" mapping (what data is collected, linked
   to identity, used for tracking — should be none for tracking/ads given
   this app's model).
6. Set up proper versioning (semantic version + build number) and confirm
   `flutter build appbundle` (Android) and `flutter build ipa` (iOS) both
   complete cleanly in release mode.
7. Optional but recommended: set up fastlane lanes for build + upload to
   reduce manual release friction for future updates.
8. Produce a final pre-submission checklist file in the repo covering all
   of the above so nothing gets missed on submission day.

Definition of done: both release builds complete successfully, all store
assets and copy exist in the repo, the privacy policy is hosted and
linked, and the pre-submission checklist is fully ticked.
```

---

## 6. Store Submission — Things to Know Before You Get There

A few details worth knowing now rather than discovering during review:

- **Play Store background location is a manual review, not just a checkbox.** Once your app's manifest declares `ACCESS_BACKGROUND_LOCATION`, Google requires a **Permissions Declaration Form** with a written justification *and* a short video proving the feature. The video must show: the in-app prominent disclosure, the native OS permission prompt, and the background feature actually working. Build the disclosure screen (Phase 2) and the manual test matrix (Phase 10) with this in mind — you'll reuse both directly.
- **Apple reviews "Always" location usage strictly** under App Review Guideline 5.1.1 — your `NSLocationAlwaysAndWhenInUseUsageDescription` string and App Review notes need to make the core use case unmistakable, or expect a rejection-and-resubmit cycle.
- Both stores want a real, hosted **privacy policy URL** — set this up well before Phase 11 so it's not a last-minute blocker.
- Budget real calendar time for store review cycles, especially the first submission with background location — it's common to need at least one resubmission round.

---

## 7. After Launch (Not in Scope Above, but Worth Planning For)

Keep these out of the MVP phases above, but worth a short note for your own roadmap:
- Multiple simultaneous trips / waypoints along one trip
- Sharing live trip/ETA with another person
- Apple Watch / Wear OS companion for the alarm
- Widget for quick-start of a saved place
- Monetization model (if any) — e.g. a free tier with ads-free single-trip use and a paid tier for unlimited saved places/history
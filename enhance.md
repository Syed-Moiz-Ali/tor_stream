# tor_stream — Android Full-Fledged Feature Build Plan (Claude Code Prompts)

Android-only scope. No monetization in this doc. Paste chunks one at a time into
Claude Code, each as its own session, against the existing `lib/`, `rust/`,
`android/` folders in the tor_stream repo. Reference the existing architecture.md
and Hive/session-restore design already in the repo — this doc extends it with
the reliability and UX layer that makes it feel like a real product.

---

## CHUNK R1 — Foreground service for persistent downloads (do this first, it's foundational)

```
Implement a proper Android foreground service so torrent downloads survive
backgrounding, screen-off, and app-switching. This is the single most important
reliability feature — Android's Doze mode and background execution limits will
kill a naive background download within minutes otherwise.

1. Create android/app/src/main/kotlin/.../TorrentForegroundService.kt:
   - Extends Service, uses startForeground() with a persistent notification
     (ONGOING_EVENT_NOTIFICATION, not dismissible while active).
   - Notification shows: active torrent name, download speed, progress %,
     a "Pause All" action button, tapping the notification opens the app to
     the relevant screen (use PendingIntent with deep link).
   - Foreground service type: use `dataSync` or `mediaPlayback` per Android 14+
     foreground service type requirements — check current Android docs for
     which type applies, since this is enforced strictly on recent API levels
     and using the wrong type gets the app rejected or crashes at runtime.
   - Service holds a reference to the Rust daemon connection (via
     flutter_rust_bridge) and stays alive as long as at least one torrent has
     `wasActive: true` in Hive (per the existing session-restore design) or an
     active user-initiated download.

2. Wire Flutter side: a Riverpod provider that starts/stops the foreground
   service via a MethodChannel or platform plugin, triggered when the user
   adds a torrent (start) and when all torrents are paused/removed (stop).

3. Handle Android's battery optimization exemption prompt: on first download,
   show an in-app explainer dialog ("For downloads to continue reliably,
   allow this app to run in the background") before triggering the system's
   "Ignore battery optimizations" permission request — don't request it
   silently, users deny unexplained permission prompts far more often.

4. Test explicitly: start a download, lock the screen for 5+ minutes, unlock,
   confirm download progressed. Kill the app via recent-apps swipe, confirm
   the foreground service notification persists and download continues
   (Android should NOT kill a proper foreground service on swipe-away, only
   on explicit force-stop).

Deliverable: a torrent added via the UI continues downloading with screen off
and app backgrounded, visible in a persistent notification with live progress.
```

---

## CHUNK R2 — Resilience: reconnect, retry, and resume logic

```
Harden the engine/daemon connection and torrent session against real-world
network conditions.

1. Network transition handling: detect WiFi<->mobile data switches (use
   connectivity_plus or Android's ConnectivityManager callbacks) and ensure
   the Rust engine's active sessions don't need a full re-add — librqbit
   should handle re-establishing peer connections, but verify this explicitly
   and add a fallback "re-resolve DHT" path if a session goes fully dead
   after a network change.

2. Daemon crash recovery: if the FFI-linked Rust daemon panics or the process
   dies (mobile mode per architecture.md's in-process model), Flutter must
   detect this (heartbeat/health-check on a timer) and cleanly restart the
   engine, then replay wasActive magnets from Hive (existing session-restore
   flow) — don't leave the user with a dead UI and no error message.

3. Torrent-level stall detection: if a torrent has zero peers and zero
   download progress for a configurable timeout (default 60s), surface a
   clear state to the UI ("No peers found — this torrent may be dead") rather
   than an infinite spinner. Implement automatic periodic re-announce to
   trackers/DHT in this state (don't just give up silently).

4. Reboot resume: on device reboot, if there were active downloads, use
   WorkManager (via workmanager Flutter plugin or native) to optionally
   relaunch the app/service per user setting ("Resume downloads after
   reboot" toggle in settings, off by default — respect that some users don't
   want the app auto-starting).

Deliverable: kill WiFi mid-download and switch to mobile data — download
continues or clearly reports why it can't. Force-kill the Rust process (adb
shell or a debug "crash daemon" button) — app detects it, restarts cleanly,
resumes the same torrents without user re-adding magnets.
```

---

## CHUNK R3 — Storage management

```
Implement real storage management — this is a top complaint category in every
torrent app's reviews if missing.

1. Settings screen: configurable max total storage (slider/input, e.g.
   default 5GB cap), configurable download location (internal vs SD card if
   present — use Android's Storage Access Framework for SD card writes on
   API 30+, don't assume raw file path access works).

2. Per-torrent storage view: show disk space used per torrent in the library
   screen, with a clear "Delete files" action separate from "Remove from
   library" (removing metadata shouldn't silently also nuke downloaded files
   without explicit confirmation, and vice versa).

3. LRU auto-eviction: when total storage approaches the configured cap,
   surface a notification/in-app prompt offering to delete the least-recently-
   watched completed downloads — never auto-delete without confirmation for
   anything not explicitly marked "auto-delete after watching" by the user.

4. "Delete after watching" per-torrent toggle: when watch_history marks a
   file `completed: true` and this flag is set, delete the underlying file
   automatically (keep the watch_history/metadata entry so it still shows in
   "history" but marked as removed-from-disk).

5. Global storage usage screen: total used, breakdown by torrent, one-tap
   "Clear all completed downloads."

Deliverable: settings screen with storage cap + location config; library
screen showing per-item disk usage; auto-delete-after-watching works end to end.
```

---

## CHUNK R4 — Streaming quality/UX signals before commit

```
Before a user taps play, give them enough info to not waste bandwidth on a
bad pick.

1. On adding a magnet and resolving file list, surface per-file: size,
   inferred resolution/quality from filename (parse patterns like 1080p,
   720p, 4K, HEVC/x265, WEB-DL, BluRay — reuse the existing filename_parser
   logic from the metadata module, extend it to extract quality tags not
   just title/year).

2. Seed/peer health indicator on the file list before playing: show peer
   count and estimated time-to-first-playable-buffer based on current swarm
   speed, so the user can bail before starting a stream that'll stall.

3. In the player, a live buffer-health indicator (not just a spinner) — show
   "Buffering: X seconds ahead" so users understand why playback might pause,
   distinct from "no peers, stalled" which needs different messaging.

Deliverable: file list screen shows quality tags, size, and peer/health info
per file before the user commits to playing; player shows buffer-ahead status
distinct from stall/no-peer errors.
```

---

## CHUNK R5 — Subtitles, done properly

```
Extend beyond basic embedded-track detection.

1. Auto-fetch flow: on play, if no embedded subtitle track exists in the
   user's preferred language (settings-configurable default language), auto-
   search OpenSubtitles (or similar) by filename/hash and auto-load the top
   match, with a clear "Auto-loaded: [subtitle name] — tap to change" toast/
   banner rather than silently doing nothing.

2. Manual override: subtitle picker showing embedded tracks + top 5 external
   search results, with a "search again" option using a custom query if
   filename-based search misses.

3. Subtitle styling settings: font size, background opacity, position offset
   (persisted in Hive settings box, applied globally across all playback).

4. Timing offset control: +/- adjustment in the player for subtitle sync
   drift, common with scene-release timing mismatches — persist per-file so
   it's remembered if the user resumes the same file later.

Deliverable: playing a file with no embedded subs auto-loads an external
match; manual picker and timing/style controls all work and persist.
```

---

## CHUNK R6 — Playback quality-of-life

```
1. Picture-in-picture: implement Android PiP mode (enterPictureInPictureMode)
   triggered on home-button-press while video is playing, with working
   play/pause controls in the PiP window.

2. Background audio mode: a toggle so video-as-podcast use keeps audio
   playing with screen off (distinct from PiP — this is audio-only
   continuation), with media session integration so lock-screen controls and
   notification media controls work (use audio_service or equivalent so
   Android's system media UI shows title/artwork/play-pause-skip).

3. Resume position: verify this works robustly across ALL exit paths — app
   backgrounded, force-killed, device rebooted mid-playback — not just clean
   navigation-away. Position should be written to Hive on a debounced timer
   (already spec'd) AND on every one of these exit paths explicitly (use
   Android lifecycle hooks / WidgetsBindingObserver.didChangeAppLifecycleState
   to force a write on pause/detached states, don't rely solely on the timer).

4. Playback speed control, standard seek gestures (double-tap to skip
   forward/back), volume/brightness swipe gestures matching common video app
   UX conventions users already expect.

Deliverable: PiP works with functional controls; background audio survives
screen-off with lock-screen controls; resume position is bulletproof across
force-kill and reboot; standard gesture controls implemented.
```

---

## CHUNK R7 — Error states and empty states (the "feels professional" layer)

```
Audit every screen for the failure/empty case, not just the happy path.

1. Define a shared ErrorState widget system (not ad-hoc per screen) covering:
   - No network connection
   - Invalid/malformed magnet link (with specific reason if parseable —
     "missing info hash" vs generic "invalid link")
   - No peers found / torrent appears dead
   - Storage full
   - Daemon/engine connection failed (with a "Retry" action, not a dead end)
   - NAS source unreachable

2. Empty states for: library with zero torrents (onboarding prompt: "Paste a
   magnet link to get started" with a visual, not a blank screen), watch
   history empty, search/filter with zero results.

3. First-run onboarding: a brief 2-3 screen intro on first launch explaining
   what the app does and does NOT do (it's a general-purpose torrent client;
   it doesn't search or provide content) — this also does useful legal/
   positioning work, not just UX polish.

Deliverable: every screen has a defined, tested empty state and error state;
first-run onboarding exists and can be replayed from settings.
```

---

## CHUNK R8 — Visual polish pass

```
1. Full Material 3 theming: dynamic color (Material You) support on Android
   12+, proper light/dark mode with a manual override in settings (don't rely
   solely on system setting — some users want the app dark regardless of
   system theme).

2. App icon, splash screen, and consistent iconography for torrent states
   (downloading, seeding, paused, stalled, completed, error) — these need to
   be visually distinct at a glance in the library list view.

3. Library screen layout options: grid (poster-focused, using existing TMDB
   metadata) vs list (denser, more info per row) — user-toggleable, persisted
   preference.

4. Smooth loading states: skeleton loaders for metadata-fetching states
   rather than layout jank when posters pop in late.

Deliverable: consistent Material 3 theme with dynamic color, distinct status
iconography, grid/list toggle, skeleton loading states throughout.
```

---

## Priority order

R1 (foreground service) and R2 (resilience) first — everything else is
polish on top of a download engine that actually survives real phone usage.
R3 (storage) next, since running out of space silently is the fastest way to
lose a user's trust. R4-R8 can interleave in any order after that based on
what's most visibly missing when you actually use the app day to day.

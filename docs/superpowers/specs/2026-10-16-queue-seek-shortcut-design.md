# Queue, seek rework and Now Playing shortcut: design

Approved in conversation on 2026-10-16. Source of truth for the implementation in commits tagged
`feat:` on that date. Out of scope: search and quick-scroll (separate spec after the UI/UX memo in
`docs/ux/2026-10-16-search-ideation-memo.md`), the 200-song queue window, Cover Flow beyond its
track list.

## Decisions

1. **Queue opens with hold-SELECT on Now Playing.** Tap SELECT keeps toggling Volume / Seek.
2. **Hold-SELECT on any song row slides in a three-row menu: Play Now, Play Next, Add to End of
   Queue.** MENU dismisses it. Tap SELECT still plays immediately. Rows that are not songs (albums,
   artists, playlists, genres, composers) do not get the menu.
3. **Seeking keeps playing and commits once.** In Seek mode each wheel click moves a pending
   position by 1/60 of the track (one second minimum), the scrubber draws the playhead there, and one
   seek is committed 400ms after the last click. Switching mode or leaving the screen commits
   immediately; a track change discards the pending position.
4. **Hold-to-seek on the transport buttons is removed.** The wheel's Seek mode is the only scrub.
5. **Hold Play/Pause opens Now Playing from any screen.** It is pushed on top of the current screen,
   so MENU returns to the exact row the user left. No-op when nothing is loaded, when a player screen
   is already on top, or while immersive Cover Flow is showing.

## Components

- `ButtonAction` gains `selectLongPress` and `playPauseLongPress`; the four forward/backward
  long-press cases are gone. `iPlayrButtonController` fires `onNowPlayingShortcut` for the
  Play/Pause hold and routes `selectLongPress` to the active scope with SELECT's debounce window.
- `WheelInputModel` schedules the 500ms hold for the MENU, centre and play/pause regions.
- `NavigationLayer.topRoute` and `Route.isPlayerScreen` let `iPlayrScreen` guard the shortcut.
- `SeekScrubber` (Foundation-only, in ThemeCore, Linux-tested) holds the pending position.
- `AppleMusicManager`: `queueEntries: [QueueEntryInfo]` refreshed by the existing state observer,
  `jump(toEntryID:)`, `playNext(_:)`, `addToQueue(_:)` over `QueueableItem` (song or track) using
  MusicKit's `queue.insert(_:position:)` at `.afterCurrentEntry` / `.tail`; an empty queue starts
  playback instead.
- `Route.queue` → `QueueView`: artwork rows, a speaker glyph on the playing entry, SELECT jumps,
  MENU back, "Nothing queued" empty state, title "Queue · n of m".
- `SongActionMenu` + `QueueCandidate`; `LibraryListView` takes `queueCandidate:`; Songs, album
  tracks, playlist tracks, composer songs and the Cover Flow track list opt in.
- Gestures info page updated.

## Verification split

Linux: `SeekScrubber` (7 tests), wheel geometry, static sweeps. Mac/device: MusicKit queue
insertion and current-entry assignment, the shortcut's stack behaviour, the slide-in menu, seek feel.

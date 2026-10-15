# Beta test log: iPhone 17, iOS 27.0.1

One row per observation. Severity: blocker (cannot use), major (wrong behaviour), minor (visual nit),
note (question or idea). Leave "Fix" blank; it is filled the next day.

| # | Date | Area (theme / mode / wheel / Now Playing / playback / Cover Flow / settings) | Steps to reproduce | Expected | Observed | Severity | Screenshot | Fix |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2026-10-15 | SideStore import | Import the original iPod-Playr-unsigned.ipa; retried twice | Reach signing and installation | SideStore.OperationError code 2: The app is in an invalid format, during DownloadAppOperation | blocker | Console log at 20:28:52 and 20:29:06 | Original archive included Payload/._iPlayr.app metadata sidecar; replaced by metadata-free iPod-Playr-SideStore.ipa. Device retry pending. |

## Build under test

- Source: baseline `679be9b` plus the uncommitted Phase 2 build/configuration fixes
- Version: 1.0 (1)
- Artifact: `DerivedData/Artifacts/iPod-Playr-SideStore.ipa` (replaces the original unsigned archive)
- Xcode version: 27.0 (27A266a), iOS 27.0 SDK
- iOS version on device: 27.0.1
- Signing: SideStore, user's free Apple ID (performed manually)
- Apple Music account signed in: yes / no

## Device setup checklist

- [ ] Developer Mode on
- [ ] Apple Music subscription active
- [ ] Reduce Motion off (then on, for the accessibility pass)
- [ ] Reduce Transparency off (then on)
- [ ] Increase Contrast off (then on)

## Manual first pass

- [ ] Install the IPA through SideStore; launch and confirm that it stays open.
- [ ] Sign In: grant music access; check library loading and any error message.
- [ ] Play a specific album track and playlist track; verify the selected track actually plays.
- [ ] Pause/resume, previous/next, volume, seek, shuffle and repeat.
- [ ] Lock the phone and switch apps while playing; verify background playback and resuming.
- [ ] Theme picker: scroll to preview, SELECT to save, MENU to cancel an unsaved preview.
- [ ] Mode picker: preview/save/cancel; switching themes preserves the chosen mode.
- [ ] Force-quit/relaunch: saved theme and mode persist.
- [ ] Wheel: scroll, SELECT, MENU, hold MENU, and hold previous/next to seek in Now Playing.
- [ ] Cover Flow: browse, open tracks, play, and exit; repeat with Immersive Mode on and off.
- [ ] Check portrait and landscape, brightness, haptics, clicker, and menu customization.
- [ ] Repeat representative screens with Reduce Motion, Reduce Transparency and Increase Contrast.
- [ ] Capture the main menu in all 20 themes in both modes; Now Playing in themes 17, 18 and 20
      in both modes. Name files `NN-themeId-dark.png` / `NN-themeId-light.png` where practical.

Do not mark a pass based only on successful installation. Record MusicKit failures with the exact
message, plus the screen and action that triggered them. Known gaps are listed in the Phase 2 status.

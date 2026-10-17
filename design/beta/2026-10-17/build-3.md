# Manual beta candidate — version 1.3 (3)

Historical release label 1.3; the original bundle embedded version **1.0 (3)**. Filenames and
verification metadata below preserve the original candidate; it has not been rebuilt.

Built on 17 October 2026 for physical iPhones, iOS 17+. Import into SideStore for manual signing
and installation. No automated device installation or device acceptance test was performed.

- IPA: `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-3.ipa` (excluded from Git).
- Size: 5,771,238 bytes.
- SHA-256: `f8979db390420b56dfdfb836f885baa08f2817304c2846bd5223f60475f55fa9`.
- Historical candidate: this IPA was replaced by build 4 after verification. Its evidence is retained.
- [Packaging verification](logs/ipa-build-3-verification.json).

## Included changes

- Cover Flow uses 0.70 nearest-album spacing and a 0.36 stack step, with separate labels.
- Immersive track rows select individual tracks and open standard Now Playing. MENU restores the
  same immersive album/list; hold MENU exits the session to the main menu.
- Rotation preserves the navigation/player subtree. System status indicators follow chassis contrast.
- There are 22 themes: Porcelain Ceramic/Engraved and Liquid Glass Frosted/Clear are included.
  Theme picker variants appear on a separate line, with wrapping for narrow screens.
- Album Glow uses Ambient Screen at 80% preferred intensity with fixed violet hardware. Frosted
  shows artwork beneath the wheel at 75%; Clear uses 50%. Glass keeps a neutral LCD. Contrast
  protection, reduced motion and opaque accessibility fallbacks remain active.
- Both Cover Flow presentations show tracks in the available content area. The fixed-size embedded
  flip card and its vertical offset were removed to prevent clipping/overlap.
- Existing theme IDs are preserved. [Captured settings](selected-theme-settings.json) records the
  selected values and comparison context.

## Verification

- [28 ThemeCore tests](logs/beta-3-theme-core-tests.log): passed, including 594 fixed contrast checks
  plus dynamic artwork/text/progress checks in both screen modes and three screen shapes.
- [Release static analysis](logs/beta-3-release-analyze.log): passed.
- [Unsigned Release iPhone build](logs/beta-3-release-build.log): passed.
- ZIP integrity, one app candidate, arm64 executable, executable permission, platform/privacy/audio
  metadata, absence of signing/provisioning and macOS sidecars, and executable identity: passed.
- Existing AppIntents metadata-extraction warning only; there is no AppIntents dependency.
- No app-module test target is configured. These checks do not establish SwiftUI layout or MusicKit
  runtime correctness on the phone.

## Manual acceptance

- [ ] Install this IPA through SideStore and confirm version 1.3 (3); open the library and play music.
- [ ] Immersive Cover Flow: open Tracks, choose a middle/final track and confirm that exact track
  starts in normal Now Playing. MENU restores the same album, selected row and list position.
- [ ] Repeat after rotating during playback. Queue → MENU returns to Now Playing, then MENU returns
  to immersive Cover Flow. Hold MENU returns to Home without leaving a hidden session.
- [ ] With immersion off, open a long album list, scroll to the last track and verify that the header
  and rows fit in portrait and landscape. MENU returns to covers. Check labels and spacing in both modes.
- [ ] Check all 22 theme entries, especially complete Ceramic/Engraved and Frosted/Clear labels;
  preview, confirm, MENU cancellation and saved choices after relaunch.
- [ ] Compare Album Glow 80%, Frosted 75% and Clear 50% with warm/cool, grayscale and missing artwork,
  in Dark and Light mode. The glass LCD stays neutral; the violet Album Glow chassis stays fixed.
- [ ] Try Reduce Transparency, Increase Contrast, Reduce Motion and VoiceOver. Check system status
  indicators on light bodies and when entering/leaving immersive Cover Flow.
- [ ] Exercise Queue/song actions, the Now Playing shortcut, wheel Volume/Seek, immediate seek commit
  on MENU/hold MENU, tap-to-skip, haptics and click sounds. Confirm Home is titled iPod.

Record results and before/after images in `BETA_TEST_LOG.md`. The 27 original iPhone screenshots
and the additional Cover Flow track-list image in `screenshots of updates/` are pre-build-3 references.

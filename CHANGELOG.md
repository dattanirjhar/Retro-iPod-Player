# Changelog

Track product and development changes here, newest first. Add work under **Unreleased** as it
lands; move it into a dated `version (build)` section when packaging an IPA. Record validation
separately from manual device acceptance. Detailed beta evidence remains in `BETA_TEST_LOG.md`.

Release versions follow **1.2 (build 2), 1.3 (build 3), 1.4 (build 4), 1.5 (build 5)**.
The requested same-version replacement is **1.5 (build 6)**; next is **1.6 (build 7)**.
Releases 1.2 and 1.3 are retrospective labels: those original IPAs embedded marketing version 1.0.
Their original metadata, filenames, logs and checksums are preserved.

## Unreleased

No unreleased changes.

## 1.5 (6) — 2026-10-17

[Manual beta checklist and verification](design/beta/2026-10-17/README.md).

### Changed

- Increased the wide double Menu bars from 1.75 pt to **Bold 3.25 pt** following feedback that
  they looked too light beside the semibold transport symbols. Preserved the 18 pt width,
  6 pt centre spacing, 24 pt canvas and Frosted soft shadow. The gap is now 2.75 pt.
- Updated the contact sheets and captured the Bold geometry separately from the earlier 1.5 (5) settings.
  Retained marketing version 1.5 as requested; increased the build number to 6 for the replacement IPA.

### Verified

- All 29 ThemeCore tests and unsigned Debug iPhone compilation passed. Fresh Release analysis,
  unsigned Release device compilation and IPA verification also passed. The optical weight balance
  against the transport symbols still needs device review.

### Packaging

- Rebuilt **v1.5 (build 6)** as requested, replacing the earlier 1.5 (5) IPA only after verification.
  Only the latest IPA is retained. The next default release is 1.6 (build 7).

## 1.5 (5) — 2026-10-17

Source commit: `86cf1e1`. [Historical beta checklist and verification](design/beta/2026-10-17/build-5.md).

### Changed

- Replaced the wheel's MENU text with the approved wide double-bar symbol across all 21 themes:
  two rounded 18 pt bars, 1.75 pt thick, with 6 pt centre spacing on a 24 pt canvas.
- Frosted's wheel labels now sit directly on the glass with the selected soft shadow: black at
  70%, radius 1.4 pt and 1.4 pt down, plus a 28% edge shadow at radius 0.4 pt. Solid label pills
  return under Reduce Transparency or Increase Contrast. Hit geometry and Menu tap/hold behavior
  are unchanged, including the accessible Menu and Main menu actions.
- Updated contact sheets, captured settings and release notes. Frosted remains at 80% artwork
  intensity / 115% luminance; Album Glow remains at 80% Ambient Screen intensity.

### Verification

- All 29 ThemeCore tests passed, including fixed contrast, migration, wheel geometry and Cover Flow
  checks. Release static analysis, unsigned Release device compilation and IPA verification passed.
  Bare Frosted glyph optics require device acceptance; fixed glyph contrast assertions cover the
  opaque accessibility fallback.

### Packaging

- Built unsigned arm64 IPA **1.5 (5)** for SideStore. Only the latest verified IPA is retained;
  the previous 1.4 archive was removed after the replacement passed verification.

## 1.4 (4) — 2026-10-17

[Historical beta checklist and verification](design/beta/2026-10-17/build-4.md).

### Changed

- Renamed Liquid Glass to Frosted and removed Clear, leaving 21 themes. Saved Clear selections
  migrate to Frosted while preserving Dark/Light mode. Frosted retains its dark body, neutral LCD,
  artwork beneath the controls at the selected 80% intensity and 115% luminance. The artwork-only
  light multiplier runs before opacity; the chassis, LCD, glyph backings and missing-artwork
  fallback retain their original colors. Album Glow stays at 80% Ambient Screen intensity.
- Reimagined Porcelain Ceramic as **Ceramic**, with a cool white satin chassis, flush ceramic face,
  broad highlights and soft chamfer. Reimagined Porcelain Engraved as **Porcelain**, with warm glaze,
  recessed wheel/centre channels, fine metallic inlays, engraved ink and a double chassis rim.
  Both stored IDs and the legacy custom Porcelain body remain compatible.

- Removed What's New, Tutorial and Gestures from Settings. Their existing information routes are
  retained; Tutorial remains accessible through Extras.
- Refreshed About with the app identity, version and build from the bundle, live theme count,
  library totals, device/iOS details, and an inspiration note reflecting the extensive reworking.
  Wheel scrolling, SELECT and the accessible Next control move between its five pages.
- Updated About and the README to describe iPodPlayer as inspiration and acknowledge iPod-Playr's
  extensive changes while retaining its SwiftUI/MusicKit foundation.

### Added

- This development changelog, with a release history and an Unreleased section for future work.
- Documented the release-number convention for future development in `AGENTS.md` and the README.

### Packaging

- Packaged and verified unsigned arm64 IPA 1.4 (4) for SideStore. This is the only retained IPA;
  build 3 was removed after build 4 passed archive and executable checks.

### Verified

- All 29 ThemeCore tests passed, including 567 contrast checks across 42 theme/mode combinations
  and retired Clear migration. Unsigned Debug iPhone compilation passed on 2026-10-17, including
  the selected Frosted lighting. A native SwiftUI render sample confirms the artwork multiplier
  brightens pixels. Release static analysis and the unsigned Release device build also passed;
  archive integrity, metadata, permissions and executable identity checks passed. Settings definitions
  and selection actions no longer include the three disabled entries. Phone installation and
  layout/material acceptance remain pending.

## 1.3 (3) — 2026-10-17

Source commit: `ede1582`. [Historical beta checklist and evidence](design/beta/2026-10-17/build-3.md).

### Added

- Expanded the gallery from 20 to 22 themes with Porcelain Ceramic/Engraved and Liquid Glass
  Frosted/Clear treatments; preserved existing saved theme IDs.
- Distinct artwork color treatments: Album Glow's Ambient Screen at 80% preferred intensity,
  Frosted's artwork backdrop at 75%, and Clear's at 50%, with contrast/accessibility safeguards.
- Captured theme settings and before-build screenshots for subsequent development and review.

### Changed

- Cover Flow uses nearest spacing 0.70 and stack spacing 0.36, with a separate album-label area.
- Immersive Cover Flow selects individual tracks, opens standard Now Playing and restores its
  album/list on MENU. Hold MENU exits to the main menu.
- Both Cover Flow presentations use the available content area for scrolling track lists.
- Rotation preserves the navigation/player subtree; system status indicators follow body contrast.
- Theme picker variant labels appear separately and titles wrap on narrow screens.

### Verified

- 28 ThemeCore tests, fresh Release static analysis, unsigned Release device build and IPA packaging
  checks passed. Manual installation and device acceptance were left to the beta session.

## 1.2 (2) — 2026-10-16

Source through `4b188ef`. [Review and verification details](BETA_TEST_LOG.md).

### Added

- Queue browsing/jumping and song actions: Play Now, Play Next and Add to End of Queue.
- Settled wheel seeking and the hold Play/Pause shortcut to Now Playing.

### Fixed

- Home heading, Cover Flow backdrop framing, wheel size and landscape wheel placement.
- Mac package deployment minimum for Duration support.
- Duplicate Now Playing shortcut behavior when Cover Flow already embeds a player.
- Pending seeks now commit before MENU navigation or focus handoff.

### Verified

- 20 ThemeCore tests, Debug/Release iOS compilation and IPA packaging checks passed.

## 1.0 (1) — 2026-10-15

Initial documented manual beta. [Preserved evidence](design/beta/2026-10-15/README.md).

- Apple Music library browsing, click-wheel controls, Cover Flow and Now Playing.
- Twenty themes with independent Dark/Light screen modes and artwork atmosphere.
- Original SideStore packaging issue and four device UI findings were recorded for follow-up.

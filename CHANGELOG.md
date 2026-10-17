# Changelog

Track product and development changes here, newest first. Add work under **Unreleased** as it
lands; move it into a dated `version (build)` section when packaging an IPA. Record validation
separately from manual device acceptance. Detailed beta evidence remains in `BETA_TEST_LOG.md`.

Release versions advance with each packaged update: **1.2 (build 2), 1.3 (build 3), 1.4 (build 4)**;
next is **1.5 (build 5)**. Releases 1.2 and 1.3 are retrospective labels: those original IPAs
embedded marketing version 1.0. Their original metadata, filenames, logs and checksums are preserved.

## Unreleased

No unreleased changes.

## 1.4 (4) — 2026-10-17

[Manual beta checklist and verification](design/beta/2026-10-17/README.md).

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

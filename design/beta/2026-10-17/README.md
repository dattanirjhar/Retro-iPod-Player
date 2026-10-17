# Manual beta candidate — version 1.4 (4)

Built on 17 October 2026 for physical iPhones, iOS 17+. Import into SideStore for manual signing
and installation. Phone installation and device acceptance have not been performed.

- IPA: `DerivedData/Artifacts/iPod-Playr-SideStore-1.4-4.ipa` (excluded from Git).
- Size: 5,785,586 bytes.
- SHA-256: `327cb04ba4036d1f1ca4ae844b38eb895f5be7f26c4b4ef08816e25629d11e31`.
- This is the only retained IPA; build 3 was removed after the new candidate passed verification.
- [Packaging verification](logs/ipa-build-4-verification.json).
- [Historical build-3 notes](build-3.md).

## Included changes

- 21 themes: 6 Classic, 4 Mini, 6 Nano, 5 Modern. **Ceramic** has cool white satin, a smooth
  flush wheel and soft highlights. **Porcelain** has warm glaze, engraved channels, fine metallic
  inlays and a double chassis rim. **Frosted** replaces the Liquid Glass name; Clear is removed.
- Saved Clear selections migrate to Frosted without changing Dark/Light mode. Existing Ceramic,
  Porcelain and Frosted IDs, plus the legacy custom Porcelain body, remain compatible.
- Frosted artwork is clipped beneath its wheel at **80% intensity / 115% luminance**, retaining
  the dark chassis, neutral LCD and opaque label backings. [Accepted settings](frosted-selected-settings.json).
  Missing artwork stays neutral; transparency/contrast/motion accessibility safeguards remain active.
- Album Glow keeps its violet hardware and Ambient Screen at 80% preferred intensity, with
  contrast protection. Theme and screen mode remain independent.
- Removed What's New, Tutorial and Gestures from Settings. Tutorial remains in Extras.
- About now shows bundle version/build, theme count, library totals, device details and inspiration
  across five pages, using the wheel, SELECT or the accessible Next control.
- About/README use “Inspired by iPodPlayer” wording. [Changelog](../../../CHANGELOG.md) records
  product and development history, with an Unreleased section for future work.
- Includes the earlier Cover Flow 0.70 nearest / 0.36 stack spacing, individual immersive track
  selection, normal Now Playing playback and MENU return to the same immersive album/list.
  Rotation preserves navigation/player state; track lists use the available content area.

## Verification

- [29 ThemeCore tests](logs/beta-4-theme-core-tests.log): passed, including 567 fixed contrast checks
  across 42 theme/mode combinations, dynamic artwork checks, migration, and Cover Flow behavior.
- [Release static analysis](logs/beta-4-release-analyze.log): passed.
- [Unsigned Release iPhone build](logs/beta-4-release-build.log): passed.
- ZIP integrity, single app directory, arm64/iOS executable, permissions, version 1.4 (4),
  privacy/audio metadata, unsigned/provision-free bundle, no macOS sidecars, executable identity: passed.
- [Native SwiftUI render sample](logs/frosted-luminance-render.log) confirms the luminance multiplier
  brightens pixels. This does not establish native glass appearance on the phone.
- The final 1.4 Release analysis and build completed without warnings.
- No app-module UI test target is configured. These checks do not establish device layout or
  MusicKit runtime acceptance.

## Manual acceptance

- [ ] Install through SideStore; confirm About displays version **1.4 (4)** and **21 themes**.
- [ ] Settings excludes the three retired entries. Visit all five About pages with the wheel,
  SELECT and Next. Confirm the inspiration text and Tutorial's separate Extras entry.
- [ ] Review Ceramic's flush highlights and Porcelain's engraving/inlays in both orientations.
  Check all 21 entries, preview/confirm/MENU cancellation and persisted choices after relaunch.
- [ ] Upgrade from a Clear selection: confirm Frosted is selected and screen mode is preserved.
- [ ] Compare Frosted 80%/115% with warm, cool, grayscale and missing artwork in Dark/Light mode.
  Confirm a neutral LCD and dark chassis. Compare Album Glow's broad Ambient Screen lighting.
- [ ] Try Reduce Transparency, Increase Contrast, Reduce Motion and VoiceOver. Check system status
  contrast on light bodies and when entering/leaving immersive Cover Flow.
- [ ] Immersive Cover Flow: choose a middle/final album track; that exact track starts in normal
  Now Playing. MENU restores the same album, selected track and list position. Repeat after rotation.
- [ ] Queue → MENU returns to Now Playing; another MENU restores immersive Cover Flow. Hold MENU
  exits to Home. With immersion off, scroll a long track list to its end in both orientations.
- [ ] Check dense Cover Flow spacing, wheel Volume/Seek, seek commit on MENU/hold MENU, queue/song
  actions, Now Playing shortcut, tap-to-skip, haptics/clicker and Home's iPod title.

Record device results in `BETA_TEST_LOG.md`. The original screenshot set remains the before reference.

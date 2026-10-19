# Historical beta — 2.7.3

Canonical label under [the new policy](../../../RELEASE_VERSIONING.md). Original bundle marketing version: `1.6`; build: `7`.
The metadata, filenames and dated retention statements below record the original package.
Current release: [2.7.4](../2026-10-19/README.md).

Built on 17 October 2026 for physical iPhones, iOS 17+. Import into SideStore for signing and
manual installation. Device installation and visual acceptance have not been performed.

- IPA: `DerivedData/Artifacts/iPod-Playr-SideStore-1.6.ipa` (excluded from Git).
- Size: 5,788,047 bytes.
- SHA-256: `54934e30d0ce3f1b4b7b04d5066547d6566b819f57564ee4a9120506130b2659`.
- Only this IPA is retained. The previous 1.5 IPA was removed after 1.6 passed verification.
  The original build-6 checksum is preserved in the verification report.
- [Packaging verification](logs/ipa-build-7-verification.json).
- [Historical 1.5 (6) notes](build-6.md), [1.5 (5) notes](build-5.md), [1.4 notes](build-4.md) and [1.3 notes](build-3.md).

## Included changes

This replacement corrects the marketing version to **1.6** at the user’s request and increments the bundle build to **7**.
The original 1.5 (5) IPA used 1.75 pt Menu bars.

- Replaced MENU text with the approved **Bold wide double** symbol across all 21 themes. Two rounded
  18 pt bars, each 3.25 pt thick, are spaced 6 pt centre-to-centre on a 24 pt optical canvas, with a 2.75 pt gap.
- Frosted's four wheel labels now use **bare symbols with the selected soft shadow**: 70% black,
  radius 1.4 pt, offset 1.4 pt down, plus a 28% black edge shadow at radius 0.4 pt.
- Reduce Transparency or Increase Contrast restores opaque wheel/label surfaces. Other materials
  keep their existing flat or engraved glyph treatments. [Accepted settings](wide-double-bold-v1.6-settings.json).
- Tap Menu still goes back; hold Menu still returns to the main menu. The hit layer, wheel sectors,
  scroll/press handling and accessible Menu/Main menu actions are unchanged.
- Frosted stays at 80% artwork intensity / 115% luminance with a dark chassis and neutral LCD.
  Album Glow stays at 80% preferred Ambient Screen intensity. Cover Flow stays at 0.70 / 0.36 spacing.
- Includes the prior 1.5 (5) theme, Settings/About and Cover Flow improvements. Contact sheets now show
  the new symbol; their Frosted view remains an opaque material approximation.

## Verification

- [29 ThemeCore tests](logs/beta-6-theme-core-tests.log): passed, including migration, wheel geometry,
  Cover Flow behavior, dynamic Album Glow checks and 567 fixed contrast checks across 42 combinations.
- [Release static analysis](logs/beta-6-release-analyze.log): passed.
- [Unsigned Release iPhone build](logs/beta-7-release-build.log): passed.
- ThemeCore tests and static analysis above were completed for the identical app source in build 6;
  build 7 changes only version metadata and release documentation.
- ZIP integrity, exactly one app directory, arm64/iOS executable, executable permissions, version
  1.6 (7), privacy/background-audio metadata, unsigned/provision-free bundle, no macOS sidecars and
  executable identity against the Release product: passed.
- Analysis emitted the existing AppIntents metadata-extraction notice; the app has no AppIntents dependency.
- Fixed Frosted glyph contrast checks cover the opaque accessibility fallback. Native glass/artwork
  under bare symbols requires device optical acceptance; the shadow does not establish fixed contrast.
- No app-module UI test target is configured. Phone layout, MusicKit runtime and touch acceptance remain manual.

## Manual acceptance

- [ ] Install through SideStore; About displays **1.6 (7)** and **21 themes**.
- [ ] Review the Bold wide double symbol across Classic, Mini, Nano, Ceramic, Porcelain, Album Glow and
  Frosted, in portrait/landscape and both screen modes. Check centring and weight against transport symbols.
- [ ] In Frosted, confirm all four glyphs sit directly on the glass with a soft shadow and no solid pills.
  Change between warm, bright, dark and grayscale artwork; check missing artwork and older-iOS material fallback.
- [ ] Enable Reduce Transparency, then Increase Contrast independently: opaque labels and wheel return,
  and artwork is hidden. Disable them to restore bare symbols. Check Reduce Motion and VoiceOver actions.
- [ ] Tap the top symbol to go back; hold it to reach Home. Check scrolling, SELECT, skip and Play/Pause.
  Repeat in embedded/immersive Cover Flow, normal Now Playing and after rotating during playback.
- [ ] Regression: immersive track selection opens normal Now Playing; Menu restores the same album/list.
  Check Queue, seek commit, Theme preview/confirm/cancel and Settings/About navigation.

Record results in `BETA_TEST_LOG.md`. The earlier screenshots and notes remain historical references.

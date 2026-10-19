# Historical beta — 2.7.1

Canonical label under [the new policy](../../../RELEASE_VERSIONING.md). Original bundle marketing version: `1.5`; build: `5`.
The metadata, filenames and dated retention statements below record the original package.
Current release: [2.7.4](../2026-10-19/README.md).

Built on 17 October 2026 for physical iPhones, iOS 17+. Import into SideStore for signing and
manual installation. Device installation and visual acceptance have not been performed.

- IPA: `DerivedData/Artifacts/iPod-Playr-SideStore-1.5.ipa` (excluded from Git).
- Size: 5,788,049 bytes.
- SHA-256: `dac1798ae308b9135d09f538cb2b8092a112094469d7d1eb7a7ebe75bda74a8d`.
- Historical build: replaced by 1.5 (6), which uses Bold 3.25 pt Menu bars. Original evidence is preserved. The previous 1.4 archive was removed after verification of this IPA;
  its checksum matched the historical verification manifest despite its shortened filename.
- [Packaging verification](logs/ipa-build-5-verification.json).
- [Historical 1.4 notes](build-4.md) and [1.3 notes](build-3.md).

## Included changes

- Replaced MENU text with the approved **wide double** symbol across all 21 themes. Two rounded
  18 pt bars, each 1.75 pt thick, are spaced 6 pt centre-to-centre on a 24 pt optical canvas.
- Frosted's four wheel labels now use **bare symbols with the selected soft shadow**: 70% black,
  radius 1.4 pt, offset 1.4 pt down, plus a 28% black edge shadow at radius 0.4 pt.
- Reduce Transparency or Increase Contrast restores opaque wheel/label surfaces. Other materials
  keep their existing flat or engraved glyph treatments. [Accepted settings](wide-double-selected-settings.json).
- Tap Menu still goes back; hold Menu still returns to the main menu. The hit layer, wheel sectors,
  scroll/press handling and accessible Menu/Main menu actions are unchanged.
- Frosted stays at 80% artwork intensity / 115% luminance with a dark chassis and neutral LCD.
  Album Glow stays at 80% preferred Ambient Screen intensity. Cover Flow stays at 0.70 / 0.36 spacing.
- Includes the prior 1.4 theme, Settings/About and Cover Flow improvements. Contact sheets now show
  the new symbol; their Frosted view remains an opaque material approximation.

## Verification

- [29 ThemeCore tests](logs/beta-5-theme-core-tests.log): passed, including migration, wheel geometry,
  Cover Flow behavior, dynamic Album Glow checks and 567 fixed contrast checks across 42 combinations.
- [Release static analysis](logs/beta-5-release-analyze.log): passed.
- [Unsigned Release iPhone build](logs/beta-5-release-build.log): passed.
- ZIP integrity, exactly one app directory, arm64/iOS executable, executable permissions, version
  1.5 (5), privacy/background-audio metadata, unsigned/provision-free bundle, no macOS sidecars and
  executable identity against the Release product: passed.
- Analysis emitted the existing AppIntents metadata-extraction notice; the app has no AppIntents dependency.
- Fixed Frosted glyph contrast checks cover the opaque accessibility fallback. Native glass/artwork
  under bare symbols requires device optical acceptance; the shadow does not establish fixed contrast.
- No app-module UI test target is configured. Phone layout, MusicKit runtime and touch acceptance remain manual.

## Manual acceptance

- [ ] Install through SideStore; About displays **1.5 (5)** and **21 themes**.
- [ ] Review the wide double symbol across Classic, Mini, Nano, Ceramic, Porcelain, Album Glow and
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

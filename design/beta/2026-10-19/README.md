# Manual beta — 2.7.4

Source commit: `e37db0bb47d7774469bfa9a1304520b0d784152c`. [Current agent/prod handoff](../../../HANDOFF.md).

Packaged on 19 October 2026 for arm64 iPhones, iOS 17+. Import into SideStore for signing and
manual installation. Device installation and runtime acceptance have not been performed.

- IPA: `DerivedData/Artifacts/iPod-2.7.4.ipa` (excluded from Git; remote pulls include source/logs, not the IPA).
- Size: 5,791,255 bytes.
- SHA-256: `c2bc8e61a5a261a448f66ace487a65f7bc3708cac23d72721ef043d277e0fbad`.
- Visible/embedded version: **2.7.4**. Internal installation counter: **9**, separate from the
  milestone build 4. About displays only **2.7.4**.
- Only this IPA is retained. The prior IPA was checksum-verified before removal; its original
  metadata/hash remain in the [new verification report](logs/ipa-build-9-verification.json).
- [Previous candidate: 2.7.3](../2026-10-17/README.md), originally embedded marketing version 1.6.

## Included changes

- Right-side menu artwork now uses shuffled rounds independently of library sorting. Every cover
  appears once per round, with no immediate repeat across round boundaries when multiple covers exist.
- Missing artwork is excluded from both rendering and cycling, preventing blank slides. Empty
  libraries show No Music; a single available cover remains still.
- Six-second timing, alternating pan and crossfade are retained. Preloaded libraries initialize
  correctly; cycling stops while hidden or unauthorized and resumes when the menu returns.
- Adopted **2.milestone.build**. The predecessor is series 1; our 20-theme redesign starts at 2.1.
  Major feature additions and major design changes advance the milestone and restart its build at 1.
  Historical labels are regrouped in [the complete policy](../../../RELEASE_VERSIONING.md).
- Current milestone: clickwheel controls, **2.7**. This is its fourth package. Next fix: **2.7.5**;
  Search, if next, would start **2.8.1**.
- Retains Bold 3.25 pt Menu bars and the soft shadow, 21 themes, Frosted at 80% intensity / 115%
  luminance, Album Glow Ambient Screen at 80%, and Cover Flow spacing 0.70 / 0.36.
  [Captured settings](selected-settings.json).

## Verification

- [29 ThemeCore tests](logs/release-theme-core-tests.log): passed, including theme migration,
  geometry, Cover Flow, artwork lighting and 567 fixed contrast checks across 42 combinations.
- [Release static analysis](logs/release-analyze.log): passed for the same Swift app source before
  the final numbering metadata change. The existing AppIntents metadata-extraction notice remains.
- [Final unsigned Release iPhone build](logs/release-build.log): passed.
- [IPA verification](logs/ipa-build-9-verification.json): ZIP integrity, single app directory,
  arm64/iOS platform, executable permissions, embedded version/counter, privacy/audio metadata,
  no macOS sidecars or signatures/provisioning, and executable identity against the Release app passed.
- [Undelivered intermediate package](logs/superseded-numbering-candidate.json): preserves the hash
  and internal counter 8 from before the numbering discussion finished. It is not another milestone.
- Fixed Frosted contrast checks cover the opaque accessibility fallback; bare glass optics and
  MusicKit runtime behavior still require a phone. No app UI test target is configured.

## Manual acceptance

- [ ] Install through SideStore; About shows exactly **2.7.4**, without a bracketed build suffix.
- [ ] Observe the menu slideshow through a full round and rollover. Check randomized order,
  no repeats within a round and no immediate repeat at its boundary.
- [ ] Check albums with missing artwork; test zero, one and two available covers where possible.
- [ ] Open Now Playing and return; change library sort order and authorization. Check the timer
  resumes, album browsing order remains correct, and rotation preserves the expected layout.
- [ ] Confirm the accepted Bold Menu glyph, Frosted lighting/shadow and accessibility fallbacks.
- [ ] Regression: immersive Cover Flow track selection opens normal Now Playing; Menu restores the
  same album/list. Check Queue, seeking, scrolling, transport controls and theme selection.

Record phone observations in [BETA_TEST_LOG.md](../../../BETA_TEST_LOG.md).

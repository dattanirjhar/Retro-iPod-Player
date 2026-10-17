# Beta observations — 15 October 2026

Release labels now follow **1.2/build 2 → 1.3/build 3 → 1.4/build 4 → 1.5/build 5**. The requested
same-version Bold replacement is **1.5/build 6**; the next default release is **1.6/build 7**.
The original build-2/build-3 bundles embedded version 1.0; historical bundle metadata, paths and
raw verification logs are preserved. Retention statements in dated entries apply at those dates.

**Latest candidate, 17 October: 1.5 (6).** Uses the approved Bold 3.25 pt wide double Menu
symbol and gives Frosted bare glyphs with a soft shadow, retaining opaque accessibility fallbacks.
All 29 ThemeCore tests, Release analysis/build and IPA checks pass. Only the 1.5 IPA is retained;
manual device acceptance remains pending. See the [current checklist](design/beta/2026-10-17/README.md).

**Build-3 history, 17 October:** immersive Cover Flow track selection/return navigation, denser album
spacing (0.70 / 0.36), landscape title layout, system status-bar contrast, and the 22-theme gallery
are implemented locally. Album Glow now uses the selected Ambient Screen treatment at 80% preferred
intensity. Glass artwork is limited to the wheel, at 75% for Frosted and 50% for Clear. The source
passes 28 ThemeCore tests and an unsigned Debug iOS build. The gallery includes Porcelain
Ceramic/Engraved and Liquid Glass Frosted/Clear.
Version **1.3 (3)** now packages these changes plus the final theme-label and embedded track-list
fixes. Release analysis/build and IPA verification pass. Only build 3 is retained; device acceptance
is pending. See the [manual beta checklist](design/beta/2026-10-17/README.md).
The following device/build details describe the original 15 October candidate.

**Post-build-3 source update:** removed What's New, Tutorial and Gestures from Settings; refreshed
About with version/build, theme/library/device information and “Inspired by iPodPlayer” wording.
Added `CHANGELOG.md` for ongoing development and release history. Unsigned Debug compilation passes;
the retained build-3 IPA does not contain this later Settings/About update.

**Current source appearance:** 21 themes, including separate Ceramic, Porcelain and Frosted.
Clear is retired and its saved selections migrate to Frosted. The accepted Frosted comparison uses
**80% artwork intensity / 115% luminance**, with a dark chassis and neutral LCD. Album Glow remains
at 80% Ambient Screen intensity. These later theme changes are also absent from the build-3 IPA.

Device: iPhone 17 · iOS 27.0.1 · app 1.0 (1) · manually installed using SideStore.
Build tools: Xcode 27.0 (27A266a), iOS 27.0 SDK. Source: baseline `679be9b` plus uncommitted Phase 2
build/configuration and packaging fixes. Candidate: `DerivedData/Artifacts/iPod-Playr-SideStore.ipa`.

**Current plan and pending acceptance checks:** [prod-dev-team handoff for 16 October](PHASE2_MAC_HANDOFF.md).
This observed-results log replaces the earlier blank checklist. Its previous version is in the
[evidence archive](design/beta/2026-10-15/archive/BETA_TEST_LOG.md).

## Reported result

The app launched and was used on the phone. The user reports that the rest of their tested use is
working fine, except for the issues below. No individual pass is inferred for unreported background
playback, migration, relaunch or accessibility scenarios. The user intends to avoid/deactivate Cover
Flow for now. No app preference, feature flag or implementation was changed in this documentation pass.

| ID | Priority | Observation / requested outcome | Evidence | Status |
| --- | --- | --- | --- | --- |
| BETA-01 | P2 | Home heading says iPlayr; it must say iPod. | Screenshots 03, 04, 05 | Fixed 2026-10-16 in `8af5801` (`HomeListView` title). Awaiting device check |
| BETA-02 | P1 | Cover Flow is misaligned and clipped; user reports failure with Immersive Mode On and Off. Selected cover/text/controls clip in portrait; landscape covers run below the visible area. | Screenshots 01, 02; user's explicit report for both modes | Fixed 2026-10-16 in `0f9312c`. Cause: the backdrop requested a rigid 700 × 700 `ArtworkImage`, inflating the layout by (700 − width)/2 ≈ 155 pt right in portrait and (700 − height)/2 down in landscape, in both Immersive settings. Backdrop now sized and clipped to the view; whole screen pinned to its measured size. Awaiting device check in all four combinations |
| BETA-03 | P2 | Landscape wheel sits too far inward; move it toward the right/end of the phone. | Screenshot 03 | Fixed 2026-10-16 in `e7814dd`: landscape reserves a square at the trailing edge (20 pt from the edge) and the wheel fills it. Awaiting user review in both landscape rotations |
| BETA-04 | P2 | Wheel feels too small; enlarge it slightly and check both orientations/styles. | Screenshots 03, 04, 05; user's tactile feedback | Fixed 2026-10-16 in `e7814dd`: portrait 70% of body width (76% compact), was 62% / 68%; landscape sized from the height (about 300 pt on a 390 pt-tall phone, was about 178 pt). Hit map unchanged. Awaiting user review |
| INSTALL-01 | Historical blocker | Original IPA rejected twice as invalid format before signing. Removed ambiguous macOS metadata sidecars in the replacement package. | Preserved SideStore console at 20:28:52 and 20:29:06 | Packaging corrected earlier; later screenshots establish app launch, without a success-install log |

See the [evidence index](design/beta/2026-10-15/README.md) for image links and saved logs. Exact
Immersive Mode state is not labeled per screenshot; use the user report to cover both states.

## Verification already recorded on the Mac

- 13 ThemeCore XCTest tests passed, including 540 contrast checks.
- Release iPhone build and Debug Analyze passed.
- Corrected IPA passed ZIP, arm64/iPhoneOS metadata, executable permissions, one-app-candidate and
  no-AppleDouble checks. It remains unsigned until SideStore signs it.
- App-module iOS tests were not run; no Xcode test target is configured.
- No tests, builds or app-code changes were performed in the documentation-only beta handoff pass.

## Fix pass, 16 October 2026 (Linux, not yet rebuilt)

All four items are implemented and committed (`8af5801`, `0f9312c`, `e7814dd`); ten orphaned app-icon PNGs were also removed (`b36cce4`) to clear the unassigned-children build warning. At this Linux handoff, the changes had not been compiled or installed. The later Mac compilation is recorded below; a new IPA and device checks remain pending for every item above.

## Mac review and follow-up fixes — 16 October 2026

Reviewed the eight commits pulled onto `main`, `58ae10f..1c58974`, authored by `tattva`.
They include BETA-01 through BETA-04, removal of ten unused icons, queue browsing and jumping,
song actions (Play Now / Play Next / Add to End of Queue), settled wheel seeking, the hold
Play/Pause shortcut, and updated documentation. Search is an ideation memo only; no search
implementation was added. The full commit list is in [the handoff](HANDOFF_2026-10-16.md).

The review found three issues. The user authorized fixing all three; these changes are local
and uncommitted on top of `1c58974` at the time of this entry.

| ID | Finding and fix | Files | Verification |
| --- | --- | --- | --- |
| MAC-01 | Native Mac tests failed because the new scrubber uses `Duration`, available from macOS 13, while the package had no matching deployment minimum. Declared `.macOS(.v13)`. | `ThemeCore/Package.swift` | Reproduced the compiler error; all 20 tests pass after the fix. |
| MAC-02 | The Now Playing shortcut checked only the outer route, so it missed Cover Flow's embedded player. Added `FocusScope.isPlayerScreen`, marked player scopes, and checked the active scope before pushing another player. | `iPlayr/iPlayr/Core/Managers/UI/FocusScope.swift`, `iPlayr/iPlayr/Screens/Player/PlayerView.swift`, `iPlayr/iPlayr/Components/iPlayrScreen.swift` | Compiles successfully. Device check of embedded Cover Flow remains pending. |
| MAC-03 | MENU navigation left pending seeking to the disappearance callback or the 400 ms timer. MENU now flushes before navigating. `FocusScope.onDeactivate` also flushes when another scope takes the wheel, covering hold MENU and other focus changes while views remain mounted. Reactivating the same scope does not deactivate it. | `iPlayr/iPlayr/Core/Managers/UI/FocusScope.swift`, `iPlayr/iPlayr/Core/Managers/UI/iPlayrButtonController.swift`, `iPlayr/iPlayr/Screens/Player/PlayerView.swift` | Compiles successfully; existing seek model tests pass. Immediate commit behavior still needs device verification. |

### Executed verification

Xcode 27.0 (27A266a), iOS 27.0 SDK. Final test and build results were recorded at approximately
23:32 IST on 16 October. Commands were run from the repository root:

```bash
CLANG_MODULE_CACHE_PATH=/private/tmp/ipod-review-clang-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/ipod-review-swift-cache \
swift test --disable-sandbox --package-path ThemeCore --scratch-path /private/tmp/ipod-review-tests

xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr \
  -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/ipod-review-derived CODE_SIGNING_ALLOWED=NO build

git diff --check
```

- **Passed:** 20 XCTest tests, zero failures: 7 seek tests, 2 color tests, 1 contrast test
  (540 checks), 5 selection/migration tests, 3 theme-table tests, and 2 wheel-geometry tests.
  The trailing Swift Testing runner reports zero tests because this suite uses XCTest.
- **Passed:** unsigned Debug build for a generic physical iOS device. The new MusicKit queue
  APIs compile with this SDK. No unused app-icon warning was emitted.
- **Build warning, verbatim:** `warning: Metadata extraction skipped, no AppIntents.framework dependency found`.
- **Test environment warnings:** SwiftPM user caches were inaccessible/read-only under the
  execution sandbox; the warnings did not prevent the successful test run. Xcode compilation
  required running outside that sandbox so Swift macro plugins and Xcode services could work.
- **Passed:** `git diff --check` after the source fixes.
- **Not executed:** app-module iOS tests, a new Analyze action, Release packaging, simulator
  interaction tests, phone installation, or device acceptance checks. No new IPA was generated
  and the build number was not changed. The existing 15 October IPA is still the previous candidate.

Saved evidence: [original Mac test failure](design/beta/2026-10-16/logs/theme-core-before-fix.log),
[20-test pass](design/beta/2026-10-16/logs/theme-core-after-fix.log), and
[successful Debug iOS build](design/beta/2026-10-16/logs/xcode-debug-device-build.log).

### Remaining acceptance checks

- [ ] With Immersive Mode off, open Cover Flow's player and hold Play/Pause: no second player
      opens. From Cover Flow's browsing or track list, the shortcut still opens Now Playing;
      MENU returns to the previous screen and selection.
- [ ] In Seek mode, turn the wheel and immediately press MENU: the target commits on exit.
      Repeat with hold MENU, opening Queue, and returning from the embedded Cover Flow player.
- [ ] Confirm ordinary seeking still settles once after 400 ms, switching modes commits,
      and changing tracks discards the pending seek.
- [ ] Verify queue jumps, Play Next, Add to End of Queue, empty-queue behavior, song actions,
      shortcut return paths, and VoiceOver actions on the phone.
- [ ] Complete BETA-01 through BETA-04 visual/touch checks with the next installed candidate.

## Release IPA — 16 October 2026, 23:47 IST

- Source: `4b188ef` (`fixes of beta test II`), which includes the three follow-up fixes and
  review logs, plus the local build-number change below.
- Bumped `CURRENT_PROJECT_VERSION` from `1` to `2` in both Debug and Release configurations.
  Marketing version remains `1.0`; bundle identifier remains `com.kerem.iPlayr`.
- Ran `bash scripts/build_ipa.sh`: **Release build succeeded** for physical iOS devices with
  signing disabled, including the pulled updates and all three local Mac follow-up fixes.
- New candidate: `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-2.ipa`.
  The script's default `DerivedData/Artifacts/iPod-Playr-SideStore.ipa` contains identical bytes.
- Size: 5,733,147 bytes. Minimum iOS: 17.0. Architecture/platform: arm64 / iPhoneOS.
- SHA-256: `7e6f86404d32175b154f83c30f3d231bd64298d81cb8181fdc57b27d3f11a9d2`.
- Preserved the previous candidate as `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-1.ipa`;
  its SHA-256 remains `7df9fbca27c8b23cd8914079addd5bbd9206b71df804296a570a003d1d0c8de3`.
- **Packaging checks passed:** ZIP integrity, exactly one app directory in Payload, no
  AppleDouble or `__MACOSX` metadata, arm64 Mach-O executable targeting iOS devices, executable
  permissions, music privacy description, background audio mode, and no code-signature directory
  or embedded provisioning profile.
- **Only Xcode warning:** `warning: Metadata extraction skipped, no AppIntents.framework dependency found`.
- **Pending:** manual SideStore signing/installation and the acceptance checks above. Packaging
  validation does not establish runtime behavior. No new Analyze action or device tests were run.
- Saved [Release build log](design/beta/2026-10-16/logs/xcode-release-build-2.log) and
  [IPA verification report](design/beta/2026-10-16/logs/ipa-build-2-verification.json).

## Build cleanup — 17 October 2026

At the user's request, retained only `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-2.ipa` as the
distributable build. Deleted the previous 1.0 (1) IPA and the duplicate, unversioned 1.2 (2) IPA.
Removed the older Debug device products/intermediates and the temporary Debug build directory
`/private/tmp/ipod-review-derived`. The latest Release products and historical verification logs
remain. Rechecked ZIP integrity and SHA-256: the retained IPA is unchanged. Earlier references
to the preserved previous candidate or the unversioned alias describe the state before this cleanup.

## Screenshot review and Cover Flow follow-up — 17 October 2026

Reviewed all 27 images in [`screenshots of updates/`](screenshots%20of%20updates/): 20 portrait
theme views, immersive Cover Flow examples, landscape Home/Queue, portrait Queue, and song actions.
The images show the iPod home title, larger wheel, trailing landscape wheel, populated Queue with
current-entry markers, and readable song actions. They do not display the app's version/build number.

**Correction from the user:** `IMG_1570.PNG` was captured mid-swipe. Its offset artwork is not
evidence of a centering defect. The user requests tighter album spacing like the two supplied classic
iPod references and confirms the other visual concerns: landscape title overlap and low-contrast
white iOS status indicators on light bodies. These are UI screenshots, not proof of seek timing,
shortcut restoration, queue insertion behavior, or theme persistence.

The user also reports that immersive album tracks cannot be selected and Play starts track 1 in
an immersive player. Requested behavior: immersion is limited to Cover Flow; selecting a track
opens normal portrait/landscape Now Playing, and MENU returns to the same immersive album/list.

### Changes implemented locally

| Area | Change | Source |
| --- | --- | --- |
| Immersive track selection | Album track rows are plain-styled buttons with 44 pt minimum height. The immersive list uses the available content area and preserves its selection while loading. Play from the track list uses the selected index; Play from covers starts track 1. | `SongListView.swift`, `AlbumCover.swift`, `CoverFlowView.swift` |
| Normal Now Playing and return | A dedicated `.immersiveCoverFlowPlayer` route renders the standard player. `CoverFlowPresentation` suspends the immersive overlay while keeping it mounted. MENU resumes it with the same album/track scope; hold MENU dismisses the session and returns to the main menu. | `MainScreen.swift`, `Navigation.swift`, `iPlayrScreen.swift`, `Core/Theme/ThemeCore/CoverFlowPresentation.swift` |
| Rotation | A shared `AnyLayout` changes screen/wheel arrangement without replacing the screen subtree, preserving player/navigation state across portrait and landscape. | `MainScreen.swift` |
| Dense album fan | The user chose 0.70 × cover width for the first neighbour and 0.36 × for each farther album after comparing the prototype. This supersedes the initial 0.64 / 0.29 proposal, the wide 0.92 × spacing, and the old clamp that placed farther albums on top of one another. | `CoverFlowPresentation.swift`, `CoverFlowView.swift`, `CoverFlowMetrics.swift` |
| Landscape labels | Cover size is constrained by available height after reserving the header, title, reflection, and controls. The title/artist now occupy their own vertical area below the carousel. Close is in the immersive header, outside the track rows. | `CoverFlowView.swift` |
| System status-bar contrast | Chassis-top contrast chooses dark or light system status indicators; immersive Cover Flow uses light indicators over black. The simulated interface keeps its selected Dark/Light mode. | `MainScreen.swift` |
| Porcelain | Ceramic retains its warm body, charcoal glyphs, orange accent, and matte finish, with an ivory ceramic face, shallow edge/shadow, and defined center. The added Engraved variant uses a warm outline with an inset highlight and etched glyph treatment. | `ThemeTable.swift`, `iPodButtons.swift`, `GlassWheelMaterial.swift` |
| Liquid Glass | Frosted and Clear use neutral screen surfaces and native `.regular` / `.clear` glass on iOS 26+. Blurred current artwork is clipped to the wheel at the captured 75% / 50% opacity respectively; fixed opaque glyph backings preserve contrast. Earlier iOS versions use system material. Reduce Transparency or Increase Contrast uses opaque wheel surfaces and hides the artwork backdrop. Reduce Motion disables artwork cross-fades. | `ThemeTable.swift`, `iPodButtons.swift`, `GlassWheelMaterial.swift` |
| Gallery and compatibility | 22 themes: 6 Classic, 4 Mini, 6 Nano, 6 Modern. Saved `porcelain` and `liquidGlass` IDs remain valid, selecting Ceramic and Frosted; added IDs are `porcelainEngraved` and `liquidGlassClear`. Dark/Light remains independent. Contact sheets now include all 22 with glass shown as an opaque approximation. | `ThemeTable.swift`, `scripts/contact_sheets.py`, `design/contact-dark.png`, `design/contact-light.png` |

Swift filenames above are under `iPlayr/iPlayr/` in their existing feature folders.

### Validation and limits

- **Passed:** 28 native Mac XCTest tests, zero failures. Five Cover Flow tests cover immersive browse →
  normal playback → return, duplicate play-request rejection, dismissal without resurrection,
  distinct/symmetric cover positions, and continuous spacing during swipes. The 594 contrast
  checks cover all 44 theme/mode combinations, including ceramic and glass label/fallback surfaces.
  Migration checks include both preserved IDs and both new variants.
  Three album-lighting tests also check effect separation, independent 75% / 50% glass intensity,
  fixed violet hardware, and dynamic text/progress contrast across eight artwork palettes, both
  screen modes and three screen shapes.
- **Passed:** unsigned Debug compilation for `generic/platform=iOS` using Xcode 27.0.
  Only Xcode warning: `warning: Metadata extraction skipped, no AppIntents.framework dependency found`.
- **Passed:** `git diff --check` for the source changes.
- Test command: `swift test --disable-sandbox --package-path ThemeCore --scratch-path /private/tmp/ipod-review-tests`
  with the same temporary module-cache variables documented in the 16 October entry.
- Build command: `xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/ipod-oct17-build CODE_SIGNING_ALLOWED=NO build`.
- Saved [test results](design/beta/2026-10-17/logs/theme-core-tests.log) and
  [Debug build log](design/beta/2026-10-17/logs/xcode-debug-build.log) for the first 22-theme pass.
  The latest [28-test run](design/beta/2026-10-17/logs/album-lighting-tests.log) and
  [Debug build](design/beta/2026-10-17/logs/album-lighting-debug-build.log) include the selected lighting treatments.
- No new Release IPA, device installation, or app-module UI tests were run. Version 1.2 (2) remains
  the only distributable and does not contain these changes. The build number is still 2.

### Liquid Glass decision and implementation

The earlier blue surfaces and outline-only wheel prompted comparison of four material directions.
The user selected all four, especially Frosted and Ceramic, and explicitly retained artwork color
behind Liquid Glass controls. All four are now implemented in source as described above.
Apple's [Materials guidance](https://developer.apple.com/design/human-interface-guidelines/materials)
reserves Liquid Glass for the controls/navigation layer and recommends using it sparingly.
The native API signatures were checked against the installed iOS 27 SDK and compiled successfully.
The design comparisons/contact sheets approximate appearance; native optical effects and gesture
feedback still need device evaluation. The wheel hit geometry and input handling are unchanged.

### Modern Album Glow research and initial proposal

The user likes its existing violet palette and asked what functional behavior the name originally
meant. The [original atmosphere spec](iPlayr-Visual-Styling-Review.md#now-playing-and-album-art-atmosphere)
defines artwork-derived ambient light behind Now Playing content, two cached dominant colors,
mode-specific clamps, contrast protection, a 600 ms transition and no continuous animation.
`PlayerView.swift` and `ArtworkAtmosphere.swift` already implemented that behavior. The theme used
the Subtle level with a 55% screen-color overlay, which may explain why the effect feels faint;
that explanation is a code-based inference, not a new device observation.

Research precedents:

- [YouTube Ambient Mode](https://support.google.com/youtube/answer/12827017?hl=en) casts gentle
  content-derived color into the background, supporting the idea of extending artwork into nearby light.
- [Android's official Palette guidance](https://developer.android.com/develop/ui/views/graphics/palette-colors)
  explicitly describes album-cover-derived song colors, asynchronous extraction, caching and fallbacks.

Recommended direction for discussion: retain the violet body, wheel outline and accent; make a
more noticeable localized two-color halo around the album cover in Now Playing, with a restrained
background wash. Keep text and controls readable, maintain the same light for tracks sharing the
same artwork, and transition on artwork changes. Missing/grayscale art falls back to violet.
Alternatives: a broader ambient-room wash, or a thin artwork-colored edge halo. Audio-reactive
pulsing is outside the original intent and would need a separate playback/analysis feasibility review.
No Modern Album Glow constants or behavior changed during the initial research pass. The selection
and implementation below supersede this proposal.

### Initial selected lighting treatments — 17 October 2026

After comparing the same artwork in both themes, the user selected **Ambient Screen** for Modern
Album Glow and requested stronger artwork color for the darker Frosted theme (65–70%) than Clear
(50–55%). Chosen defaults: **Album Glow 55%** (the comparison's selected intensity), **Frosted 70%**,
**Clear 55%**. These are theme constants, not new settings rows.

- **Album Glow:** two broad radial lights behind Now Playing, with mode-specific color clamps,
  a solid controls platter and contrast-protected text/progress. The new Foundation-only
  `AmbientScreenSpec` prefers 55% intensity and reduces it only if needed for readable text.
  Missing/grayscale palettes use the existing violet accent/wheel colors. The violet hardware is fixed.
- **Liquid Glass:** removed the shared Now Playing artwork wash. The LCD remains neutral; actual
  blurred artwork appears beneath the wheel at each material's own opacity, clipped to the wheel's
  diameter. Missing artwork leaves a neutral body-colored backing. This replaces the earlier
  extracted-palette blobs and removes their extra palette-loading work from the wheel.
- **Accessibility and transitions:** artwork changes cross-fade over 600 ms, without continuous
  animation; Reduce Motion swaps instantly. Glass retains opaque accessibility fallbacks. Increase
  Contrast disables Album Glow's ambient screen lighting. Screen mode does not change glass intensity.
- **Preview:** the comparison now opens on Ambient Screen and has independent intensity controls
  for Album Glow, Frosted and Clear; the defaults match the app. Its glass optics remain approximate.

No new IPA or device verification was performed in this pass. Version 1.2 (2) is still the previous candidate.

### Captured comparison refinements — 17 October 2026

The user adjusted the comparison and explicitly requested capturing those settings. These supersede
the initial 55% / 70% / 55% defaults above:

| Theme | Captured treatment | Artwork intensity |
| --- | --- | --- |
| Modern Album Glow | Ambient Screen | 80% preferred, with text contrast protection |
| Liquid Glass · Frosted | Blurred artwork beneath the wheel | 75% |
| Liquid Glass · Clear | Blurred artwork beneath the wheel | 50% |

Updated `AmbientScreenSpec.preferredIntensity`, `WheelMaterial.artworkIntensity`, and the existing
album-lighting tests. Values apply in both screen modes. The comparison was viewed in Dark mode
with artwork color enabled and Frosted visible; that preview context does not change the app's saved
theme or mode. Cover Flow remains at nearest spacing 0.70 and stack spacing 0.36.

Saved the full selection and preview context in
[`selected-theme-settings.json`](design/beta/2026-10-17/selected-theme-settings.json).
Validation: all 28 tests and unsigned Debug iOS compilation pass; logs are saved as
[`selected-lighting-tests.log`](design/beta/2026-10-17/logs/selected-lighting-tests.log) and
[`selected-lighting-debug-build.log`](design/beta/2026-10-17/logs/selected-lighting-debug-build.log).
The existing IPA still predates these source changes.

### Source-review findings — resolved in build 3

The user asked whether any work or concerns remained. The source/log audit identified the following
items. They were then fixed for the requested beta build; device layout acceptance remains pending.

| ID | Original finding | Build-3 resolution |
| --- | --- | --- |
| FOLLOWUP-01 | Long theme names could truncate the suffix that distinguishes variants. | `ThemeView.swift`: family and variant are separate lines; titles wrap vertically, preserving the swatch and checkmark. Accessibility combines the row's labels. |
| FOLLOWUP-02 | The embedded track card's fixed 280 pt height and 35 pt offset could clip or overlap album labels. | `CoverFlowView.swift`: both presentations use the full available content area for track lists. `AlbumCover.swift` now renders covers/reflections only; obsolete expanded-card sizing was removed. |
| FOLLOWUP-03 | Fresh comparison defaults still used 55% / 70% / 55%. | The thread comparison now defaults to 80% / 75% / 50%, while retaining subsequent saved edits. |

### Release candidate and Git preparation — 17 October 2026

- Increased `CURRENT_PROJECT_VERSION` to **3** in Debug and Release; marketing version stays 1.0.
- Ran all 28 ThemeCore tests: zero failures. Ran fresh Release analysis and the unsigned Release
  iPhone build: both passed. Existing AppIntents metadata-extraction warning only.
- Built with `bash scripts/build_ipa.sh`, then renamed the verified output to
  `DerivedData/Artifacts/iPod-Playr-SideStore-1.0-3.ipa`.
- Size: **5,771,238 bytes**. SHA-256:
  `f8979db390420b56dfdfb836f885baa08f2817304c2846bd5223f60475f55fa9`.
- Packaging checks pass: ZIP integrity, exactly one app directory, no macOS sidecars, arm64/iOS
  metadata, executable permissions, Music usage description, background audio, unsigned bundle,
  and archive executable identical to the Release product.
- Deleted the known previous 1.2 (2) IPA only after the new candidate passed verification. Build 3
  is the only retained distributable. Build logs and previous verification reports are preserved.
- Fetched `origin` before commit preparation; local `main` matched `origin/main` at `4b188ef`.
  Prepared the source, tests, documentation, verification evidence and reference screenshots for a
  local beta commit. No remote push is performed by this task; the IPA remains excluded from Git.
- Saved [test log](design/beta/2026-10-17/logs/beta-3-theme-core-tests.log),
  [Release analysis](design/beta/2026-10-17/logs/beta-3-release-analyze.log),
  [Release build](design/beta/2026-10-17/logs/beta-3-release-build.log),
  [IPA verification](design/beta/2026-10-17/logs/ipa-build-3-verification.json), and
  [manual beta checklist](design/beta/2026-10-17/README.md).

Installation and phone acceptance remain manual. No app-module UI test target is configured.

### Next acceptance checks

- [ ] In the next candidate after build 3, confirm the shortened Settings menu, five About pages,
      version/build display and wheel/SELECT/tappable Next navigation. Tutorial remains in Extras.

- [ ] Immersive Cover Flow → Tracks → tap a middle or final track: that exact track starts in
      standard Now Playing with the normal chassis and wheel.
- [ ] MENU returns to the same immersive album, track-list state, selected row, and scroll position.
      Repeat after rotating during playback. Playback must not restart on rotation or on return.
- [ ] Queue → MENU returns to normal Now Playing; a second MENU returns to immersive Cover Flow.
- [ ] Hold MENU exits to the main menu; reopening Cover Flow creates a fresh browsing session.
- [ ] In the immersive track list, choose a row and press Play; from covers, Play starts track 1.
- [ ] Validate dense spacing and separate labels/controls in both orientations and both immersive settings.
- [ ] Check iOS status indicators on Porcelain, Silver Classic, Mini Gold, and dark bodies, including
      entering/exiting immersive Cover Flow without changing the selected interface mode.
- [ ] Review both Porcelain variants and both Liquid Glass variants, in both orientations/modes.
      Change albums, try missing artwork, and check Reduce Transparency, Increase Contrast and Reduce
      Motion. Evaluate native glass on the phone; compilation and static contrast tests do not verify optics.
- [ ] Check Album Glow's broad screen light against Glass's neutral LCD, with warm, cool, grayscale
      and missing artwork. Confirm the captured 80% Album Glow / 75% Frosted / 50% Clear balance on the device.

## Next device result to record

For the next candidate containing the 17 October changes, record its version/build, installation
outcome, the new acceptance checks above, and BETA-01 through BETA-04 results,
Immersive On/Off plus orientation for each Cover Flow screenshot, and the user's review of wheel
placement/size. Keep the current screenshots as the before set; do not overwrite them.


### Post-build-3 source update — material identities, 17 October 2026

- Renamed Liquid Glass to **Frosted** and retired **Clear**. The gallery now contains 21 themes
  (6 Classic, 4 Mini, 6 Nano, 5 Modern). Saved Clear IDs and legacy presets migrate to Frosted
  without changing screen mode. Native/fallback glass and accessibility behavior remain supported.
- Split the old Porcelain variants into **Ceramic** and **Porcelain**, preserving their stored IDs.
  Ceramic uses cool white satin, a flush wheel, broad specular light and a soft chamfer. Porcelain
  uses warm glaze, recessed circular channels, metallic inlay, engraved label details and a double rim.
  The legacy custom Porcelain body still migrates to Ceramic.
- Frosted stays at **75%** artwork opacity and Album Glow stays at **80%** preferred Ambient Screen
  intensity. A separate comparison explores brighter Frosted artwork before implementation.
  Comparison defaults: Current 75% intensity/100% luminance, More artwork 85%/100%, Brighter
  artwork 85%/115%. All keep the dark chassis and neutral screen; material optics are approximated.
- Refreshed both contact sheets and development documentation. These source changes are absent
  from the retained **1.3 (3)** IPA. Device optical/layout acceptance remains pending.
- Validation: 29 ThemeCore tests passed, including 567 contrast checks across 42 combinations and
  Clear migration in both modes; unsigned Debug iPhone build passed. Evidence:
  [theme tests](design/beta/2026-10-17/logs/theme-refresh-tests.log) and
  [Debug build](design/beta/2026-10-17/logs/theme-refresh-debug-build.log).

Next candidate acceptance: confirm the three separate Modern names, no Clear entry, saved Clear
migration, Ceramic's flush highlights and Porcelain's recessed/inlaid detail in portrait/landscape
and both screen modes. Review Frosted artwork across warm, cool, grayscale and missing artwork.
Earlier build-3 checklists and settings snapshots above describe that packaged build's 22-theme state.

### Accepted Frosted brightness — 17 October 2026

- Applied the user's edited **Current** comparison: **80% artwork intensity / 115% luminance**.
  The other comparison variants remain alternatives. Album Glow stays at 80% Ambient Screen;
  Cover Flow stays at nearest 0.70 / stack 0.36. Clear remains retired.
- The extended-sRGB light multiplier affects the blurred artwork before opacity and glass.
  The dark chassis, neutral LCD, opaque glyph backings and missing-artwork fallback are unchanged.
  Reduce Transparency/Increase Contrast still disable the artwork layer; Reduce Motion still
  disables cross-fades. Both Dark and Light screen modes use the selected artwork settings.
- Captured the accepted values and artwork context in
  [Frosted settings](design/beta/2026-10-17/frosted-selected-settings.json). The earlier
  `selected-theme-settings.json` remains a historical snapshot of packaged beta 3.
- All 29 ThemeCore tests passed, including 567 contrast checks; unsigned Debug iPhone compilation
  passed. A native SwiftUI render sample also confirms that the light multiplier increases pixel
  brightness. This sample does not establish the phone's native glass optics.
- Evidence: [theme tests](design/beta/2026-10-17/logs/frosted-lighting-tests.log),
  [Debug build](design/beta/2026-10-17/logs/frosted-lighting-debug-build.log), and
  [native render sample](design/beta/2026-10-17/logs/frosted-luminance-render.log).
  No IPA was repackaged; build 3 still predates these changes. Device acceptance remains pending.


### Release candidate 1.4 (4) — 17 October 2026

- Reviewed and confirmed the pending Settings/About and material updates. Set both Debug/Release
  build numbers to 4; marketing version is 1.4. The gallery has 21 themes, with Ceramic,
  Porcelain and Frosted as separate entries; Clear migration preserves screen mode.
- Frosted uses the approved 80% artwork intensity and 115% luminance. Album Glow remains at
  80% Ambient Screen intensity and Cover Flow at 0.70 / 0.36 spacing.
- All 29 ThemeCore tests passed, including 567 fixed contrast checks, dynamic artwork checks,
  retired-theme migration and Cover Flow presentation/spacing checks. Fresh Release static
  analysis and unsigned Release iPhone compilation passed. The final 1.4 analysis and build
  completed without warnings. Earlier runs recorded an AppIntents metadata-extraction notice.
- Packaged `DerivedData/Artifacts/iPod-Playr-SideStore-1.4-4.ipa` for SideStore: **5,785,586 bytes**,
  SHA-256 `327cb04ba4036d1f1ca4ae844b38eb895f5be7f26c4b4ef08816e25629d11e31`.
  ZIP integrity, single app directory, no macOS sidecars, version/build/platform/privacy/audio
  metadata, arm64, executable permissions, unsigned bundle, and executable identity all passed.
- Removed the previous build-3 IPA after build 4 passed verification. Historical build-3 notes
  are retained in [build-3.md](design/beta/2026-10-17/build-3.md); the main beta checklist now describes build 4.
  Promoted the Unreleased changelog into the 1.4 (4) release entry.
- Fetched origin successfully over SSH; main matched origin/main at `ede1582` before preparing
  this release commit. Source, settings, documentation, contact sheets and validation evidence
  are included in the requested commit/push; the IPA stays excluded from Git.
- Evidence: [29 tests](design/beta/2026-10-17/logs/beta-4-theme-core-tests.log),
  [Release analysis](design/beta/2026-10-17/logs/beta-4-release-analyze.log),
  [Release build](design/beta/2026-10-17/logs/beta-4-release-build.log), and
  [IPA verification](design/beta/2026-10-17/logs/ipa-build-4-verification.json).

No phone installation, MusicKit runtime acceptance or native-material optical acceptance is inferred.
Use the current manual checklist and record the next device result here.

Version convention confirmed by the user: earlier releases are labeled 1.2/build 2 and 1.3/build 3;
this candidate embeds **1.4 (4)**. Future packaged updates increment both values together, starting
with 1.5/build 5. `AGENTS.md`, README and changelog record the convention. Historical verification
manifests add the revised release label while preserving the actual embedded 1.0 version and hashes.
The temporary 1.0 (4) archive was removed after the 1.4 (4) replacement passed verification.


### Release 1.5 (5) — wide double and soft shadow, 17 October 2026

- Applied the user's approved **Wide double / Soft shadow** direction. The menu text is now two
  rounded 18 pt bars, 1.75 pt thick with 6 pt centre spacing, on a 24 pt optical canvas across all
  21 themes. The existing Menu label position, hit sector and input routing are unchanged.
- Frosted's four glyphs are bare by default, with black shadows at 70%/1.4 pt radius/1.4 pt down and
  a 28%/0.4 pt edge shadow. Reduce Transparency or Increase Contrast restores opaque label backings
  and wheel material; those accessibility modes continue to suppress the artwork layer.
- Other materials keep their existing glyph treatments. Accessible Menu/Main menu actions remain
  available. Frosted 80% intensity / 115% luminance, Album Glow 80%, and Cover Flow 0.70 / 0.36 remain unchanged.
- Captured the approved geometry and shadow values in
  [selected wheel settings](design/beta/2026-10-17/wide-double-selected-settings.json). Regenerated both
  contact sheets with the new symbol; these sheets still approximate Frosted using its opaque fallback.
- Set Debug and Release to marketing version **1.5**, build **5**. The next packaged update is 1.6/build 6.
  Updated changelog, README, current beta checklist, handoff pointers and the release convention.
- All 29 ThemeCore tests pass, including 567 fixed contrast checks, dynamic Album Glow checks,
  migration, wheel geometry and Cover Flow behavior. Release analysis and unsigned Release iPhone
  compilation pass. Existing AppIntents metadata-extraction notice during analysis only.
- Verified `DerivedData/Artifacts/iPod-Playr-SideStore-1.5.ipa`: **5,788,049 bytes**, SHA-256
  `dac1798ae308b9135d09f538cb2b8092a112094469d7d1eb7a7ebe75bda74a8d`.
  ZIP integrity, single app directory, no macOS sidecars, arm64/iOS metadata, executable permissions,
  privacy/background audio, unsigned bundle and executable identity against the Release product pass.
- Verified the previous 1.4 IPA's hash against its historical manifest before removing it. It was
  found as `iPod-Playr-SideStore-1.4.ipa`; original verification filenames/hashes remain preserved.
  Only 1.5 is retained. Archived the previous current checklist as
  [build-4.md](design/beta/2026-10-17/build-4.md).
- Fetched origin successfully; main matched origin/main at `93eaad6` before preparing this release commit.
  The source, selected settings, release notes, contact sheets and verification evidence are prepared
  for the requested commit/push. The IPA remains excluded from Git.
- Evidence: [tests](design/beta/2026-10-17/logs/beta-5-theme-core-tests.log),
  [Release analysis](design/beta/2026-10-17/logs/beta-5-release-analyze.log),
  [Release build](design/beta/2026-10-17/logs/beta-5-release-build.log), and
  [IPA verification](design/beta/2026-10-17/logs/ipa-build-5-verification.json).

Fixed glyph contrast assertions cover the opaque Frosted accessibility fallback. Bare symbols over
native glass and changing artwork still need the manual visual/interaction checks in the current
checklist. No device installation, optical acceptance or MusicKit runtime result is inferred.


### Unreleased source adjustment — Bold Menu weight, 17 October 2026

- User reports that the 1.75 pt Menu bars look much lighter than the straight stems in Pause and
  Skip, and requested trying the Bold direction. The supplied screenshot path was unavailable;
  this change follows their description and the 3.25 pt Bold comparison.
- Increased the native rounded bars to **3.25 pt**, preserving 18 pt width, 6 pt centre spacing and
  the centred 24 pt canvas. The inter-bar gap is now 2.75 pt. Frosted's selected soft shadow,
  transport symbols, Menu hit region and tap/hold behavior are unchanged.
- Regenerated contact sheets and captured [Bold settings](design/beta/2026-10-17/wide-double-bold-settings.json).
  The earlier selected-settings file preserves the exact 1.5 packaged geometry.
- All 29 ThemeCore tests and unsigned Debug iPhone compilation passed. Evidence:
  [tests](design/beta/2026-10-17/logs/bold-menu-theme-tests.log),
  [Debug build](design/beta/2026-10-17/logs/bold-menu-debug-build.log).
  Existing AppIntents metadata-extraction notice only; device optical acceptance remains pending.
- Source update only: the retained **1.5 (5)** IPA still has 1.75 pt bars. No new IPA, version bump,
  commit or push was performed in this adjustment. Next packaged release remains 1.6/build 6.


### v1.5 replacement — build 6, 17 October 2026

- Packaged the approved **Bold 3.25 pt** Menu bars, retaining 18 pt width, 6 pt centre spacing,
  2.75 pt gap, 24 pt canvas and Frosted's selected soft shadow. The hit layer, Menu tap/hold,
  transport glyphs, artwork lighting, accessibility fallbacks and 21-theme gallery are unchanged.
- Kept marketing version **1.5** at the user's explicit request and raised both Debug/Release
  build numbers to **6** for this replacement IPA. Updated the version policy: next default release
  is 1.6/build 7. Original 1.5 (5) settings, logs, hashes and notes remain historical evidence.
- Promoted the Bold Unreleased entry into the 1.5 (6) changelog. The current checklist now describes
  build 6; the former checklist is archived as [build-5.md](design/beta/2026-10-17/build-5.md).
  [Bold settings](design/beta/2026-10-17/wide-double-bold-settings.json) now record the packaged values.
- All 29 ThemeCore tests pass. Fresh Release analysis and unsigned Release iPhone compilation pass.
  Analysis emitted only the existing AppIntents metadata-extraction notice; Release build had no warnings.
- Verified `DerivedData/Artifacts/iPod-Playr-SideStore-1.5.ipa`: version **1.5 (6)**, **5,788,050 bytes**,
  SHA-256 `35098b026e714525282199d533532e2072fa8f767d9f2103e21f2d6137ffeaa6`.
  ZIP integrity, single app directory, arm64/iOS metadata, executable permissions, privacy/audio,
  unsigned bundle, absence of macOS sidecars and executable identity against the Release product pass.
- Confirmed the old build-5 checksum before replacing that IPA atomically with build 6. Only this
  latest IPA is retained. The verification report preserves the replaced candidate's metadata/hash.
- Fetched origin successfully; main matched origin/main at `86cf1e1` before preparing this release.
  The requested commit/push includes code, contact sheets, settings, release notes and evidence;
  the IPA stays excluded from Git.
- Evidence: [tests](design/beta/2026-10-17/logs/beta-6-theme-core-tests.log),
  [Release analysis](design/beta/2026-10-17/logs/beta-6-release-analyze.log),
  [Release build](design/beta/2026-10-17/logs/beta-6-release-build.log), and
  [IPA verification](design/beta/2026-10-17/logs/ipa-build-6-verification.json).

Phone installation, optical weight/contrast acceptance and MusicKit runtime checks remain manual.
Earlier dated source-only and retention statements describe the state at those times.

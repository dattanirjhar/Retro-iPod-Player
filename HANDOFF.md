# Current handoff — 19 October 2026

Start here after pulling the repository. This is the current operational handoff for agents and
prod-dev-team. It supersedes the dated plans in `HANDOFF_2026-10-16.md`, `PHASE2_MAC_HANDOFF.md`
and the historical snapshots in `THEME_MIGRATION_STATUS.md`.

## Read order and authority

1. [AGENTS.md](AGENTS.md): working instructions and version rules.
2. This file: current state, implementation map, constraints and remaining work.
3. [Current beta record](design/beta/2026-10-19/README.md) and its manual acceptance checklist.
4. [Release numbering](RELEASE_VERSIONING.md), [changelog](CHANGELOG.md) and
   [chronological beta log](BETA_TEST_LOG.md) for decisions and historical evidence.

Current code and the latest explicit user decisions take priority over old plans. A historical
"local/uncommitted", "current", "next release" or "only retained IPA" statement describes its
original date. Do not reapply superseded designs or interpret historical pending implementation
as missing code today. No prior chat, temporary verifier script or local HTML visualization is
needed: accepted settings, sources, tests and logs are committed.

## Release checkpoint

| Item | Current value |
| --- | --- |
| Branch | `main` |
| Release source commit | `e37db0bb47d7774469bfa9a1304520b0d784152c` |
| Visible version / About | **2.7.4**, without brackets |
| Internal installation counter | **9**, independent of the visible milestone build 4 |
| Bundle identifier / deployment | `com.kerem.iPlayr`; arm64 iPhoneOS; iOS 17.0+ |
| Toolchain used | Xcode 27.0, build 27A266a |
| Local IPA | `DerivedData/Artifacts/iPod-2.7.4.ipa` |
| IPA bytes / SHA-256 | 5,791,255 / `c2bc8e61a5a261a448f66ace487a65f7bc3708cac23d72721ef043d277e0fbad` |
| Source/package verification | 29 tests passed; Release analysis and final Release compilation passed; IPA checks passed |
| Phone verification | Installation and runtime acceptance of this candidate are pending |

The release source is committed and pushed. Subsequent handoff and packaging-tooling commits update the instructions and filename handling
without changing the release binary. Read the current Git status before beginning new work;
there was no unfinished source work at release handoff.

**The IPA is excluded from Git**, as is DerivedData. Pulling remote gets source and durable evidence,
not the local binary. The recorded hash identifies the original candidate; a later rebuild can have
a different ZIP hash. Do not claim an IPA exists on another machine or that a rebuilt archive is the
original. Use the build procedure below for a new candidate.

## Delivered behavior and accepted design

| Area | Accepted behavior or settings |
| --- | --- |
| Right-side menu artwork | Shuffled rounds of albums with artwork; each cover once per round; no immediate boundary repeat with multiple covers. Missing artwork is excluded from counting and display. Zero covers shows No Music; one stays still. Six-second slides, 1.5-second crossfade, alternating pan; pauses while hidden/unauthorized. Does not mutate library/Cover Flow sort order. |
| Cover Flow | Nearest spacing **0.70**, stack **0.36**. Individual album tracks are selectable. Immersive mode applies to browsing; playback uses ordinary portrait/landscape Now Playing. Menu resumes the same immersive album/list; hold Menu goes Home. |
| Menu symbol | Bold wide double across all themes: width **18 pt**, thickness **3.25 pt**, centres **6 pt** apart, gap **2.75 pt**, canvas **24 pt**. Tap goes back; hold goes Home. Hit mapping unchanged. |
| Frosted wheel symbols | Bare symbols by default. Primary black shadow 70%, radius 1.4 pt, down 1.4 pt; edge shadow 28%, radius 0.4 pt. Reduce Transparency or Increase Contrast restores opaque surfaces/label backings. |
| Frosted theme | Dark body, neutral LCD, artwork behind controls at **80% intensity**, **115% artwork luminance**. Native glass on supported iOS with system-material fallback. Clear retired; old Clear selections migrate to Frosted while preserving screen mode. |
| Album Glow | **Ambient Screen at 80%** preferred intensity, fixed violet hardware. Its screen lighting is intentionally distinct from Frosted's artwork behind controls. |
| Ceramic / Porcelain | Separate themes: Ceramic is cool satin/flush ceramic; Porcelain is warm glaze with recessed engraving and metallic inlays. Preserve stored IDs despite display-name changes. |
| Theme gallery | **21** themes: Classic 6, Mini 4, Nano 6, Modern 5. Dark/Light changes the screen independently of hardware. |
| Settings/About | What's New, Tutorial and Gestures removed from Settings; Tutorial still exists in Extras. About displays the dotted version, theme/library/device information and inspiration wording. Describe iPodPlayer as inspiration, not original-project credit. |
| Playback tools | Queue and song actions, settled wheel seeking, hold Play/Pause shortcut. Hold SELECT opens Queue on Now Playing or song actions on song rows. |

The [machine-readable settings](design/beta/2026-10-19/selected-settings.json) preserve these values.
Old 22-theme/Clear, 75% Frosted, thin Menu-bar and early Porcelain prototypes are superseded.
`IMG_1570.PNG` was captured mid-swipe; do not diagnose its transitional Cover Flow position alone
as a settled-layout failure. Tracked user screenshots remain in `screenshots of updates/`.
Contact sheets in `design/` are approximations, not native glass/device acceptance evidence.

## Implementation map

Paths below are relative to `iPlayr/iPlayr/` unless otherwise stated.

| Work area | Entry points |
| --- | --- |
| Artwork shuffle and lifecycle | `Components/RightImageView.swift` |
| Wheel glyphs, materials, input | `Components/iPodButtons.swift`, `Components/GlassWheelMaterial.swift`, `Core/Managers/UI/iPlayrButtonController.swift` |
| Themes, stored selection, mode | `Core/Theme/ThemeCore/ThemeTable.swift`, `ThemeState.swift`, `ModeTokens.swift`; `Core/Theme/Theme.swift` |
| Album Glow lighting | `Core/Theme/ArtworkAtmosphere.swift`, `Core/Theme/ThemeCore/AmbientScreenSpec.swift`, `Screens/Player/PlayerView.swift` |
| Cover Flow / immersive return | `Screens/CoverFlow/`, `Core/Theme/ThemeCore/CoverFlowPresentation.swift`, `Screens/Main/MainScreen.swift`, `Components/iPlayrScreen.swift`, `Core/Navigation/Navigation.swift` |
| Queue, library and album shuffle | `Core/Managers/AppleMusic/AppleMusicManager.swift`, `MusicLibraryStore.swift`, `Screens/Queue/QueueView.swift`, `Components/SongActionMenu.swift` |
| About and Settings | `Screens/Settings/AboutView.swift`, `SettingsView.swift` |
| Release metadata / packaging | Repository root: `iPlayr/iPlayr.xcodeproj/project.pbxproj`, `scripts/build_ipa.sh` |
| Portable tests | Repository root: `ThemeCore/`; its sources symlink to the app's `Core/Theme/ThemeCore` |

## Evidence and its limits

- [29-test output](design/beta/2026-10-19/logs/release-theme-core-tests.log): migration, geometry,
  Cover Flow state, lighting and 567 fixed contrast checks across 42 combinations. These tests do
  not exercise the SwiftUI slideshow timer, MusicKit service behavior or native glass optics.
- [Release analysis](design/beta/2026-10-19/logs/release-analyze.log): identical Swift source before
  the final version metadata correction. Existing AppIntents extraction notice only.
- [Final Release build](design/beta/2026-10-19/logs/release-build.log): final 2.7.4/counter-9 candidate.
- [IPA verification](design/beta/2026-10-19/logs/ipa-build-9-verification.json): ZIP integrity, one app,
  no macOS sidecars, arm64/iOS platform, executable permissions/identity, version/counter, music/audio
  metadata and unsigned/provision-free packaging. Includes the actual release commit as well as base.
- [Intermediate metadata](design/beta/2026-10-19/logs/superseded-numbering-candidate.json): internal
  counter 8 was consumed by an undelivered numbering candidate, so the next unused counter is 10.

No app-module UI test target is configured. Fixed Frosted glyph contrast tests cover its opaque
accessibility fallback. Phone checks remain distinct from compilation, analysis and unit tests.

## Remaining work

| Item | Current status and next action |
| --- | --- |
| 2.7.4 manual beta | Run the [current acceptance checklist](design/beta/2026-10-19/README.md): artwork rounds/rollover, missing/single covers, hide/return, sorting/authorization, About, rotation, Cover Flow return, Queue/seek, glass/accessibility. Record device/iOS, version, steps, expected/actual outcome and screenshots/logs. |
| Library-wide playback window | Still limited to 200 queued songs with 25-song lead-in in `AppleMusicManager.enqueue`; no automatic window extension. Album/playlist `playTracks` queues the full chosen container. Treat large-library continuation as an open limitation. |
| Shuffle Albums identity | `MusicLibraryStore.songsGroupedByShuffledAlbums` groups by album title, so distinct albums sharing a title can merge. Stable album identity remains a follow-up. This differs from the right-side artwork shuffle fixed in 2.7.4. |
| Dynamic visual contrast | Code has lighting safeguards and tests; native artwork/glass, Light mode and accessibility need manual optical review. Historical contrast concerns are not a claim of a newly reproduced failure. |
| Search / quick-scroll | Not implemented. [Search memo](docs/ux/2026-10-16-search-ideation-memo.md) contains proposals and unresolved scope choices, not an approved implementation specification. Search qualifies for the next milestone if it is the next major feature. |

BETA-01..04 layout changes, immersive track selection and normal-player return are implemented in
source. Their old issue descriptions are historical evidence, not instructions to remove Cover Flow
or redo the fixes. Keep itemized device acceptance pending until actual observations establish it.

## Verification and next package

From the repository root, portable tests:

```bash
swift test --package-path ThemeCore
```

On a Mac with full Xcode selected, analyze and compile for a physical iPhone without packaging or signing:

```bash
xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr -destination 'generic/platform=iOS' -configuration Release -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO analyze
xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr -destination 'generic/platform=iOS' -configuration Release -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

Save complete output under a new dated `design/beta/.../logs/` path; preserve prior logs. Linux can
run the portable package but cannot establish that SwiftUI/MusicKit compiles or that an IPA works.
Use manual SideStore signing/installation for phone acceptance; no automated phone installation or
simulator run was performed in the saved evidence.

Before producing a new IPA, follow [RELEASE_VERSIONING.md](RELEASE_VERSIONING.md): next routine
candidate **2.7.5**, internal counter **10**; next milestone instead **2.8.1**, internal counter **10**.
Set both Xcode configurations consistently. Do not bump for documentation-only work.

```bash
bash scripts/build_ipa.sh
```

This writes `DerivedData/Artifacts/iPod-<version>.ipa` using the embedded version, plus the build
log. The script refuses to overwrite an existing candidate of that version. It
checks version format, ZIP integrity, device platform, metadata, single app and no signing/sidecars.
Complete the additional architecture, executable-permission/identity and embedded-metadata checks
listed in the current verification report; record the new SHA-256/size and source commit/base.
Verify the new package before removing the previous IPA. Update
README, beta notes, settings capture, changelog and this handoff; commit/push code and evidence.
Keep the IPA and DerivedData out of Git. Changes to documentation do not require rebuilding the IPA.

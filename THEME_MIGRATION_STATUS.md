# Theme + Mode migration status

**Current product handoff:** [16 October prod-dev-team fix plan](PHASE2_MAC_HANDOFF.md).
**Latest Mac validation, 16 October:** all 20 ThemeCore tests and unsigned Debug iOS compilation
pass on `1c58974` plus the three locally applied review fixes. A new IPA and device checks remain
pending. See [the current verification log](BETA_TEST_LOG.md#mac-review-and-follow-up-fixes--16-october-2026).
The 15 October device beta reported four issues: iPod heading, broken Cover Flow in both immersive
settings, landscape wheel alignment, and wheel size. See [observations](BETA_TEST_LOG.md) and
[saved evidence](design/beta/2026-10-15/README.md). This file retains the technical history below;
the current handoff replaces the earlier simulator plan and pending-first-launch checklist.

Phase 1 (Linux) status as of 2026-10-15 15:50 IST. Every item was verified against the files, the Linux
SwiftPM build and tests (Swift 6.0.3 in `swift:6.0-jammy`), and the regenerated contact sheets.
At that point no SwiftUI had been compiled. This table is the historical Phase 1 snapshot;
see the Phase 2 results below for the current Mac verification status.

| # | Item | Status | Evidence | What remains |
| --- | --- | --- | --- | --- |
| A | Settings reduced to Theme + Mode; Language and Immersive Mode kept | Done | `Screens/Theme/ThemeView.swift` `ThemeView.Row { theme, mode, language, immersive }`; `Core/Navigation/Navigation.swift` routes `.appearanceSetting(.theme/.mode/.language)` only; no Body/Ring/Glyph/Interface/Accent/Atmosphere rows, pickers or view models remain (grep in §O) | Device check of the hub tonight |
| B | Persistence = themeId + mode; migration; obsolete keys deleted | Done | `Core/Theme/Theme.swift` `persist()` writes only `themeId`, `mode` (+ immersiveMode, language); `init` runs `ThemeMigration.migrate` then removes `UserDefaultsKeys.legacyKeys`; `Core/Theme/ThemeCore/ThemeState.swift` `ThemeMigration`; test `SelectionStateTests.testMigration` | Migration against a real stored Custom / Retro value on device |
| C | Theme picker: sections, swatches, preview / confirm / cancel, tick | Done | `ThemeView.swift` `ThemePickerView`: `SectionHeaderRow` per `ThemeGroup`, `ThemeSwatch` (body disc, wheel ring, base-accent dot), `onChange(of: scope.selection)` → `theme.preview(theme:)`, SELECT → `commitPreview()`, MENU → `cancelPreview()` + pop, tick = `theme.savedTheme.id == spec.id`; state machine test `SelectionStateTests.testPickerPreviewConfirmCancel` | Live preview feel on device |
| D | Mode picker: Dark / Light, same behaviour | Done | `ThemeView.swift` `ModePickerView`, `ModeSwatch` (screenBackground + "Aa" in primaryText), preview / confirm / cancel identical to C | Device check |
| E | 20 hardware constants exactly as Spec §3 | Done | `Core/Theme/ThemeCore/ThemeTable.swift` `ThemeTable.all`; test `ThemeTableTests.testEveryThemeConstant` (restates the spec table) and `testTwentyThemesInGalleryOrder` | — |
| F | Per-theme × per-mode selection and progress constants (Spec §4) | Done | same file, `dark:` / `light:` tuples per theme, stored not derived; `ThemeDerivation` deleted; test `testEveryThemeConstant` | — |
| G | Mode tokens (Spec §5) incl. Dark mutedText #9AA5B3 and Glow / Liquid Glass overrides | Done | `Core/Theme/ThemeCore/ModeTokens.swift` `SurfaceTokens.dark/.light`; `ThemeTable.modernAlbumGlowDark/Light`, `liquidGlassDark/Light`; overrides keep text colours (`SurfaceTokens.applying`); test `ThemeTableTests.testModeTokenConstants` | — |
| H | Mode affects only the screen; hardware and bezel identical in both modes | Done | `Screens/Main/MainScreen.swift` `ChassisBackgroundView(theme: ThemeSpec)` reads no mode; `Components/iPodButtons.swift` `WheelLook(theme:)` reads no mode; bezel `Theme.swift` `bezelColor` from body lightness only, drawn in `iPlayrScreen.swift` in both modes; contact sheets show identical hardware per cell across Dark/Light; test `SelectionStateTests.testNoThemeForcesAMode` | Simulator grids tonight |
| I | Atmosphere uses per-mode clamp and text colour | Done | `Core/Theme/ArtworkAtmosphere.swift` `AtmosphereSpec.make`: `tokens.mode.isDark` → L 0.28–0.38 / chroma 0.12 or 0.16 and white text, else L 0.86–0.92 / chroma 0.08 and black text; layered over `tokens.screenBackground`; `PlayerView.swift` gates on `theme.theme.atmosphere != .off && contrast != .increased` | Now Playing screenshots for 17, 18, 20 tonight |
| J | Visual corrections 1–5 (Spec §7) | Done | 1: `iPodButtons.swift` `WheelLook.centerFill = body.color`, Classic stroke 1 pt at 40%. 2: `MainScreen.swift` `edge`: dark body → white 18% rim, light → −18%, `bodyEdgeOverride` for Porcelain. 3: `WheelLook.hairline` drawn on outer ring and centre button unconditionally; conditional keyline removed. 4: no Material / glass path in `iPodButtons.swift`. 5: `Components/StatusBar.swift` `BatteryIconView` primaryText ink, `#E5484D` below 20%, no asset gradient | Visual match against the reference image tonight |
| K | Retro Color, Retro LCD, Custom, old pickers, Classic Liquid Glass path, retired assets removed with zero references | Done | `ThemeTokens.swift`, `ThemePresets.swift`, `ColorContrast.swift` deleted; `Assets.xcassets` holds only `AppIcon.appiconset` and `images`; grep for removed symbols / asset names returns only the legacy key names used by migration (`UserDefaultsKeys.legacyKeys`, `ThemeState.swift`) | — |
| L | Linux SwiftPM package, Foundation-only logic; swift build and swift test pass | Done | `ThemeCore/Package.swift`; `ThemeCore/Sources/ThemeCore` → symlink to `iPlayr/iPlayr/Core/Theme/ThemeCore` (5 files, `import Foundation` only); `swift build`: Build complete; `swift test`: Executed 13 tests, 0 failures | — |
| M | Test coverage per Spec §9; 40/40 contrast | Done | `ThemeCore/Tests/ThemeCoreTests/ThemeCoreTests.swift`: `ContrastTests.testAllFortyCombinations` (540 assertions, counter asserted), `ThemeTableTests` (every constant), `SelectionStateTests` (independence, migration, picker), `WheelGeometryTests` (style-independent hit map, 44 pt targets), `ColorMathTests`; mirror for Xcode in `iPlayr/iPlayrTests/ThemeSystemTests.swift` | Xcode `iPlayrTests` target tonight |
| N | Contact sheets from the Swift constants | Done | `scripts/contact_sheets.py` parses `ThemeTable.swift` and `ModeTokens.swift`; outputs `design/contact-dark.png`, `design/contact-light.png` (5 × 4, gallery order). Review: no cell with a hard-to-spot selected row; no light screen merging with a light body (bezel drawn) | Replace with simulator grids tonight |
| O | Static checks clean | Done | 65 Swift files brace / paren / bracket balanced; no duplicate top-level definitions; no stale symbol, key or asset references; no unused imports; ThemeCore Foundation-only; no truncated files | — |

## Divergences from the spec

None in constants. Two implementation notes:

- The Classic ring keeps its 1 px edge at wheel −10% inside the always-on hairline (Spec §7.3 replaces the *keyline*, not the ring edge).
- Live preview is held as transient `previewingThemeId` / `previewingMode` on `ThemeManager` and wins over the saved selection at render time; the pure `PickerSession` type in ThemeCore encodes the same preview / confirm / cancel machine and is what the tests exercise.

## Repository note

The project was never a git repository, so no per-item commits existed before this recovery. The repository was
initialised during recovery; Phase 1 work is committed as a baseline and every change from here on is committed per item.

## Phase 2 results — 2026-10-15, Mac and manual SideStore workflow

Environment: Apple silicon, macOS 27.0.1, Xcode 27.0 (27A266a), iOS 27.0 SDK.
Target phone: iPhone 17 on iOS 27.0.1. The user installs through SideStore and captures
screenshots manually. No simulator was launched and no app was installed on a phone by automation.

- **Passed:** all 13 ThemeCore XCTest tests on the Mac, including the 540 contrast checks.
  Command: `swift test --package-path ThemeCore --scratch-path /private/tmp/iplayr-xcode27-tests`.
- **Passed:** Release build for `generic/platform=iOS`, signing disabled.
- **Passed:** Xcode Analyze action for the Debug configuration on `generic/platform=iOS`.
  This checks compilation/analysis; it does not execute the app or its iOS tests.
- **Fixed build blockers:** `UserDefaultsKeys` now conforms to `Sendable`; `MusicLibraryStore`
  explicitly imports Foundation; `.extras` belongs to the split-screen navigation routes;
  artwork cluster ranking uses smaller typed expressions the Swift compiler can check.
- **Fixed bundle configuration:** background audio is declared as an array in `Info.plist`.
  The previous generated build setting did not appear in the built app's metadata.
- **Packaged:** `DerivedData/Artifacts/iPod-Playr-SideStore.ipa`, version 1.0 (1), arm64 device
  executable, minimum iOS 17.0. ZIP integrity, Payload layout, music privacy description, and
  background audio metadata verified. It contains no provisioning profile or code signature;
  SideStore must sign it. Rebuild with `bash scripts/build_ipa.sh`.
- **Packaging correction after the first device attempt:** SideStore 0.7.0 rejected the original
  `iPod-Playr-unsigned.ipa` twice during DownloadAppOperation, before signing. That archive
  contained nine AppleDouble metadata entries, including `Payload/._iPlayr.app`. The parser in
  the installed SideSign revision (`a731c0d5`) selects the first Payload entry whose name ends
  in `.app`, without checking that it is a directory, so the sidecar is a plausible cause of
  the invalidApp result. The corrected IPA contains zero metadata entries and exactly one
  `.app` candidate; the executable and app resources are byte-identical to the original.
  `build_ipa.sh` now suppresses resource/xattr metadata and rejects ambiguous candidates.
  Subsequent user-supplied screenshots and beta feedback establish that the app launched on the
  phone. No successful installer console was supplied. The observed Cover Flow layout defect
  is documented separately from the earlier archive-import failure.
- **Warnings observed on first compilation:** ten legacy app-icon images are unassigned in
  the asset catalog; App Intents metadata extraction is skipped because the app has no
  AppIntents dependency. Neither prevented the build. They remain unresolved.
- **Not run:** the five app-module tests in `iPlayrTests/ThemeSystemTests.swift`. The Xcode
  project still has no test target; these tests require an iOS test host and cannot execute
  through the user's ordinary SideStore install. The native SwiftPM suite is the executed suite.
- **Device beta update:** five screenshots saved; the user reports that other tested use works
  fine and explicitly requests four fixes for tomorrow. Individual migration, accessibility,
  background-playback and full-theme checks were not separately reported. The current handoff
  defines the focused follow-up; the former 40-theme screenshot checklist is not a new gate.

**2026-10-16 fix pass (Linux):** BETA-01 `8af5801`, BETA-02 `0f9312c`, BETA-03/04 `e7814dd`, icon warning `b36cce4`. Spec divergence recorded: the wheel is now 70% of body width (76% compact) in portrait and fills a trailing square in landscape, superseding the 62% / 68% in Spec §3 at the user's request after the device beta. Hit geometry (36% centre, four sectors, 8 pt slop) is unchanged. ThemeCore tests re-run on Linux after the change: 13 passed. SwiftUI had not yet been compiled at this handoff; see the later Mac results below.

The 15 October build fixed compilation and packaging only. The reviewed queue-window limit, album-title
grouping, light-atmosphere progress contrast, and immersive track-selection gaps remain open.
No application source, build configuration or IPA was modified during the later documentation-only
15 October handoff pass; its Phase 2 source changes were still uncommitted at that time.

## Mac review and follow-up fixes — 2026-10-16

Reviewed the eight remote commits `58ae10f..1c58974`, including the four beta UI fixes, unused-icon
cleanup, queue and song actions, settled seeking, the Now Playing shortcut, and documentation.
Search remains a proposal in `docs/ux/2026-10-16-search-ideation-memo.md`.

Three follow-up fixes are local and uncommitted on top of `1c58974`:

- **MAC-01:** `ThemeCore/Package.swift` declares macOS 13, resolving the reproduced availability
  error from `SeekScrubber.settleDelay: Duration` in the native Mac test build.
- **MAC-02:** `FocusScope.isPlayerScreen` identifies the player even when embedded in Cover Flow.
  `PlayerView` marks its scope and `iPlayrScreen` checks it before opening the shortcut.
- **MAC-03:** `PlayerView` flushes pending seeking before MENU navigation. Its scope's new
  `onDeactivate` callback also flushes before another scope takes the wheel, including hold MENU.
  `iPlayrButtonController.activate` invokes this callback only when the scope changes.

Executed on the Mac: 20 XCTest tests passed (including 7 seek tests and 540 contrast checks),
unsigned Debug compilation for `generic/platform=iOS` passed, and source `git diff --check` passed.
The MusicKit queue insertion and current-entry APIs compile without spelling changes. The unused
app-icon warning was absent; the App Intents metadata warning remains. SwiftPM emitted cache access
warnings under the execution sandbox but completed successfully.

No new iOS test target or UI tests were added. No new Analyze run, Release IPA, phone installation,
or device acceptance was performed. The original 15 October candidate remains the installed/artifact
reference; the build number is unchanged. The two interaction fixes, all four beta UI outcomes, and
queue behavior await manual device verification. Exact commands and durable build/test evidence are
linked from [BETA_TEST_LOG.md](BETA_TEST_LOG.md#mac-review-and-follow-up-fixes--16-october-2026).

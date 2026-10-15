# Phase 2 handoff: Mac build, verification, and beta IPA

For the team picking this up on a Mac. Everything below is self-contained; you do not need the
history of how Phase 1 was done. Read `THEME_MIGRATION_STATUS.md` for the per-item status and
`README.md` for what the app is.

## 1. Where things stand

- **App:** iPlayr, a SwiftUI + MusicKit iPod recreation. Xcode project at `iPlayr/iPlayr.xcodeproj`,
  Swift 6 language mode, iOS 17.0 deployment target, iPhone only.
- **Phase 1 (done on Linux, no Xcode):** a fixed two-choice theme system, THEME (20 presets) × MODE
  (Dark / Light). The theme logic lives in `iPlayr/iPlayr/Core/Theme/ThemeCore/` (Foundation only)
  and was compiled and unit-tested with the Linux Swift 6.0.3 toolchain through the SwiftPM package
  in `ThemeCore/`. All 13 tests pass, including 540 contrast assertions across 20 themes × 2 modes.
- **Never compiled yet:** every SwiftUI and UIKit file. Phase 1 could only check them statically.
  Expect the first Xcode build to surface a handful of diagnostics; §4 lists where to look first.
- **Reference visuals:** `design/contact-dark.png` and `design/contact-light.png` are Pillow
  renders of the 20 themes from the Swift constants. They are the intended look, not app output.

Repository notes:
- `ThemeCore/Sources/ThemeCore` is a **symlink** to `iPlayr/iPlayr/Core/Theme/ThemeCore`. Git
  preserves it on macOS. Do not replace it with a copy; the point is that Xcode and SwiftPM compile
  the same files.
- The project uses Xcode's folder-synchronised groups, so any `.swift` under `iPlayr/iPlayr/` is
  compiled automatically. `iPlayr/iPlayrTests/` is *outside* that folder on purpose (see §5).

## 2. Environment

- Xcode with the iOS 27 SDK (the target device is an iPhone 17e on iOS 27). Xcode 16 builds the
  code, but running on that device needs the matching SDK.
- An Apple Developer account for device signing.
- Enable **Developer Mode** on the iPhone (Settings › Privacy & Security › Developer Mode).
- An Apple Music subscription on the device; the app has no content without one.

## 3. First build

1. Clone, then `open iPlayr/iPlayr.xcodeproj`.
2. Target iPlayr › Signing & Capabilities: set **your** team. The committed project carries the
   original author's team id (`5H8M2557R8` in `project.pbxproj`) and bundle id `com.kerem.iPlayr`;
   change the bundle id if your team cannot sign it.
3. In the Developer portal, the App ID must have the **MusicKit** app service enabled
   (Identifiers › your App ID › App Services › MusicKit). Without it, library requests fail at
   runtime even though the build succeeds. `NSAppleMusicUsageDescription` is already set in the
   target's build settings.
4. Build for a simulator first (⌘B), then for the device.

Command-line equivalent for a fast diagnostic pass without signing:

```bash
xcodebuild -project iPlayr/iPlayr.xcodeproj -scheme iPlayr \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | grep -E 'error|warning:' | sort -u
```

Goal: zero errors, no new warnings. Record any fixes in `THEME_MIGRATION_STATUS.md` under the item
they belong to and commit per item (`theme: J …`).

## 4. Where the first build is most likely to complain

These are the spots Phase 1 could not compile. None is expected to be deep; most are one-line fixes.

| File | What to check |
| --- | --- |
| `Components/iPodButtons.swift` | `WheelLook.init(theme:)` reads `ThemeSpec` only (value type), so it needs no actor isolation; `iPlayrButtons.body` builds `WheelGeometry` and `WheelLook` inside the `GeometryReader` closure. `WheelPaintLayer.sectorPath` builds a `Path` from `WheelGeometry.sectorOutline`. The two `Task { @MainActor in … }` closures capture the view; same pattern as elsewhere in the app. |
| `Screens/Theme/ThemeView.swift` | `ThemePickerView.Row` is a private `Identifiable` enum driving `ForEach(rows)` with a `switch` in the builder. `ChoiceRow` takes `AnyView?` for its swatch. `ModeSwatch` calls `InterfaceTokens.resolve` in its body. |
| `Screens/Player/PlayerView.swift` | `platter<Content: View>(@ViewBuilder _:)` with `.background(_:in:)` and `.ultraThinMaterial`; `.animation(_, value: atmosphereSpec)` relies on `AtmosphereSpec: Hashable`; `.task(id:)` keyed on a string. |
| `Core/Theme/ArtworkAtmosphere.swift` | `actor ArtworkPaletteExtractor` with `static` helpers; `pixels.withUnsafeMutableBytes` feeding `CGContext(data:)`; `Artwork.url(width:height:)` and `URLSession.shared.data(from:)`. |
| `Core/Managers/AppleMusic/AppleMusicManager.swift` | `enqueue<Item: PlayableMusicItem>` passing `[Track]` and `[Song]` to `ApplicationMusicPlayer.Queue(for:startingAt:)`. If `Track` does not satisfy the constraint in this SDK, split into two overloads. |
| `Screens/Settings/AboutView.swift` | `async let` on a locally bound `MusicLibraryStore` inside a `taskAfterNavigation` closure. |
| `Core/Theme/Theme.swift` | `ThemeManager.init` persists then deletes legacy keys; `preview(theme:)` / `preview(mode:)` are overloads by label. |
| `Core/Theme/ThemeCore/WheelGeometry.swift` | Uses `CGPoint` / `CGFloat` via Foundation. On Apple platforms this resolves through CoreGraphics automatically. |
| `Components/StatusBar.swift` | `BatteryIconView(level:ink:)` is the new signature; `Color.hex` is defined in `Core/Theme/ColorMath+SwiftUI.swift`. |

If Swift 6 strict concurrency flags a view-struct capture in a `Task`, prefer binding the needed
`@Environment` object to a `let` before the `Task` over loosening the isolation.

## 5. Tests in Xcode

The test file exists but there is no test target yet.

1. File › New › Target › **Unit Testing Bundle**, name it exactly `iPlayrTests`, host app iPlayr.
2. Delete the generated template test file.
3. Add `iPlayr/iPlayrTests/ThemeSystemTests.swift` to that target (Target Membership: iPlayrTests only).
4. Run ⌘U. Expected: all tests pass, including the 540-assertion contrast sweep.

The same assertions already pass on Linux (`cd ThemeCore && swift test`); if a test fails only in
Xcode, the difference is the environment, not the constants. Do not change a constant to make a test
pass; record the exact pair and ratio in the status file instead.

## 6. Screenshot grids (20 themes × 2 modes)

Use a simulator whose logical width is 390 pt (iPhone 16 / 17 base models). For each theme in gallery
order (the order in `ThemeTable.all`), open the app's main menu and capture one screenshot in Dark
and one in Light. Change theme and mode in the app: Settings › App Settings › Theme / Mode.

Capture from the command line while the simulator is booted:

```bash
mkdir -p design/shots
xcrun simctl io booted screenshot design/shots/01-silverClassic-dark.png
```

Name files `NN-themeId-mode.png` (NN = 01…20, mode = dark|light). Then assemble:

```bash
python3 scripts/make_grid.py design/shots dark  design/grid-dark.png
python3 scripts/make_grid.py design/shots light design/grid-light.png
```

Compare each cell with the same cell in `design/contact-dark.png` / `contact-light.png` and with the
reference gallery image. Flag any theme where the selected row is hard to spot at arm's length, or
where a light screen visually merges with a light body (the 6 pt bezel should prevent this).

Also capture Now Playing for themes 17 (Modern Album Glow), 18 (Midnight Studio) and 20 (Liquid
Glass) in both modes with a track playing, so the artwork atmosphere is visible.

## 7. Device checks (iPhone 17e, iOS 27)

- [ ] Theme picker: scrolling the wheel over a row previews it on the whole device; centre confirms;
      MENU restores the saved theme; the tick marks the saved theme.
- [ ] Mode picker: same three behaviours.
- [ ] Changing Theme never changes Mode, and vice versa.
- [ ] Theme and Mode survive a force-quit and relaunch.
- [ ] Migration: install a build that writes the old keys, or seed `UserDefaults` with
      `presetId = "custom"`, `bodyColor = "#287EB8"`, `interfaceAppearance = "retroLcd"`; the app
      must open as Nano Blue, Dark, and the old keys must be gone afterwards.
- [ ] Tap, centre press, scroll and long-press behave identically on a Classic theme (Silver
      Classic) and a Minimal theme (Liquid Glass).
- [ ] The 90 ms press highlight on the wheel sectors and centre feels right.
- [ ] Reduce Motion: atmosphere swaps instantly. Reduce Transparency: the Now Playing platter is
      solid. Increase Contrast: atmosphere off, muted text brighter.
- [ ] Battery glyph tints `#E5484D` below 20%.
- [ ] Playback, Cover Flow and non-visual settings behave as before (they were not meant to change).

## 8. Beta IPA

Simplest for a single test phone: run from Xcode directly onto the device (⌘R) with automatic
signing. For a shareable file: Product › Archive › Distribute App › **Debugging** (development) or
**Release Testing** (ad hoc), export, and install the `.ipa` with Apple Configurator or Finder.
A development-signed IPA runs only on devices registered to the team.

Log everything you find in `BETA_TEST_LOG.md`.

## 9. Known gaps not caused by Phase 1 (do not fix tonight; log if they bite)

- In immersive Cover Flow the track list is viewable but its rows are not tappable, so Play starts
  from track 1.
- Cover Flow's own screen still uses a blurred-artwork backdrop (pre-existing); the theme system does
  not touch it.
- The colour pickers are gone by design; themes are fixed presets.

## 10. Reporting back

Fill the Phase 2 section at the bottom of `THEME_MIGRATION_STATUS.md` with: build output, test
output, both grids, Now Playing shots, any mismatch against the reference image, and anything still
unverified. Commit per checklist item.

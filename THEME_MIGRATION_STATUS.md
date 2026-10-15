# Theme + Mode migration status

Phase 1 (Linux) status as of 2026-10-15 15:50 IST. Every item was verified against the files, the Linux
SwiftPM build and tests (Swift 6.0.3 in `swift:6.0-jammy`), and the regenerated contact sheets.
Nothing SwiftUI has been compiled; that is Phase 2 on the Mac tonight.

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

## Phase 2 (Mac, tonight)

1. Xcode build, zero errors, no new warnings; fix anything Linux could not see (SwiftUI, main-actor isolation, Material).
2. Add the `iPlayrTests` Unit Testing Bundle, attach `iPlayr/iPlayrTests/ThemeSystemTests.swift`, run it.
3. 390 pt simulator screenshots: 20 themes × Dark and Light, two 5 × 4 grids.
4. Now Playing for themes 17, 18 and 20 in both modes.
5. Device checks: picker preview / confirm / cancel; theme / mode independence; relaunch persistence; migration; identical touch behaviour on Classic and Minimal; the 90 ms press feel; Reduce Motion, Reduce Transparency, Increase Contrast.

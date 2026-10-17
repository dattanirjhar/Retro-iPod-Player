import XCTest
@testable import ThemeCore

final class AlbumLightingTests: XCTestCase {
    func testAlbumGlowAndGlassHaveSeparateColorRegions() {
        let albumGlow = ThemeTable.find("modernAlbumGlow")!
        XCTAssertEqual(albumGlow.atmosphere, .ambientScreen)
        XCTAssertEqual(albumGlow.material.artworkIntensity, 0)
        XCTAssertEqual(albumGlow.material.artworkLuminance, 1)
        let frosted = ThemeTable.find("liquidGlass")!
        XCTAssertEqual(frosted.name, "Frosted")
        XCTAssertEqual(frosted.atmosphere, .off, "Frosted must keep a neutral LCD")
        XCTAssertEqual(frosted.material.artworkIntensity, 0.80, "Selected Frosted artwork intensity")
        XCTAssertEqual(frosted.material.artworkLuminance, 1.15, "Selected artwork-only luminance lift")
        XCTAssertNil(ThemeTable.find("liquidGlassClear"))
    }

    func testRetiredClearSelectionMigratesToFrostedAndPreservesMode() {
        for mode in ScreenMode.allCases {
            let selection = ThemeMigration.migrate(.init(themeId: "liquidGlassClear", modeRaw: mode.rawValue))
            XCTAssertEqual(selection.themeId, "liquidGlass")
            XCTAssertEqual(selection.mode, mode)
        }
        XCTAssertEqual(ThemeMigration.migrateTheme(.init(presetId: "liquidGlassClear")), "liquidGlass")
    }

    func testArtworkChangesScreenLightWhileKeepingVioletHardware() {
        let theme = ThemeTable.find("modernAlbumGlow")!
        let tokens = InterfaceTokens.resolve(theme: theme, mode: .dark)
        let red = RGB.hex("F02A16").oklch, blue = RGB.hex("164AF0").oklch
        let warm = AmbientScreenSpec.make(primary: red, secondary: red, screen: tokens.screenBackground, mode: .dark)
        let cool = AmbientScreenSpec.make(primary: blue, secondary: blue, screen: tokens.screenBackground, mode: .dark)
        XCTAssertNotEqual(warm.primary, cool.primary)
        XCTAssertEqual(theme.body.hex, "#1B1B23")
        XCTAssertEqual(theme.wheel.hex, "#C9C7FF")
        XCTAssertEqual(theme.accent.hex, "#6A58E0")
        XCTAssertEqual(AmbientScreenSpec.preferredIntensity, 0.80)
    }

    func testTextAndProgressRemainReadableAcrossArtworkAndScreenShapes() {
        let theme = ThemeTable.find("modernAlbumGlow")!
        let covers = ["FFFFFF", "000000", "FFFF00", "FF0000", "00FF00", "0000FF", "FF00FF", "808080"]
        for mode in ScreenMode.allCases {
            let tokens = InterfaceTokens.resolve(theme: theme, mode: mode)
            for (index, cover) in covers.enumerated() {
                let spec = AmbientScreenSpec.make(primary: RGB.hex(cover).oklch,
                                                  secondary: RGB.hex(covers[(index + 3) % covers.count]).oklch,
                                                  screen: tokens.screenBackground, mode: mode)
                let fill = spec.progressFill(accent: tokens.accent)
                for (width, height) in [(320.0, 260.0), (600.0, 300.0), (250.0, 300.0)] {
                    let side = max(width, height)
                    // Sample the actual two radial lights used by PlayerView,
                    // independently of the model's conservative overlap grid.
                    for row in 0...10 {
                        for column in 0...10 {
                            let x = Double(column) / 10, y = Double(row) / 10
                            let a = max(0, 1 - hypot((x - 0.18) * width, (y - 0.25) * height) / (side * 0.95))
                            let b = max(0, 1 - hypot((x - 0.85) * width, (y - 0.82) * height) / (side * 0.8))
                            let background = tokens.screenBackground
                                .overlaid(by: spec.primary, alpha: a * spec.primaryOpacity)
                                .overlaid(by: spec.secondary, alpha: b * spec.secondaryOpacity)
                            for opacity in [1.0, 0.78, 0.62] {
                                let text = background.overlaid(by: spec.textColor, alpha: opacity)
                                XCTAssertGreaterThanOrEqual(text.contrast(with: background), 4.5,
                                                           "\(cover) \(mode) opacity \(opacity)")
                            }
                            XCTAssertGreaterThanOrEqual(fill.contrast(with: background), 3)
                            XCTAssertGreaterThanOrEqual(fill.contrast(with: background.overlaid(by: spec.textColor, alpha: 0.24)), 3)
                        }
                    }
                }
            }
        }
    }
}

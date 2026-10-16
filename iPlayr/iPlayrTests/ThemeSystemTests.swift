import XCTest
@testable import iPlayr

/// Xcode-side theme tests. The same assertions run on Linux in
/// ThemeCore/Tests; this file exists so the Xcode `iPlayrTests` target can
/// run them against the app module. Create the Unit Testing Bundle named
/// `iPlayrTests` in Xcode and add this file to it.
@MainActor
final class ThemeSystemTests: XCTestCase {
    private func assertRatio(_ a: RGB, _ b: RGB, atLeast floor: Double, _ label: String) {
        let ratio = a.contrast(with: b)
        XCTAssertGreaterThanOrEqual(ratio, floor, "\(label): \(a.hex) on \(b.hex) = \(String(format: "%.2f", ratio)):1, need \(floor):1")
    }

    func testTwentyTwoThemes() {
        XCTAssertEqual(ThemeTable.all.count, 22)
        XCTAssertEqual(ThemeTable.defaultId, "silverClassic")
    }

    func testAllFortyFourCombinations() {
        for theme in ThemeTable.all {
            let surface = theme.glyphSurface
            assertRatio(theme.glyph, surface, atLeast: 4.5, "\(theme.name) glyph")
            for mode in ScreenMode.allCases {
                let t = InterfaceTokens.resolve(theme: theme, mode: mode)
                let tag = "\(theme.name) \(mode.title)"
                for (name, text) in [("primaryText", t.primaryText), ("secondaryText", t.secondaryText), ("mutedText", t.mutedText)] {
                    assertRatio(text, t.screenBackground, atLeast: 4.5, "\(tag) \(name) on screen")
                    assertRatio(text, t.panelBackground, atLeast: 4.5, "\(tag) \(name) on panel")
                    assertRatio(text, t.raisedPanel, atLeast: 4.5, "\(tag) \(name) on raised")
                }
                assertRatio(t.selectionText, t.selectionBackground, atLeast: 4.5, "\(tag) selection text")
                assertRatio(t.selectionBackground, t.screenBackground, atLeast: 3, "\(tag) selection bar vs screen")
                assertRatio(t.progressFill, t.progressTrack, atLeast: 3, "\(tag) fill vs track")
                assertRatio(t.progressFill, t.screenBackground, atLeast: 3, "\(tag) fill vs screen")
            }
        }
    }

    func testThemeAndModeAreIndependent() {
        let manager = ThemeManager()
        manager.setMode(.light)
        manager.setTheme("nanoBlue")
        XCTAssertEqual(manager.mode, .light)
        manager.setMode(.dark)
        XCTAssertEqual(manager.themeId, "nanoBlue")
    }

    func testPreviewConfirmCancel() {
        let manager = ThemeManager()
        manager.setTheme("silverClassic")
        manager.preview(theme: "porcelain")
        XCTAssertEqual(manager.theme.id, "porcelain", "preview is what renders")
        XCTAssertEqual(manager.savedTheme.id, "silverClassic", "nothing saved yet")
        manager.cancelPreview()
        XCTAssertEqual(manager.theme.id, "silverClassic")
        manager.preview(theme: "porcelain")
        manager.commitPreview()
        XCTAssertEqual(manager.savedTheme.id, "porcelain")
        XCTAssertEqual(UserDefaults.standard.string(forKey: UserDefaultsKeys.themeId.rawValue), "porcelain")
    }

    func testHitMapIsStyleIndependent() {
        let g = WheelGeometry(diameter: 242)
        XCTAssertEqual(g.region(at: g.center), .center)
        XCTAssertEqual(g.region(at: CGPoint(x: g.center.x, y: g.center.y - 100)), .menu)
        XCTAssertGreaterThanOrEqual(g.centerDiameter, 44)
    }
}

import XCTest
@testable import ThemeCore

/// The theme table as the product spec states it, restated here so the test
/// does not trust the source it checks. Columns: id, body, wheel, glyph,
/// accent, dark (sel bg, sel text, fill), light (sel bg, sel text, fill),
/// style, finish, atmosphere, compact.
private let expectedThemes: [(String, String, String, String, String, [String], [String], RingStyle, WheelFinish, Atmosphere, Bool)] = [
    ("silverClassic", "C9CED4", "F3F5F7", "58616B", "2B6FC8", ["2B6FC8", "FFFFFF", "3C7FD5"], ["2B6FC8", "FFFFFF", "2B6FC8"], .classic, .satin, .off, false),
    ("blackClassic", "17191D", "252A31", "E2E6EB", "2B6FC8", ["2B6FC8", "FFFFFF", "3C7FD5"], ["2B6FC8", "FFFFFF", "2B6FC8"], .classic, .gloss, .off, false),
    ("signatureWhite", "F2F2EF", "FFFFFF", "6B737D", "2B6FC8", ["2B6FC8", "FFFFFF", "3C7FD5"], ["2B6FC8", "FFFFFF", "2B6FC8"], .classic, .gloss, .off, false),
    ("graphiteClassic", "43474D", "16181B", "C9CED4", "2B6FC8", ["2B6FC8", "FFFFFF", "3C7FD5"], ["2B6FC8", "FFFFFF", "2B6FC8"], .classic, .satin, .off, false),
    ("u2RedWheel", "111215", "B93248", "FFFFFF", "B93248", ["B93248", "FFFFFF", "D1566C"], ["B93248", "FFFFFF", "B93248"], .classic, .gloss, .off, false),
    ("productRedBody", "A7193F", "F3F5F7", "58616B", "2B6FC8", ["2B6FC8", "FFFFFF", "3C7FD5"], ["2B6FC8", "FFFFFF", "2B6FC8"], .classic, .satin, .off, false),
    ("miniGold", "D9C38E", "ECEEF0", "7A6330", "8A6A1F", ["8A6A1F", "FFFFFF", "9E7924"], ["8A6A1F", "FFFFFF", "8A6A1F"], .classic, .satin, .off, true),
    ("miniPink", "E9A9C3", "ECEEF0", "9C4870", "A3406E", ["A3406E", "FFFFFF", "C05F8D"], ["A3406E", "FFFFFF", "A3406E"], .classic, .satin, .off, true),
    ("miniBlue", "8FBBDB", "ECEEF0", "2F6A94", "2C6A99", ["2C6A99", "FFFFFF", "3585BD"], ["2C6A99", "FFFFFF", "2C6A99"], .classic, .satin, .off, true),
    ("miniGreen", "A8D08F", "ECEEF0", "387028", "3B7A2C", ["3B7A2C", "FFFFFF", "458E31"], ["3B7A2C", "FFFFFF", "3B7A2C"], .classic, .satin, .off, true),
    ("nanoBlue", "287EB8", "F3F5F7", "4D5A66", "235D92", ["26669E", "FFFFFF", "3084C6"], ["235D92", "FFFFFF", "235D92"], .classic, .satin, .off, true),
    ("nanoPink", "D66F97", "F3F5F7", "4D5A66", "934066", ["9B446A", "FFFFFF", "BB6586"], ["934066", "FFFFFF", "934066"], .classic, .satin, .off, true),
    ("nanoGreen", "56A779", "F3F5F7", "4D5A66", "235D48", ["276D54", "FFFFFF", "30916F"], ["235D48", "FFFFFF", "235D48"], .classic, .satin, .off, true),
    ("nanoPurple", "6E4BA8", "F3F5F7", "4D5A66", "6E4BA8", ["724FB0", "FFFFFF", "8D73C2"], ["6E4BA8", "FFFFFF", "6E4BA8"], .classic, .satin, .off, true),
    ("nanoOrange", "E7792B", "F3F5F7", "4D5A66", "B4541A", ["B4541A", "FFFFFF", "CC6020"], ["B4541A", "FFFFFF", "B4541A"], .classic, .satin, .off, true),
    ("nanoYellow", "E9C63C", "F3F5F7", "4D5A66", "8A6D00", ["E9C63C", "1D2228", "E9C63C"], ["8A6D00", "FFFFFF", "8A6D00"], .classic, .satin, .off, true),
    ("modernAlbumGlow", "1B1B23", "C9C7FF", "F1F0FA", "6A58E0", ["6A58E0", "FFFFFF", "7E6CE5"], ["6A58E0", "FFFFFF", "6A58E0"], .minimalIcons, .satin, .ambientScreen, false),
    ("midnightStudio", "121212", "2A2A2A", "FFFFFF", "1ED760", ["1ED760", "000000", "1ED760"], ["0F853E", "FFFFFF", "0F8A40"], .classic, .satin, .subtle, false),
    ("porcelain", "E7E5E0", "F8F7F4", "2B2B2B", "E5531A", ["CC4916", "FFFFFF", "E5531A"], ["CC4916", "FFFFFF", "D64D17"], .minimalIcons, .matte, .off, false),
    ("porcelainEngraved", "E7E5E0", "AEA69A", "30332F", "E5531A", ["CC4916", "FFFFFF", "E5531A"], ["CC4916", "FFFFFF", "D64D17"], .minimalIcons, .matte, .off, false),
    ("liquidGlass", "1D2329", "38444E", "F5F7F8", "0A84FF", ["0073EB", "FFFFFF", "0A84FF"], ["0073EB", "FFFFFF", "0078F5"], .minimalIcons, .satin, .off, false),
    ("liquidGlassClear", "DFE5E4", "DFE5E4", "1F2C2E", "0A84FF", ["0073EB", "FFFFFF", "0A84FF"], ["0073EB", "FFFFFF", "0078F5"], .minimalIcons, .satin, .off, false),
]

final class ThemeTableTests: XCTestCase {
    func testTwentyTwoThemesInGalleryOrder() {
        XCTAssertEqual(ThemeTable.all.count, 22)
        XCTAssertEqual(ThemeTable.all.map(\.id), expectedThemes.map { $0.0 })
        XCTAssertEqual(ThemeTable.defaultId, "silverClassic")
        XCTAssertEqual(ThemeTable.all.map(\.group), [ThemeGroup](repeating: .classic, count: 6)
                       + [ThemeGroup](repeating: .mini, count: 4) + [ThemeGroup](repeating: .nano, count: 6)
                       + [ThemeGroup](repeating: .modern, count: 6))
    }

    func testEveryThemeConstant() {
        for row in expectedThemes {
            guard let t = ThemeTable.find(row.0) else { XCTFail("missing \(row.0)"); continue }
            XCTAssertEqual(t.body.hex, "#" + row.1, "\(row.0) body")
            XCTAssertEqual(t.wheel.hex, "#" + row.2, "\(row.0) wheel")
            XCTAssertEqual(t.glyph.hex, "#" + row.3, "\(row.0) glyph")
            XCTAssertEqual(t.accent.hex, "#" + row.4, "\(row.0) accent")
            XCTAssertEqual([t.dark.selectionBackground.hex, t.dark.selectionText.hex, t.dark.progressFill.hex], row.5.map { "#" + $0 }, "\(row.0) dark")
            XCTAssertEqual([t.light.selectionBackground.hex, t.light.selectionText.hex, t.light.progressFill.hex], row.6.map { "#" + $0 }, "\(row.0) light")
            XCTAssertEqual(t.wheelStyle, row.7, "\(row.0) style")
            XCTAssertEqual(t.finish, row.8, "\(row.0) finish")
            XCTAssertEqual(t.atmosphere, row.9, "\(row.0) atmosphere")
            XCTAssertEqual(t.isCompact, row.10, "\(row.0) compact")
        }
        XCTAssertEqual(ThemeTable.find("porcelain")?.bodyEdgeOverride?.hex, "#D3D0C9")
        XCTAssertNil(ThemeTable.find("silverClassic")?.bodyEdgeOverride)
        XCTAssertEqual(ThemeTable.all.filter { $0.darkSurfaces != nil }.map(\.id), ["modernAlbumGlow", "liquidGlass", "liquidGlassClear"])
    }

    func testModeTokenConstants() {
        let d = SurfaceTokens.dark, l = SurfaceTokens.light
        XCTAssertEqual([d.screenBackground, d.panelBackground, d.raisedPanel, d.divider, d.primaryText, d.secondaryText, d.mutedText, d.progressTrack].map(\.hex),
                       ["#101317", "#202630", "#293341", "#394451", "#F5F7FA", "#BBC4CF", "#9AA5B3", "#2E3641"])
        XCTAssertEqual([l.screenBackground, l.panelBackground, l.raisedPanel, l.divider, l.primaryText, l.secondaryText, l.mutedText, l.progressTrack].map(\.hex),
                       ["#F6F7F9", "#FFFFFF", "#EEF1F4", "#D5DBE2", "#12161B", "#46505C", "#5F6A78", "#D5DBE2"])
        let mag = ThemeTable.find("modernAlbumGlow")!, lg = ThemeTable.find("liquidGlass")!
        XCTAssertEqual([mag.darkSurfaces!.screenBackground, mag.darkSurfaces!.panelBackground, mag.darkSurfaces!.raisedPanel, mag.darkSurfaces!.divider, mag.darkSurfaces!.progressTrack].map(\.hex),
                       ["#1E1838", "#272043", "#30294F", "#433A66", "#332B55"])
        XCTAssertEqual([mag.lightSurfaces!.screenBackground, mag.lightSurfaces!.panelBackground, mag.lightSurfaces!.raisedPanel, mag.lightSurfaces!.divider, mag.lightSurfaces!.progressTrack].map(\.hex),
                       ["#F4F2FB", "#FFFFFF", "#ECE9F8", "#D9D4EF", "#DCD7F2"])
        XCTAssertEqual([lg.darkSurfaces!.screenBackground, lg.darkSurfaces!.panelBackground, lg.darkSurfaces!.raisedPanel, lg.darkSurfaces!.divider, lg.darkSurfaces!.progressTrack].map(\.hex),
                       ["#161D24", "#222B33", "#2A3540", "#3E4B57", "#293540"])
        XCTAssertEqual([lg.lightSurfaces!.screenBackground, lg.lightSurfaces!.panelBackground, lg.lightSurfaces!.raisedPanel, lg.lightSurfaces!.divider, lg.lightSurfaces!.progressTrack].map(\.hex),
                       ["#F3F5F4", "#FAFCFB", "#E6EBE9", "#C9D2D0", "#D4DCDA"])
        // Overrides never touch text colours.
        let t = InterfaceTokens.resolve(theme: mag, mode: .dark)
        XCTAssertEqual([t.primaryText, t.secondaryText, t.mutedText].map(\.hex), ["#F5F7FA", "#BBC4CF", "#9AA5B3"])
        XCTAssertEqual(InterfaceTokens.resolve(theme: mag, mode: .dark, increasedContrast: true).mutedText.hex, "#BBC4CF")
    }
}

final class ContrastTests: XCTestCase {
    private func assertRatio(_ a: RGB, _ b: RGB, atLeast floor: Double, _ label: String) {
        let ratio = a.contrast(with: b)
        XCTAssertGreaterThanOrEqual(ratio, floor, "\(label): \(a.hex) on \(b.hex) = \(String(format: "%.2f", ratio)):1, need \(floor):1")
    }

    /// 22 themes × 2 modes, including opaque glass accessibility fallbacks.
    func testAllFortyFourCombinations() {
        var checks = 0
        for theme in ThemeTable.all {
            let surface = theme.glyphSurface
            assertRatio(theme.glyph, surface, atLeast: 4.5, "\(theme.name) glyph"); checks += 1
            for mode in ScreenMode.allCases {
                let t = InterfaceTokens.resolve(theme: theme, mode: mode)
                let tag = "\(theme.name) \(mode.title)"
                for (name, text) in [("primaryText", t.primaryText), ("secondaryText", t.secondaryText), ("mutedText", t.mutedText)] {
                    assertRatio(text, t.screenBackground, atLeast: 4.5, "\(tag) \(name) on screen")
                    assertRatio(text, t.panelBackground, atLeast: 4.5, "\(tag) \(name) on panel")
                    assertRatio(text, t.raisedPanel, atLeast: 4.5, "\(tag) \(name) on raised")
                    checks += 3
                }
                assertRatio(t.selectionText, t.selectionBackground, atLeast: 4.5, "\(tag) selection text")
                assertRatio(t.selectionBackground, t.screenBackground, atLeast: 3, "\(tag) selection bar vs screen")
                assertRatio(t.progressFill, t.progressTrack, atLeast: 3, "\(tag) fill vs track")
                assertRatio(t.progressFill, t.screenBackground, atLeast: 3, "\(tag) fill vs screen")
                checks += 4
            }
        }
        XCTAssertEqual(checks, 594)
    }
}

final class SelectionStateTests: XCTestCase {
    func testThemeChangeLeavesModeUnchanged() {
        var s = ThemeSelection.default
        s.mode = .light
        s.themeId = "nanoBlue"
        XCTAssertEqual(s.mode, .light)
        s.themeId = "liquidGlass"
        XCTAssertEqual(s.mode, .light)
    }

    func testModeChangeLeavesThemeUnchanged() {
        var s = ThemeSelection(themeId: "porcelain", mode: .dark)
        s.mode = .light
        XCTAssertEqual(s.themeId, "porcelain")
        s.mode = .dark
        XCTAssertEqual(s.themeId, "porcelain")
    }

    func testNoThemeForcesAMode() {
        for theme in ThemeTable.all {
            XCTAssertEqual(InterfaceTokens.resolve(theme: theme, mode: .dark).mode, .dark)
            XCTAssertEqual(InterfaceTokens.resolve(theme: theme, mode: .light).mode, .light)
        }
    }

    func testMigration() {
        typealias V = ThemeMigration.StoredValues
        for id in ["porcelain", "liquidGlass", "porcelainEngraved", "liquidGlassClear"] {
            XCTAssertEqual(ThemeMigration.migrateTheme(V(themeId: id)), id,
                           "Existing saved IDs and new variants must remain selectable")
        }
        XCTAssertEqual(ThemeMigration.migrate(V()), .default)
        XCTAssertEqual(ThemeMigration.migrate(V(themeId: "nanoPink", modeRaw: "light")), ThemeSelection(themeId: "nanoPink", mode: .light))
        XCTAssertEqual(ThemeMigration.migrateTheme(V(presetId: "midnightStudio")), "midnightStudio")
        XCTAssertEqual(ThemeMigration.migrateTheme(V(presetId: "custom", bodyHex: "#287EB8")), "nanoBlue")
        XCTAssertEqual(ThemeMigration.migrateTheme(V(presetId: "custom", bodyHex: "e7e5e0")), "porcelain")
        XCTAssertEqual(ThemeMigration.migrateTheme(V(presetId: "custom", bodyHex: "#123456")), "silverClassic")
        XCTAssertEqual(ThemeMigration.migrateTheme(V(presetId: "custom")), "silverClassic")
        XCTAssertEqual(ThemeMigration.migrateTheme(V(themeId: "notATheme", presetId: "u2RedWheel")), "u2RedWheel")
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "dark")), .dark)
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "light")), .light)
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "retroColor")), .dark)
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "retroLcd")), .dark)
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "day")), .light)
        XCTAssertEqual(ThemeMigration.migrateMode(V(interfaceRaw: "night")), .dark)
        XCTAssertEqual(ThemeMigration.migrateMode(V(modeRaw: "light", interfaceRaw: "retroLcd")), .light)
    }

    func testPickerPreviewConfirmCancel() {
        var session = PickerSession(saved: "silverClassic")
        XCTAssertEqual(session.effective, "silverClassic")
        XCTAssertFalse(session.isPreviewing)

        session.preview("nanoBlue")
        XCTAssertEqual(session.effective, "nanoBlue", "wheel movement previews live")
        XCTAssertEqual(session.saved, "silverClassic", "nothing persisted yet")
        XCTAssertTrue(session.isPreviewing)

        XCTAssertEqual(session.cancel(), "silverClassic", "MENU restores the saved value")
        XCTAssertEqual(session.effective, "silverClassic")
        XCTAssertFalse(session.isPreviewing)

        session.preview("porcelain")
        XCTAssertEqual(session.confirm(), "porcelain", "centre button persists the preview")
        XCTAssertEqual(session.saved, "porcelain")
        XCTAssertEqual(session.effective, "porcelain")
        XCTAssertFalse(session.isPreviewing)

        session.preview("porcelain")
        XCTAssertFalse(session.isPreviewing, "previewing the saved value is not a change")
    }
}

final class WheelGeometryTests: XCTestCase {
    func testHitMapIsStyleIndependent() {
        let classic = ThemeTable.find("silverClassic")!, minimal = ThemeTable.find("liquidGlass")!
        XCTAssertEqual(classic.wheelStyle, .classic)
        XCTAssertEqual(minimal.wheelStyle, .minimalIcons)
        // Geometry takes no style, so both themes share one map at any diameter.
        let g1 = WheelGeometry(diameter: 242), g2 = WheelGeometry(diameter: 242)
        XCTAssertEqual(g1, g2)
        for x in stride(from: 0, through: 258, by: 6) {
            for y in stride(from: 0, through: 258, by: 6) {
                let p = CGPoint(x: CGFloat(x), y: CGFloat(y))
                XCTAssertEqual(g1.region(at: p), g2.region(at: p))
            }
        }
    }

    func testRegionsAndTargets() {
        let g = WheelGeometry(diameter: 240)
        let c = g.center
        XCTAssertEqual(g.region(at: c), .center)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x, y: c.y - 100)), .menu)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x + 100, y: c.y)), .next)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x, y: c.y + 100)), .playPause)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x - 100, y: c.y)), .previous)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x, y: c.y - 126)), .menu, "8pt slop outside the edge")
        XCTAssertEqual(g.region(at: CGPoint(x: c.x, y: c.y - 130)), WheelRegion.none)
        XCTAssertEqual(g.region(at: CGPoint(x: c.x + 60, y: c.y - 60)), .next, "45° boundary belongs to next")
        XCTAssertGreaterThanOrEqual(g.centerDiameter, 44)
        XCTAssertGreaterThanOrEqual(g.outerRadius - g.centerRadius + WheelGeometry.slop, 44, "sector depth")
        XCTAssertEqual(g.sectorOutline(for: .menu).count, 50)
        XCTAssertTrue(g.sectorOutline(for: .center).isEmpty)
    }
}

final class ColorMathTests: XCTestCase {
    func testHexRoundTrip() {
        XCTAssertEqual(RGB(hex: "#2B6FC8")?.hex, "#2B6FC8")
        XCTAssertEqual(RGB(hex: "2b6fc8")?.hex, "#2B6FC8")
        XCTAssertNil(RGB(hex: "nope"))
        XCTAssertEqual(RGB.white.contrast(with: .black), 21, accuracy: 0.001)
    }

    func testLightnessStep() {
        XCTAssertEqual(RGB.hex("C9CED4").adjustingLightness(by: 0.06).hex, "#DADDE2")
        XCTAssertEqual(RGB.hex("C9CED4").adjustingLightness(by: -0.06).hex, "#B8BFC6")
        XCTAssertTrue(RGB.hex("C9CED4").isLight)
        XCTAssertFalse(RGB.hex("17191D").isLight)
    }
}

final class SeekScrubberTests: XCTestCase {
    func testStepIsOneSixtiethWithOneSecondFloor() {
        XCTAssertEqual(SeekScrubber(duration: 300).stepSize, 5)
        XCTAssertEqual(SeekScrubber(duration: 30).stepSize, 1)
    }

    func testFirstClickStartsFromLivePositionThenAccumulates() {
        var s = SeekScrubber(duration: 300)
        XCTAssertFalse(s.isScrubbing)
        s.move(by: 1, from: 100)
        XCTAssertEqual(s.pending, 105)
        XCTAssertTrue(s.isScrubbing)
        s.move(by: 2, from: 999)
        XCTAssertEqual(s.pending, 115, "later clicks ignore the live position")
        s.move(by: -5, from: 0)
        XCTAssertEqual(s.pending, 90)
    }

    func testClampsToTrack() {
        var s = SeekScrubber(duration: 300)
        s.move(by: -3, from: 4)
        XCTAssertEqual(s.pending, 0)
        s.move(by: 100, from: 0)
        XCTAssertEqual(s.pending, 300)
    }

    func testCommitReturnsTargetOnceAndClears() {
        var s = SeekScrubber(duration: 300)
        XCTAssertNil(s.commit())
        s.move(by: 3, from: 10)
        XCTAssertEqual(s.commit(), 25)
        XCTAssertNil(s.pending)
        XCTAssertNil(s.commit())
    }

    func testCancelDropsPending() {
        var s = SeekScrubber(duration: 300)
        s.move(by: 1, from: 10)
        s.cancel()
        XCTAssertFalse(s.isScrubbing)
    }

    func testDisplayedPositionPrefersPending() {
        var s = SeekScrubber(duration: 200)
        XCTAssertEqual(s.displayedPosition(live: 42), 42)
        s.move(by: 1, from: 42)
        XCTAssertEqual(s.displayedPosition(live: 60), 45.333, accuracy: 0.01)
    }

    func testSettleDelay() {
        XCTAssertEqual(SeekScrubber.settleDelay, .milliseconds(400))
    }
}

final class CoverFlowTests: XCTestCase {
    func testPlaybackHidesBrowsingWithoutEndingTheSession() {
        var flow = CoverFlowPresentation()
        flow.present()
        XCTAssertTrue(flow.isVisible)
        XCTAssertTrue(flow.beginPlayback())
        XCTAssertTrue(flow.isPresented, "Keep the album/track views mounted during normal Now Playing")
        XCTAssertFalse(flow.isVisible)
        flow.resume()
        XCTAssertTrue(flow.isVisible, "MENU returns to the same immersive session")
    }

    func testPlayRequestsOnlyStartFromVisibleBrowsing() {
        var flow = CoverFlowPresentation()
        XCTAssertFalse(flow.beginPlayback())
        flow.present()
        XCTAssertTrue(flow.beginPlayback())
        XCTAssertFalse(flow.beginPlayback(), "Repeated taps must not push another player")
    }

    func testDismissWhilePlayingCannotReopenTheSession() {
        var flow = CoverFlowPresentation()
        flow.present()
        flow.beginPlayback()
        flow.dismiss()
        flow.resume()
        XCTAssertFalse(flow.isPresented)
        XCTAssertFalse(flow.isVisible)
    }

    func testDenseFanKeepsFartherAlbumsDistinctAndSymmetric() {
        let positions = (0...5).map { CoverFlowLayout.horizontalOffset(position: Double($0), coverSize: 200) }
        XCTAssertEqual(positions.first, 0)
        for index in 1..<positions.count {
            XCTAssertGreaterThan(positions[index], positions[index - 1], "Farther covers must not collapse onto the same offset")
            XCTAssertEqual(CoverFlowLayout.horizontalOffset(position: -Double(index), coverSize: 200), -positions[index])
        }
        // At the approved 0.70 spacing the projected nearest edge has only a
        // small gap; farther albums continue at the approved 0.36 stack step.
        let neighbourHalfWidth = cos(63 * .pi / 180) * 0.85 * 100
        XCTAssertLessThan(positions[1] - neighbourHalfWidth - 100, 5)
        XCTAssertEqual(positions[1], 140, accuracy: 0.0001)
        XCTAssertEqual(positions[2] - positions[1], 72, accuracy: 0.0001)
    }

    func testFanIsContinuousWhenAnAlbumPassesTheNeighbourPosition() {
        let before = CoverFlowLayout.horizontalOffset(position: 0.999, coverSize: 200)
        let after = CoverFlowLayout.horizontalOffset(position: 1.001, coverSize: 200)
        XCTAssertLessThan(abs(after - before), 1, "Swiping must not jump between spacing segments")
        XCTAssertEqual(CoverFlowLayout.horizontalOffset(position: 1, coverSize: 100),
                       CoverFlowLayout.horizontalOffset(position: 1, coverSize: 200) / 2)
    }
}

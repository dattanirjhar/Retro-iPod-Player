import Foundation

enum ThemeGroup: String, CaseIterable, Sendable {
    case classic = "Classic"
    case mini = "Mini"
    case nano = "Nano"
    case modern = "Modern"
}

enum RingStyle: String, CaseIterable, Identifiable, Sendable {
    case classic, minimalIcons
    var id: String { rawValue }
    var title: String { self == .classic ? "Classic" : "Minimal + Icons" }
}

enum WheelFinish: String, CaseIterable, Sendable {
    case satin, gloss, matte
}

enum Atmosphere: String, CaseIterable, Sendable {
    case off, subtle, rich
}

/// Selection and progress colours for one theme in one mode. Stored, not derived.
struct ModeAccent: Hashable, Sendable {
    let selectionBackground: RGB
    let selectionText: RGB
    let progressFill: RGB
}

/// A theme's screen-surface override for one mode. Text colours are never overridden.
struct SurfaceOverride: Hashable, Sendable {
    let screenBackground: RGB
    let panelBackground: RGB
    let raisedPanel: RGB
    let divider: RGB
    let progressTrack: RGB
}

/// One of the twenty fixed themes: hardware plus accent constants.
struct ThemeSpec: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let group: ThemeGroup
    let body: RGB
    let wheel: RGB
    /// Label colour on its real surface: the ring fill for Classic, the body for Minimal.
    let glyph: RGB
    /// The base accent, shown by the picker's swatch dot.
    let accent: RGB
    let dark: ModeAccent
    let light: ModeAccent
    let wheelStyle: RingStyle
    let finish: WheelFinish
    let atmosphere: Atmosphere
    /// Mini and nano bodies draw the wheel at 68% instead of 62%.
    let isCompact: Bool
    /// Porcelain draws a fixed edge instead of body −18%.
    let bodyEdgeOverride: RGB?
    let darkSurfaces: SurfaceOverride?
    let lightSurfaces: SurfaceOverride?

    func accent(for mode: ScreenMode) -> ModeAccent { mode == .dark ? dark : light }
    func surfaceOverride(for mode: ScreenMode) -> SurfaceOverride? { mode == .dark ? darkSurfaces : lightSurfaces }
}

enum ThemeTable {
    static let defaultId = "silverClassic"

    static func find(_ id: String) -> ThemeSpec? { all.first { $0.id == id } }
    static var defaultTheme: ThemeSpec { find(defaultId)! }
    static func themes(in group: ThemeGroup) -> [ThemeSpec] { all.filter { $0.group == group } }

    static let modernAlbumGlowDark = SurfaceOverride(
        screenBackground: .hex("1E1838"), panelBackground: .hex("272043"), raisedPanel: .hex("30294F"),
        divider: .hex("433A66"), progressTrack: .hex("332B55"))
    static let modernAlbumGlowLight = SurfaceOverride(
        screenBackground: .hex("F4F2FB"), panelBackground: .hex("FFFFFF"), raisedPanel: .hex("ECE9F8"),
        divider: .hex("D9D4EF"), progressTrack: .hex("DCD7F2"))
    static let liquidGlassDark = SurfaceOverride(
        screenBackground: .hex("14263F"), panelBackground: .hex("1B2F4C"), raisedPanel: .hex("233A59"),
        divider: .hex("33496D"), progressTrack: .hex("233650"))
    static let liquidGlassLight = SurfaceOverride(
        screenBackground: .hex("F1F5FA"), panelBackground: .hex("FFFFFF"), raisedPanel: .hex("E7EEF7"),
        divider: .hex("D0DCEA"), progressTrack: .hex("D3DEEB"))

    // One line per theme, in the reference gallery's order. The contact-sheet
    // script parses these literals directly, so keep the shape unchanged.
    private static func theme(_ id: String, _ name: String, _ group: ThemeGroup,
                              body: String, wheel: String, glyph: String, accent: String,
                              dark: (String, String, String), light: (String, String, String),
                              style: RingStyle, finish: WheelFinish, atmosphere: Atmosphere, compact: Bool,
                              edge: String? = nil, darkSurfaces: SurfaceOverride? = nil,
                              lightSurfaces: SurfaceOverride? = nil) -> ThemeSpec {
        ThemeSpec(id: id, name: name, group: group,
                  body: .hex(body), wheel: .hex(wheel), glyph: .hex(glyph), accent: .hex(accent),
                  dark: ModeAccent(selectionBackground: .hex(dark.0), selectionText: .hex(dark.1), progressFill: .hex(dark.2)),
                  light: ModeAccent(selectionBackground: .hex(light.0), selectionText: .hex(light.1), progressFill: .hex(light.2)),
                  wheelStyle: style, finish: finish, atmosphere: atmosphere, isCompact: compact,
                  bodyEdgeOverride: edge.map { RGB.hex($0) }, darkSurfaces: darkSurfaces, lightSurfaces: lightSurfaces)
    }

    static let all: [ThemeSpec] = [
        theme("silverClassic", "Silver Classic", .classic, body: "C9CED4", wheel: "F3F5F7", glyph: "58616B", accent: "2B6FC8",
              dark: ("2B6FC8", "FFFFFF", "3C7FD5"), light: ("2B6FC8", "FFFFFF", "2B6FC8"),
              style: .classic, finish: .satin, atmosphere: .off, compact: false),
        theme("blackClassic", "Black Classic", .classic, body: "17191D", wheel: "252A31", glyph: "E2E6EB", accent: "2B6FC8",
              dark: ("2B6FC8", "FFFFFF", "3C7FD5"), light: ("2B6FC8", "FFFFFF", "2B6FC8"),
              style: .classic, finish: .gloss, atmosphere: .off, compact: false),
        theme("signatureWhite", "Signature White", .classic, body: "F2F2EF", wheel: "FFFFFF", glyph: "6B737D", accent: "2B6FC8",
              dark: ("2B6FC8", "FFFFFF", "3C7FD5"), light: ("2B6FC8", "FFFFFF", "2B6FC8"),
              style: .classic, finish: .gloss, atmosphere: .off, compact: false),
        theme("graphiteClassic", "Graphite Classic", .classic, body: "43474D", wheel: "16181B", glyph: "C9CED4", accent: "2B6FC8",
              dark: ("2B6FC8", "FFFFFF", "3C7FD5"), light: ("2B6FC8", "FFFFFF", "2B6FC8"),
              style: .classic, finish: .satin, atmosphere: .off, compact: false),
        theme("u2RedWheel", "U2 Red Wheel", .classic, body: "111215", wheel: "B93248", glyph: "FFFFFF", accent: "B93248",
              dark: ("B93248", "FFFFFF", "D1566C"), light: ("B93248", "FFFFFF", "B93248"),
              style: .classic, finish: .gloss, atmosphere: .off, compact: false),
        theme("productRedBody", "Product Red Body", .classic, body: "A7193F", wheel: "F3F5F7", glyph: "58616B", accent: "2B6FC8",
              dark: ("2B6FC8", "FFFFFF", "3C7FD5"), light: ("2B6FC8", "FFFFFF", "2B6FC8"),
              style: .classic, finish: .satin, atmosphere: .off, compact: false),

        theme("miniGold", "Mini Gold", .mini, body: "D9C38E", wheel: "ECEEF0", glyph: "7A6330", accent: "8A6A1F",
              dark: ("8A6A1F", "FFFFFF", "9E7924"), light: ("8A6A1F", "FFFFFF", "8A6A1F"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("miniPink", "Mini Pink", .mini, body: "E9A9C3", wheel: "ECEEF0", glyph: "9C4870", accent: "A3406E",
              dark: ("A3406E", "FFFFFF", "C05F8D"), light: ("A3406E", "FFFFFF", "A3406E"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("miniBlue", "Mini Blue", .mini, body: "8FBBDB", wheel: "ECEEF0", glyph: "2F6A94", accent: "2C6A99",
              dark: ("2C6A99", "FFFFFF", "3585BD"), light: ("2C6A99", "FFFFFF", "2C6A99"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("miniGreen", "Mini Green", .mini, body: "A8D08F", wheel: "ECEEF0", glyph: "387028", accent: "3B7A2C",
              dark: ("3B7A2C", "FFFFFF", "458E31"), light: ("3B7A2C", "FFFFFF", "3B7A2C"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),

        theme("nanoBlue", "Nano Blue", .nano, body: "287EB8", wheel: "F3F5F7", glyph: "4D5A66", accent: "235D92",
              dark: ("26669E", "FFFFFF", "3084C6"), light: ("235D92", "FFFFFF", "235D92"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("nanoPink", "Nano Pink", .nano, body: "D66F97", wheel: "F3F5F7", glyph: "4D5A66", accent: "934066",
              dark: ("9B446A", "FFFFFF", "BB6586"), light: ("934066", "FFFFFF", "934066"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("nanoGreen", "Nano Green", .nano, body: "56A779", wheel: "F3F5F7", glyph: "4D5A66", accent: "235D48",
              dark: ("276D54", "FFFFFF", "30916F"), light: ("235D48", "FFFFFF", "235D48"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("nanoPurple", "Nano Purple", .nano, body: "6E4BA8", wheel: "F3F5F7", glyph: "4D5A66", accent: "6E4BA8",
              dark: ("724FB0", "FFFFFF", "8D73C2"), light: ("6E4BA8", "FFFFFF", "6E4BA8"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("nanoOrange", "Nano Orange", .nano, body: "E7792B", wheel: "F3F5F7", glyph: "4D5A66", accent: "B4541A",
              dark: ("B4541A", "FFFFFF", "CC6020"), light: ("B4541A", "FFFFFF", "B4541A"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),
        theme("nanoYellow", "Nano Yellow", .nano, body: "E9C63C", wheel: "F3F5F7", glyph: "4D5A66", accent: "8A6D00",
              dark: ("E9C63C", "1D2228", "E9C63C"), light: ("8A6D00", "FFFFFF", "8A6D00"),
              style: .classic, finish: .satin, atmosphere: .off, compact: true),

        theme("modernAlbumGlow", "Modern Album Glow", .modern, body: "1B1B23", wheel: "C9C7FF", glyph: "F1F0FA", accent: "6A58E0",
              dark: ("6A58E0", "FFFFFF", "7E6CE5"), light: ("6A58E0", "FFFFFF", "6A58E0"),
              style: .minimalIcons, finish: .satin, atmosphere: .subtle, compact: false,
              darkSurfaces: modernAlbumGlowDark, lightSurfaces: modernAlbumGlowLight),
        theme("midnightStudio", "Midnight Studio", .modern, body: "121212", wheel: "2A2A2A", glyph: "FFFFFF", accent: "1ED760",
              dark: ("1ED760", "000000", "1ED760"), light: ("0F853E", "FFFFFF", "0F8A40"),
              style: .classic, finish: .satin, atmosphere: .subtle, compact: false),
        theme("porcelain", "Porcelain", .modern, body: "E7E5E0", wheel: "F8F7F4", glyph: "2B2B2B", accent: "E5531A",
              dark: ("CC4916", "FFFFFF", "E5531A"), light: ("CC4916", "FFFFFF", "D64D17"),
              style: .minimalIcons, finish: .matte, atmosphere: .off, compact: false, edge: "D3D0C9"),
        theme("liquidGlass", "Liquid Glass", .modern, body: "22262E", wheel: "8E96A3", glyph: "FFFFFF", accent: "0A84FF",
              dark: ("0073EB", "FFFFFF", "0A84FF"), light: ("0073EB", "FFFFFF", "0078F5"),
              style: .minimalIcons, finish: .satin, atmosphere: .rich, compact: false,
              darkSurfaces: liquidGlassDark, lightSurfaces: liquidGlassLight),
    ]
}

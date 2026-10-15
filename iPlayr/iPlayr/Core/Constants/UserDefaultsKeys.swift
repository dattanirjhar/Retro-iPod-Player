public enum UserDefaultsKeys: String {
    case themeId = "themeId"
    case mode = "mode"

    case sortOrder = "sortOrder"
    case immersiveMode = "immersiveMode"
    case language = "language"
    case hapticsEnabled = "hapticsEnabled"
    case soundsEnabled = "soundsEnabled"
    case musicMenuItems = "musicMenuItems"
    case mainMenuShortcuts = "mainMenuShortcuts"

    // Keys from earlier builds. Read once for migration, then deleted.
    case legacyCurrentTheme = "currentTheme"
    case legacyBodyColor = "bodyColor"
    case legacyRingStyle = "ringStyle"
    case legacyRingColor = "ringColor"
    case legacyWheelColor = "wheelColor"
    case legacyInterfaceAppearance = "interfaceAppearance"
    case legacyAccentColor = "accentColor"
    case legacyAtmosphere = "atmosphere"
    case legacyPresetId = "presetId"
    case legacyWheelGlyph = "wheelGlyph"
    case legacyTintedGlyphs = "tintedGlyphs"

    static let legacyKeys: [UserDefaultsKeys] = [
        .legacyCurrentTheme, .legacyBodyColor, .legacyRingStyle, .legacyRingColor, .legacyWheelColor,
        .legacyInterfaceAppearance, .legacyAccentColor, .legacyAtmosphere, .legacyPresetId,
        .legacyWheelGlyph, .legacyTintedGlyphs,
    ]
}

enum SortOrder: String, CaseIterable, Sendable {
    case alphabetical = "Alphabetical"
    case dateAdded = "Date Added"

    var next: SortOrder {
        self == .alphabetical ? .dateAdded : .alphabetical
    }
}

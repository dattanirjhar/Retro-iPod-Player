import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english
    var id: String { rawValue }
    var title: String { "English" }
    var locale: Locale { Locale(identifier: "en") }
}

/// Rows on the Appearance screen that open a picker.
enum AppearanceSetting: String, CaseIterable, Identifiable, Hashable, Sendable {
    case theme, mode, language
    var id: String { rawValue }
    var title: String {
        switch self {
        case .theme: "Theme"
        case .mode: "Mode"
        case .language: "Language"
        }
    }
}

/// Two persisted visual choices (theme, mode) plus a transient preview the
/// pickers drive while the wheel moves. Everything else is derived at render.
@MainActor
@Observable
final class ThemeManager {
    private(set) var selection: ThemeSelection
    private(set) var previewingThemeId: String?
    private(set) var previewingMode: ScreenMode?
    private(set) var immersiveMode: Bool
    private(set) var language: AppLanguage

    @ObservationIgnored private let defaults = UserDefaults.standard

    init() {
        let defaults = UserDefaults.standard
        func string(_ key: UserDefaultsKeys) -> String? { defaults.string(forKey: key.rawValue) }

        selection = ThemeMigration.migrate(ThemeMigration.StoredValues(
            themeId: string(.themeId),
            modeRaw: string(.mode),
            presetId: string(.legacyPresetId),
            bodyHex: string(.legacyBodyColor),
            interfaceRaw: string(.legacyInterfaceAppearance)
        ))
        immersiveMode = defaults.object(forKey: UserDefaultsKeys.immersiveMode.rawValue) as? Bool ?? true
        language = string(.language).flatMap(AppLanguage.init(rawValue:)) ?? .english

        persist()
        for key in UserDefaultsKeys.legacyKeys {
            defaults.removeObject(forKey: key.rawValue)
        }
    }

    // MARK: Effective values (preview wins while a picker is open)

    var themeId: String { previewingThemeId ?? selection.themeId }
    var mode: ScreenMode { previewingMode ?? selection.mode }
    var theme: ThemeSpec { ThemeTable.find(themeId) ?? ThemeTable.defaultTheme }
    var savedTheme: ThemeSpec { ThemeTable.find(selection.themeId) ?? ThemeTable.defaultTheme }
    var savedMode: ScreenMode { selection.mode }

    /// Drawn in both modes: near-black on dark bodies, a touch lighter on light ones.
    var bezelColor: Color { (theme.body.isLight ? RGB.hex("1A1D22") : RGB.hex("0B0D10")).color }

    func tokens(increasedContrast: Bool = false) -> InterfaceTokens {
        InterfaceTokens.resolve(theme: theme, mode: mode, increasedContrast: increasedContrast)
    }

    // MARK: Preview / confirm / cancel

    func preview(theme id: String) { previewingThemeId = id }
    func preview(mode: ScreenMode) { previewingMode = mode }

    func commitPreview() {
        if let id = previewingThemeId, ThemeTable.find(id) != nil { selection.themeId = id }
        if let mode = previewingMode { selection.mode = mode }
        previewingThemeId = nil
        previewingMode = nil
        persist()
    }

    func cancelPreview() {
        previewingThemeId = nil
        previewingMode = nil
    }

    // MARK: Direct setters

    func setTheme(_ id: String) {
        guard ThemeTable.find(id) != nil else { return }
        selection.themeId = id
        persist()
    }

    func setMode(_ mode: ScreenMode) {
        selection.mode = mode
        persist()
    }

    func set(_ value: AppLanguage) { language = value; persist() }
    func setImmersiveMode(_ value: Bool) { immersiveMode = value; persist() }

    private func persist() {
        defaults.set(selection.themeId, forKey: UserDefaultsKeys.themeId.rawValue)
        defaults.set(selection.mode.rawValue, forKey: UserDefaultsKeys.mode.rawValue)
        defaults.set(immersiveMode, forKey: UserDefaultsKeys.immersiveMode.rawValue)
        defaults.set(language.rawValue, forKey: UserDefaultsKeys.language.rawValue)
    }
}

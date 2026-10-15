import Foundation

/// The two persisted visual choices. Changing one never touches the other.
struct ThemeSelection: Hashable, Sendable {
    var themeId: String
    var mode: ScreenMode

    static let `default` = ThemeSelection(themeId: ThemeTable.defaultId, mode: .dark)
}

/// Maps whatever an earlier build stored onto a ThemeSelection.
enum ThemeMigration {
    struct StoredValues: Sendable {
        var themeId: String? = nil
        var modeRaw: String? = nil
        var presetId: String? = nil
        var bodyHex: String? = nil
        var interfaceRaw: String? = nil
    }

    static func migrate(_ stored: StoredValues) -> ThemeSelection {
        ThemeSelection(themeId: migrateTheme(stored), mode: migrateMode(stored))
    }

    static func migrateTheme(_ stored: StoredValues) -> String {
        if let id = stored.themeId, ThemeTable.find(id) != nil { return id }
        if let preset = stored.presetId {
            if ThemeTable.find(preset) != nil { return preset }
            if preset == "custom", let body = stored.bodyHex, let rgb = RGB(hex: body),
               let match = ThemeTable.all.first(where: { $0.body == rgb }) {
                return match.id
            }
        }
        return ThemeTable.defaultId
    }

    static func migrateMode(_ stored: StoredValues) -> ScreenMode {
        if let raw = stored.modeRaw, let mode = ScreenMode(rawValue: raw) { return mode }
        switch stored.interfaceRaw {
        case "light", "day": return .light
        case "dark", "night", "retroColor", "retroLcd": return .dark
        default: return .dark
        }
    }
}

/// Preview / confirm / cancel state for a picker. The wheel previews a value
/// live; the centre button confirms; MENU cancels back to the saved value.
struct PickerSession<Value: Equatable>: Equatable {
    private(set) var saved: Value
    private(set) var preview: Value?

    init(saved: Value) {
        self.saved = saved
    }

    var effective: Value { preview ?? saved }
    var isPreviewing: Bool { preview != nil && preview != saved }

    mutating func preview(_ value: Value) {
        preview = value
    }

    /// Makes the preview the saved value and returns it.
    @discardableResult
    mutating func confirm() -> Value {
        if let preview { saved = preview }
        preview = nil
        return saved
    }

    /// Drops the preview and returns the saved value.
    @discardableResult
    mutating func cancel() -> Value {
        preview = nil
        return saved
    }
}

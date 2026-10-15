import Foundation

/// The screen interface mode. Controls surfaces, text, divider and progress
/// track only; the body, bezel and wheel never read it.
enum ScreenMode: String, CaseIterable, Identifiable, Sendable {
    case dark, light

    var id: String { rawValue }
    var title: String { self == .dark ? "Dark" : "Light" }
    var isDark: Bool { self == .dark }
}

/// Surface and text tokens for one mode.
struct SurfaceTokens: Hashable, Sendable {
    let screenBackground: RGB
    let panelBackground: RGB
    let raisedPanel: RGB
    let divider: RGB
    let primaryText: RGB
    let secondaryText: RGB
    let mutedText: RGB
    let progressTrack: RGB

    static let dark = SurfaceTokens(
        screenBackground: .hex("101317"), panelBackground: .hex("202630"), raisedPanel: .hex("293341"),
        divider: .hex("394451"), primaryText: .hex("F5F7FA"), secondaryText: .hex("BBC4CF"),
        mutedText: .hex("9AA5B3"), progressTrack: .hex("2E3641")
    )

    static let light = SurfaceTokens(
        screenBackground: .hex("F6F7F9"), panelBackground: .hex("FFFFFF"), raisedPanel: .hex("EEF1F4"),
        divider: .hex("D5DBE2"), primaryText: .hex("12161B"), secondaryText: .hex("46505C"),
        mutedText: .hex("5F6A78"), progressTrack: .hex("D5DBE2")
    )

    /// Applies a theme's surface override; text colours stay the mode's own.
    func applying(_ override: SurfaceOverride?) -> SurfaceTokens {
        guard let o = override else { return self }
        return SurfaceTokens(
            screenBackground: o.screenBackground, panelBackground: o.panelBackground, raisedPanel: o.raisedPanel,
            divider: o.divider, primaryText: primaryText, secondaryText: secondaryText,
            mutedText: mutedText, progressTrack: o.progressTrack
        )
    }
}

extension ScreenMode {
    var defaultSurfaces: SurfaceTokens { self == .dark ? .dark : .light }
}

/// Everything a screen needs, resolved from one theme and one mode.
struct InterfaceTokens: Hashable, Sendable {
    let mode: ScreenMode
    let accent: RGB
    let screenBackground: RGB
    let panelBackground: RGB
    let raisedPanel: RGB
    let divider: RGB
    let primaryText: RGB
    let secondaryText: RGB
    let mutedText: RGB
    let progressTrack: RGB
    let selectionBackground: RGB
    let selectionText: RGB
    let progressFill: RGB

    static func resolve(theme: ThemeSpec, mode: ScreenMode, increasedContrast: Bool = false) -> InterfaceTokens {
        let surfaces = mode.defaultSurfaces.applying(theme.surfaceOverride(for: mode))
        let accent = theme.accent(for: mode)
        return InterfaceTokens(
            mode: mode,
            accent: theme.accent,
            screenBackground: surfaces.screenBackground,
            panelBackground: surfaces.panelBackground,
            raisedPanel: surfaces.raisedPanel,
            divider: surfaces.divider,
            primaryText: surfaces.primaryText,
            secondaryText: surfaces.secondaryText,
            mutedText: increasedContrast ? surfaces.secondaryText : surfaces.mutedText,
            progressTrack: surfaces.progressTrack,
            selectionBackground: accent.selectionBackground,
            selectionText: accent.selectionText,
            progressFill: accent.progressFill
        )
    }
}

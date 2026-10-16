import Foundation

/// Broad, matte artwork light inside Now Playing. Glass has a separate artwork
/// backdrop under its wheel and never uses this screen effect.
struct AmbientScreenSpec: Hashable, Sendable {
    let primary: RGB
    let secondary: RGB
    let screen: RGB
    let textColor: RGB
    private(set) var intensity: Double

    static let preferredIntensity = 0.80
    var primaryOpacity: Double { intensity * 0.5 }
    var secondaryOpacity: Double { intensity * 0.4 }

    static func make(primary: OKLCH, secondary: OKLCH, screen: RGB, mode: ScreenMode) -> Self {
        func clamp(_ source: OKLCH) -> RGB {
            var color = source
            color.l = mode.isDark ? min(max(color.l, 0.46), 0.62) : min(max(color.l, 0.68), 0.82)
            color.c = min(color.c, mode.isDark ? 0.16 : 0.12)
            return RGB(oklch: color).quantized()
        }
        var spec = Self(primary: clamp(primary), secondary: clamp(secondary), screen: screen,
                        textColor: mode.isDark ? .white : .black, intensity: preferredIntensity)
        // Protect primary, secondary and muted text across both overlapping
        // lights, including the fully illuminated region of each gradient.
        while spec.worstTextContrast < 4.5 && spec.intensity > 0 {
            spec.intensity = max(0, spec.intensity - 0.05)
        }
        return spec
    }

    /// Every combination of light contribution, independent of view size,
    /// gradient centres and portrait/landscape layout.
    var backgroundSamples: [RGB] {
        (0...10).flatMap { a in
            (0...10).map { b in
                screen.overlaid(by: primary, alpha: primaryOpacity * Double(a) / 10)
                    .overlaid(by: secondary, alpha: secondaryOpacity * Double(b) / 10)
            }
        }
    }

    var worstTextContrast: Double {
        backgroundSamples.flatMap { background in
            [1.0, 0.78, 0.62].map { opacity in
                background.overlaid(by: textColor, alpha: opacity).contrast(with: background)
            }
        }.min() ?? 0
    }

    func progressFill(accent: RGB) -> RGB {
        backgroundSamples.allSatisfy { background in
            let track = background.overlaid(by: textColor, alpha: 0.24)
            return accent.contrast(with: background) >= 3 && accent.contrast(with: track) >= 3
        } ? accent : textColor
    }
}

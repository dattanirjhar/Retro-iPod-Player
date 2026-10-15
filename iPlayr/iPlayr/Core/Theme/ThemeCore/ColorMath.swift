import Foundation

/// An sRGB colour with 0...1 components. Foundation-only so it compiles in the
/// ThemeCore package on Linux; the SwiftUI bridge lives in ColorMath+SwiftUI.
struct RGB: Hashable, Sendable {
    var r: Double
    var g: Double
    var b: Double

    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// Accepts "RRGGBB" or "#RRGGBB", any case.
    init?(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        self.init(
            r: Double((value >> 16) & 0xFF) / 255,
            g: Double((value >> 8) & 0xFF) / 255,
            b: Double(value & 0xFF) / 255
        )
    }

    /// Non-failable form for literals in the theme table.
    static func hex(_ value: String) -> RGB { RGB(hex: value) ?? .black }

    static let white = RGB(r: 1, g: 1, b: 1)
    static let black = RGB(r: 0, g: 0, b: 0)

    private func byte(_ component: Double) -> Int {
        Int(max(0, min(255, (component * 255).rounded())))
    }

    var hex: String { String(format: "#%02X%02X%02X", byte(r), byte(g), byte(b)) }

    func quantized() -> RGB {
        RGB(r: Double(byte(r)) / 255, g: Double(byte(g)) / 255, b: Double(byte(b)) / 255)
    }

    // MARK: WCAG (used by the test suite; runtime colours are stored constants)

    private static func linear(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    var luminance: Double {
        0.2126 * Self.linear(r) + 0.7152 * Self.linear(g) + 0.0722 * Self.linear(b)
    }

    func contrast(with other: RGB) -> Double {
        let mine = luminance, theirs = other.luminance
        let (hi, lo) = mine > theirs ? (mine, theirs) : (theirs, mine)
        return (hi + 0.05) / (lo + 0.05)
    }

    // MARK: HSL (body gradient, ring edge, pressed tint)

    var hsl: (h: Double, s: Double, l: Double) {
        let mx = max(r, g, b), mn = min(r, g, b)
        let l = (mx + mn) / 2
        guard mx != mn else { return (0, 0, l) }
        let d = mx - mn
        let s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn)
        var h: Double
        if mx == r {
            h = (g - b) / d
            if h < 0 { h += 6 }
        } else if mx == g {
            h = (b - r) / d + 2
        } else {
            h = (r - g) / d + 4
        }
        return (h * 60, s, l)
    }

    static func fromHSL(h: Double, s: Double, l: Double) -> RGB {
        let c = (1 - abs(2 * l - 1)) * s
        let hh = (h.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let x = c * (1 - abs((hh / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2
        let (r1, g1, b1): (Double, Double, Double)
        switch Int(hh / 60) % 6 {
        case 0: (r1, g1, b1) = (c, x, 0)
        case 1: (r1, g1, b1) = (x, c, 0)
        case 2: (r1, g1, b1) = (0, c, x)
        case 3: (r1, g1, b1) = (0, x, c)
        case 4: (r1, g1, b1) = (x, 0, c)
        default: (r1, g1, b1) = (c, 0, x)
        }
        return RGB(r: r1 + m, g: g1 + m, b: b1 + m)
    }

    /// "Light" and "dark" bodies are decided by HSL lightness.
    var isLight: Bool { hsl.l >= 0.5 }

    /// One HSL-lightness step of `delta` (0.06 = "lightened 6%"), quantised to 8 bits.
    func adjustingLightness(by delta: Double) -> RGB {
        let c = hsl
        return RGB.fromHSL(h: c.h, s: c.s, l: max(0, min(1, c.l + delta))).quantized()
    }

    func mixed(with other: RGB, amount t: Double) -> RGB {
        let k = max(0, min(1, t))
        return RGB(r: r + (other.r - r) * k, g: g + (other.g - g) * k, b: b + (other.b - b) * k)
    }

    func overlaid(by overlay: RGB, alpha: Double) -> RGB {
        mixed(with: overlay, amount: alpha)
    }
}

// MARK: - OKLab / OKLCH (artwork atmosphere)

struct OKLCH: Hashable, Sendable {
    var l: Double
    var c: Double
    /// Degrees, 0..<360.
    var h: Double

    static func hueDistance(_ a: Double, _ b: Double) -> Double {
        let d = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(d, 360 - d)
    }
}

extension RGB {
    private static func linearChannel(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    private static func encodeChannel(_ c: Double) -> Double {
        c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055
    }

    var oklab: (l: Double, a: Double, b: Double) {
        let lr = Self.linearChannel(r), lg = Self.linearChannel(g), lb = Self.linearChannel(b)
        let l = cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb)
        let m = cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb)
        let s = cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb)
        return (
            0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
        )
    }

    var oklch: OKLCH {
        let lab = oklab
        var hue = atan2(lab.b, lab.a) * 180 / .pi
        if hue < 0 { hue += 360 }
        return OKLCH(l: lab.l, c: hypot(lab.a, lab.b), h: hue)
    }

    init(oklch: OKLCH) {
        let a = oklch.c * cos(oklch.h * .pi / 180)
        let b = oklch.c * sin(oklch.h * .pi / 180)
        let l_ = oklch.l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = oklch.l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = oklch.l - 0.0894841775 * a - 1.2914855480 * b
        let l = l_ * l_ * l_, m = m_ * m_ * m_, s = s_ * s_ * s_
        let lr = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let lg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let lb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        self.init(
            r: Self.encodeChannel(max(0, min(1, lr))),
            g: Self.encodeChannel(max(0, min(1, lg))),
            b: Self.encodeChannel(max(0, min(1, lb)))
        )
    }
}

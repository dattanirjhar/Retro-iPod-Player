import CoreGraphics
import Foundation
import MusicKit
import SwiftUI
import UIKit

/// Two dominant artwork colours in OKLCH, unclamped. Clamping happens at
/// render time because it depends on the interface appearance.
struct ArtworkPalette: Hashable, Sendable {
    let primary: OKLCH
    let secondary: OKLCH
}

/// Extracts and caches a palette per artwork, off the main thread.
actor ArtworkPaletteExtractor {
    static let shared = ArtworkPaletteExtractor()

    private var cache: [String: ArtworkPalette?] = [:]
    private var inFlight: [String: Task<ArtworkPalette?, Never>] = [:]

    func palette(for artwork: Artwork, key: String) async -> ArtworkPalette? {
        if let cached = cache[key] { return cached }
        if let running = inFlight[key] { return await running.value }
        let task = Task<ArtworkPalette?, Never> { await Self.extract(from: artwork) }
        inFlight[key] = task
        let result = await task.value
        cache[key] = result
        inFlight[key] = nil
        return result
    }

    private static func extract(from artwork: Artwork) async -> ArtworkPalette? {
        guard let url = artwork.url(width: 64, height: 64),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)?.cgImage else { return nil }
        return palette(from: image)
    }

    /// Downsamples to 32×32, clusters in OKLab with k-means (k = 5), drops
    /// clusters with chroma below 0.03, and picks c1 by population × chroma and
    /// c2 as the next cluster at least 30° away in hue (or c1 shifted 25°).
    static func palette(from image: CGImage) -> ArtworkPalette? {
        let side = 32
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        let drawn: Bool = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress, width: side, height: side, bitsPerComponent: 8,
                bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: side, height: side))
            return true
        }
        guard drawn else { return nil }

        var samples: [SIMD3<Double>] = []
        samples.reserveCapacity(side * side)
        for i in stride(from: 0, to: pixels.count, by: 4) {
            let lab = RGB(r: Double(pixels[i]) / 255, g: Double(pixels[i + 1]) / 255, b: Double(pixels[i + 2]) / 255).oklab
            samples.append(SIMD3(lab.l, lab.a, lab.b))
        }
        return cluster(samples)
    }

    private struct Cluster {
        var mean: SIMD3<Double>
        var count: Int
        var chroma: Double { hypot(mean.y, mean.z) }
        var hue: Double {
            var h = atan2(mean.z, mean.y) * 180 / .pi
            if h < 0 { h += 360 }
            return h
        }
        var oklch: OKLCH { OKLCH(l: mean.x, c: chroma, h: hue) }
    }

    private static func cluster(_ samples: [SIMD3<Double>]) -> ArtworkPalette? {
        let k = 5
        guard samples.count >= k else { return nil }
        var centroids = (0..<k).map { samples[$0 * samples.count / k] }
        var assignment = [Int](repeating: 0, count: samples.count)

        for _ in 0..<12 {
            for (i, s) in samples.enumerated() {
                var best = 0
                var bestDistance = Double.greatestFiniteMagnitude
                for (j, c) in centroids.enumerated() {
                    let d = s - c
                    let distance = d.x * d.x + d.y * d.y + d.z * d.z
                    if distance < bestDistance { bestDistance = distance; best = j }
                }
                assignment[i] = best
            }
            var sums = [SIMD3<Double>](repeating: SIMD3(0, 0, 0), count: k)
            var counts = [Int](repeating: 0, count: k)
            for (i, s) in samples.enumerated() {
                sums[assignment[i]] += s
                counts[assignment[i]] += 1
            }
            for j in 0..<k where counts[j] > 0 {
                centroids[j] = sums[j] / Double(counts[j])
            }
        }

        var counts = [Int](repeating: 0, count: k)
        for a in assignment { counts[a] += 1 }
        let clusters = (0..<k).map { Cluster(mean: centroids[$0], count: counts[$0]) }
            .filter { $0.count > 0 && $0.chroma >= 0.03 }
            .sorted { Double($0.count) * $0.chroma > Double($1.count) * $1.chroma }

        guard let first = clusters.first else { return nil }
        let second = clusters.dropFirst().first { OKLCH.hueDistance($0.hue, first.hue) >= 30 }
        let secondary = second?.oklch ?? OKLCH(l: first.mean.x, c: first.chroma,
                                                h: (first.hue + 25).truncatingRemainder(dividingBy: 360))
        return ArtworkPalette(primary: first.oklch, secondary: secondary)
    }
}

/// The Now Playing background: a 160° gradient of two clamped artwork colours
/// into the screen background, under a screen-coloured overlay whose opacity
/// is raised until text behind the title and controls reaches 4.5:1.
struct AtmosphereSpec: Hashable {
    let primary: RGB
    let secondary: RGB
    let screen: RGB
    let textColor: RGB
    let overlayOpacity: Double

    static let angleDegrees = 160.0

    /// Points, in unit coordinates, behind the title block and the controls platter.
    static let textSamplePoints: [CGPoint] = [
        CGPoint(x: 0.45, y: 0.10), CGPoint(x: 0.95, y: 0.10), CGPoint(x: 0.45, y: 0.50),
        CGPoint(x: 0.95, y: 0.50), CGPoint(x: 0.70, y: 0.30),
        CGPoint(x: 0.05, y: 0.60), CGPoint(x: 0.95, y: 0.60), CGPoint(x: 0.05, y: 0.95),
        CGPoint(x: 0.95, y: 0.95), CGPoint(x: 0.50, y: 0.80),
    ]

    static func make(palette: ArtworkPalette, tokens: InterfaceTokens, atmosphere: Atmosphere) -> AtmosphereSpec {
        let dark = tokens.mode.isDark
        func clamp(_ c: OKLCH) -> RGB {
            var v = c
            if dark {
                v.l = min(max(v.l, 0.28), 0.38)
                v.c = min(v.c, atmosphere == .rich ? 0.16 : 0.12)
            } else {
                v.l = min(max(v.l, 0.86), 0.92)
                v.c = min(v.c, 0.08)
            }
            return RGB(oklch: v).quantized()
        }
        var spec = AtmosphereSpec(primary: clamp(palette.primary), secondary: clamp(palette.secondary),
                                  screen: tokens.screenBackground, textColor: dark ? .white : .black,
                                  overlayOpacity: atmosphere == .rich ? 0.35 : 0.55)
        spec = spec.raisingOverlayUntilLegible()
        return spec
    }

    /// Unit direction of the gradient (CSS convention: 0° is up, 90° is right).
    private static var direction: (x: Double, y: Double) {
        let radians = angleDegrees * .pi / 180
        return (sin(radians), -cos(radians))
    }

    var startPoint: UnitPoint { UnitPoint(x: 0.5 - Self.direction.x / 2, y: 0.5 - Self.direction.y / 2) }
    var endPoint: UnitPoint { UnitPoint(x: 0.5 + Self.direction.x / 2, y: 0.5 + Self.direction.y / 2) }

    var stops: [Gradient.Stop] {
        [.init(color: primary.color, location: 0),
         .init(color: secondary.color, location: 0.45),
         .init(color: screen.color, location: 0.85),
         .init(color: screen.color, location: 1)]
    }

    /// The raw gradient colour at a unit point, before the overlay.
    func gradientColor(at point: CGPoint) -> RGB {
        let d = Self.direction
        let s = startPoint
        let t = max(0, min(1, (point.x - s.x) * d.x + (point.y - s.y) * d.y))
        switch t {
        case ..<0.45: return primary.mixed(with: secondary, amount: t / 0.45)
        case ..<0.85: return secondary.mixed(with: screen, amount: (t - 0.45) / 0.40)
        default: return screen
        }
    }

    /// Colour actually visible at a unit point, with the overlay composited.
    func compositeColor(at point: CGPoint) -> RGB {
        gradientColor(at: point).overlaid(by: screen, alpha: overlayOpacity)
    }

    /// Raises the overlay in 0.05 steps until the lightest sampled point
    /// behind the text reaches 4.5:1 against the text colour.
    func raisingOverlayUntilLegible() -> AtmosphereSpec {
        var spec = self
        var guardCount = 0
        while spec.worstTextContrast < 4.5, spec.overlayOpacity < 1, guardCount < 20 {
            spec = AtmosphereSpec(primary: primary, secondary: secondary, screen: screen, textColor: textColor,
                                  overlayOpacity: min(1, (spec.overlayOpacity + 0.05).rounded(toPlaces: 2)))
            guardCount += 1
        }
        return spec
    }

    var worstTextContrast: Double {
        Self.textSamplePoints.map { compositeColor(at: $0).contrast(with: textColor) }.min() ?? 0
    }

    /// Progress fill on atmosphere: the accent if it reaches 3:1 against the
    /// local background behind the bar, otherwise white.
    func progressFill(accent: RGB) -> RGB {
        let local = compositeColor(at: CGPoint(x: 0.5, y: 0.62))
        return accent.contrast(with: local) >= 3 ? accent : .white
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

import SwiftUI
import MusicKit

/// Native glass on supported systems; a system-material fallback on iOS 17–25.
/// Accessibility settings always replace translucency with an opaque surface.
struct GlassWheelSurface: View {
    let fallback: RGB
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        if reduceTransparency || contrast == .increased {
            Circle().fill(fallback.color)
        } else if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(.regular, in: Circle())
        } else {
            Circle()
                .fill(.regularMaterial)
                .overlay {
                    Circle().fill(fallback.color.opacity(0.35))
                }
                .overlay {
                    Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
        }
    }
}

/// Stable ink over variable artwork and native glass. The small opaque label
/// backings use the same tested surface in native, fallback and accessible modes.
struct WheelGlyphBacking: ViewModifier {
    let look: WheelLook

    @ViewBuilder
    func body(content: Content) -> some View {
        if look.material.isGlass {
            content
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(look.wheel.color, in: Capsule())
        } else if look.material == .engraved {
            // Dark inlaid ink with a lower cut-edge highlight reads as recessed.
            content
                .shadow(color: look.wheel.color.opacity(0.45), radius: 0.35, y: -0.5)
                .shadow(color: .white.opacity(0.85), radius: 0, y: 1)
        } else {
            content
        }
    }
}

/// Blurred artwork is viewed through Frosted's dark controls.
/// No extracted light spills into the LCD or around the wheel.
struct GlassWheelArtwork: View {
    let artwork: Artwork?
    let theme: ThemeSpec
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var artworkKey: String? { artwork?.url(width: 160, height: 160)?.absoluteString }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                theme.body.color
                if let artwork {
                    ArtworkImage(artwork, width: side, height: side)
                        .scaledToFill()
                        .blur(radius: side * 0.07)
                        // Extended sRGB permits a multiplier above white without lifting the chassis.
                        .colorMultiply(Color(.sRGB, white: theme.material.artworkLuminance, opacity: 1))
                        .opacity(theme.material.artworkIntensity)
                        .id(artworkKey)
                        .transition(.opacity)
                }
            }
            .frame(width: side, height: side)
            .clipShape(Circle())
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: artworkKey)
    }
}

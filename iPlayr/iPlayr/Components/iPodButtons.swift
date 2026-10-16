import SwiftUI

// MARK: - Input model

@MainActor
final class WheelInputModel {
    var isActive = false
    var pressRegion: WheelRegion = .none
    var startLocation: CGPoint = .zero
    var lastAngle: CGFloat?
    var accumulated: CGFloat = 0
    var scrolled = false
    var longPressFired = false
    var longPressTask: Task<Void, Never>?

    static let tapSlop: CGFloat = 12
    static let degreesPerStep: CGFloat = 30
    static let longPressDuration: Duration = .milliseconds(500)

    func reset() {
        longPressTask?.cancel()
        longPressTask = nil
        isActive = false
        pressRegion = .none
        lastAngle = nil
        accumulated = 0
        scrolled = false
        longPressFired = false
    }
}

// MARK: - Appearance (paint only; the hit layer never reads it)

struct WheelLook {
    let material: WheelMaterial
    let isPorcelain: Bool
    let style: RingStyle
    let body: RGB
    let wheel: RGB
    let finish: WheelFinish
    let compact: Bool
    let glyph: RGB

    init(theme: ThemeSpec) {
        material = theme.material
        isPorcelain = theme.material == .ceramic
        style = theme.wheelStyle
        body = theme.body
        wheel = theme.wheel
        finish = theme.finish
        compact = theme.isCompact
        glyph = theme.glyph
    }

    /// Always-on 1px outline on the outer ring and the centre button.
    var hairline: Color { body.isLight ? Color.black.opacity(0.14) : Color.white.opacity(0.18) }
    var ringEdge: Color { wheel.adjustingLightness(by: -0.10).color }

    /// Porcelain keeps a ceramic centre; other themes use the body colour.
    var centerFill: Color { (isPorcelain ? wheel : body).color }

    var centerStroke: (color: Color, width: CGFloat) {
        switch style {
        case .classic: (wheel.color.opacity(0.40), 1)
        case .minimalIcons: (wheel.color.opacity(0.60), 1.5)
        }
    }

    var pressedFill: Color {
        switch style {
        case .classic: wheel.adjustingLightness(by: wheel.isLight ? -0.08 : 0.08).color
        case .minimalIcons: wheel.color.opacity(0.16)
        }
    }
}

// MARK: - The wheel

/// How the wheel picks its diameter from the space it is given.
enum WheelSizing {
    /// Portrait: a fraction of the body width (70%, 76% on compact bodies).
    case bodyWidth
    /// Landscape: fill the square the layout reserves at the trailing edge.
    case fillContainer
}

struct iPlayrButtons: View {
    var sizing: WheelSizing = .bodyWidth
    @State private var input = WheelInputModel()
    @State private var pressedRegion: WheelRegion = .none
    @State private var pressedClearTask: Task<Void, Never>?
    @Environment(iPlayrButtonController.self) private var buttonController
    @Environment(ThemeManager.self) private var theme
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    private var glassAtmosphereEnabled: Bool {
        theme.theme.material.isGlass && !reduceTransparency && contrast != .increased
    }

    var body: some View {
        GeometryReader { proxy in
            let spec = theme.theme
            // 70% of the body width, 76% on compact (mini / nano) bodies; raised
            // from 62% / 68% after the first device beta found the wheel too small.
            let ratio: CGFloat = spec.isCompact ? 0.76 : 0.70
            let available = min(proxy.size.width, proxy.size.height) - WheelGeometry.slop * 2
            let diameter: CGFloat = switch sizing {
            case .bodyWidth: min(proxy.size.width * ratio, available)
            case .fillContainer: available
            }
            let geometry = WheelGeometry(diameter: max(diameter, 44))
            let look = WheelLook(theme: spec)

            ZStack {
                if glassAtmosphereEnabled {
                    GlassWheelArtwork(artwork: playerManager.currentTrack?.artwork, theme: spec)
                        .frame(width: geometry.diameter, height: geometry.diameter)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                WheelPaintLayer(geometry: geometry, look: look, pressed: pressedRegion)
                    .allowsHitTesting(false)
                WheelLabelLayer(geometry: geometry, look: look)
                    .allowsHitTesting(false)
                hitLayer(geometry: geometry)
            }
            .frame(width: geometry.frameSize, height: geometry.frameSize)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .clipped()
    }

    // MARK: Hit layer (identical in both styles)

    private func hitLayer(geometry: WheelGeometry) -> some View {
        Color.clear
            .frame(width: geometry.frameSize, height: geometry.frameSize)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in touchChanged(value.location, geometry: geometry) }
                    .onEnded { value in touchEnded(value.location, geometry: geometry) }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Click wheel")
            .accessibilityHint("Swipe up or down to scroll. Use the actions for the buttons.")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: buttonController.scrollDown()
                case .decrement: buttonController.scrollUp()
                @unknown default: break
                }
            }
            .accessibilityAction(named: "Select") { buttonController.selectButtonPressed() }
            .accessibilityAction(named: "Menu") { buttonController.menuButtonPressed() }
            .accessibilityAction(named: "Main menu") { buttonController.menuLongPressed() }
            .accessibilityAction(named: "Play or pause") { buttonController.playPauseButtonPressed() }
            .accessibilityAction(named: "Next track") { buttonController.forwardEndAltButtonPressed() }
            .accessibilityAction(named: "Previous track") { buttonController.backwardEndAltButtonPressed() }
            .accessibilityAction(named: "Queue or song actions") { buttonController.selectLongPressed() }
            .accessibilityAction(named: "Now Playing") { buttonController.playPauseLongPressed() }
    }

    private func touchChanged(_ location: CGPoint, geometry: WheelGeometry) {
        if !input.isActive {
            input.reset()
            input.isActive = true
            input.pressRegion = geometry.region(at: location)
            input.startLocation = location
            showPressed(input.pressRegion)
            scheduleLongPress()
            return
        }

        guard geometry.radius(at: location) > geometry.centerRadius else { return }
        let angle = geometry.angle(at: location)
        guard let previous = input.lastAngle else {
            input.lastAngle = angle
            return
        }
        var theta = previous - angle
        if theta > 180 { theta -= 360 }
        if theta < -180 { theta += 360 }
        input.lastAngle = angle
        input.accumulated += theta

        let moved = hypot(location.x - input.startLocation.x, location.y - input.startLocation.y)
        if moved > WheelInputModel.tapSlop {
            input.longPressTask?.cancel()
            input.longPressTask = nil
        }

        while input.accumulated > WheelInputModel.degreesPerStep {
            buttonController.scrollUp()
            input.accumulated -= WheelInputModel.degreesPerStep
            markScrolled()
        }
        while input.accumulated < -WheelInputModel.degreesPerStep {
            buttonController.scrollDown()
            input.accumulated += WheelInputModel.degreesPerStep
            markScrolled()
        }
    }

    private func touchEnded(_ location: CGPoint, geometry: WheelGeometry) {
        defer { input.reset() }
        let region = input.pressRegion

        if input.longPressFired {
            clearPressedSoon()
            return
        }

        let moved = hypot(location.x - input.startLocation.x, location.y - input.startLocation.y)
        guard !input.scrolled, moved <= WheelInputModel.tapSlop else {
            clearPressedSoon()
            return
        }

        switch region {
        case .center: buttonController.selectButtonPressed()
        case .menu: buttonController.menuButtonPressed()
        case .next: buttonController.forwardEndAltButtonPressed()
        case .previous: buttonController.backwardEndAltButtonPressed()
        case .playPause: buttonController.playPauseButtonPressed()
        case .none: break
        }
        clearPressedSoon()
    }

    private func markScrolled() {
        input.scrolled = true
        input.longPressTask?.cancel()
        input.longPressTask = nil
        pressedRegion = .none
    }

    private func scheduleLongPress() {
        let region = input.pressRegion
        guard region == .menu || region == .center || region == .playPause else { return }
        input.longPressTask = Task { @MainActor in
            try? await Task.sleep(for: WheelInputModel.longPressDuration)
            guard !Task.isCancelled, input.isActive, !input.scrolled else { return }
            input.longPressFired = true
            switch region {
            case .menu: buttonController.menuLongPressed()
            case .center: buttonController.selectLongPressed()
            case .playPause: buttonController.playPauseLongPressed()
            default: break
            }
        }
    }

    private func showPressed(_ region: WheelRegion) {
        pressedClearTask?.cancel()
        pressedRegion = region
    }

    /// Pressed highlight stays for at least 90ms, or until release when held longer.
    private func clearPressedSoon() {
        pressedClearTask?.cancel()
        pressedClearTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(90))
            guard !Task.isCancelled else { return }
            pressedRegion = .none
        }
    }
}

// MARK: - Paint layer

private struct WheelPaintLayer: View {
    let geometry: WheelGeometry
    let look: WheelLook
    let pressed: WheelRegion

    var body: some View {
        ZStack {
            ring
            if pressed != .center && pressed != .none {
                sectorPath(for: pressed)
                    .fill(look.pressedFill)
            }
            Circle()
                .stroke(look.hairline, lineWidth: 1)
                .frame(width: geometry.diameter, height: geometry.diameter)
            centerButton
        }
        .frame(width: geometry.frameSize, height: geometry.frameSize)
    }

    private func sectorPath(for region: WheelRegion) -> Path {
        var path = Path()
        let points = geometry.sectorOutline(for: region)
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        path.closeSubpath()
        return path
    }

    @ViewBuilder
    private var ring: some View {
        switch look.style {
        case .classic:
            ZStack {
                Circle().fill(look.wheel.color)
                if look.finish == .gloss {
                    Circle().fill(
                        RadialGradient(colors: [Color.white.opacity(0.08), .clear],
                                       center: UnitPoint(x: 0.3, y: 0.28), startRadius: 0,
                                       endRadius: geometry.outerRadius * 0.9)
                    )
                }
                Circle().strokeBorder(look.ringEdge, lineWidth: 1)
            }
            .frame(width: geometry.diameter, height: geometry.diameter)
        case .minimalIcons:
            if look.material.isGlass {
                GlassWheelSurface(material: look.material, fallback: look.wheel)
                    .environment(\.colorScheme, look.body.isLight ? .light : .dark)
                    .frame(width: geometry.diameter, height: geometry.diameter)
            } else if look.isPorcelain {
                // A warm ceramic face and a shallow edge give Porcelain substance.
                Circle()
                    .fill(look.wheel.color)
                    .overlay {
                        Circle().strokeBorder(look.body.adjustingLightness(by: -0.12).color, lineWidth: 1)
                    }
                    .shadow(color: look.body.adjustingLightness(by: -0.25).color.opacity(0.18), radius: 3, y: 2)
                    .frame(width: geometry.diameter, height: geometry.diameter)
            } else if look.material == .engraved {
                Circle()
                    .strokeBorder(look.wheel.color, lineWidth: 1.5)
                    .overlay {
                        Circle().inset(by: 2).stroke(Color.white.opacity(0.65), lineWidth: 1)
                    }
                    .frame(width: geometry.diameter, height: geometry.diameter)
            } else {
                Circle()
                    .strokeBorder(look.wheel.color, lineWidth: 2)
                    .frame(width: geometry.diameter, height: geometry.diameter)
            }
        }
    }

    private var centerButton: some View {
        ZStack {
            if look.material.isGlass {
                // The centre shares the single glass disk; avoid stacking glass.
                Circle().fill(look.wheel.color.opacity(0.12))
            } else {
                Circle().fill(look.centerFill)
            }
            if pressed == .center {
                Circle().fill(look.pressedFill)
            }
            Circle().strokeBorder(look.centerStroke.color, lineWidth: look.centerStroke.width)
            Circle().stroke(look.hairline, lineWidth: 1)
            if look.isPorcelain {
                Circle().strokeBorder(look.body.adjustingLightness(by: -0.12).color, lineWidth: 1)
            }
        }
        .frame(width: geometry.centerDiameter, height: geometry.centerDiameter)
    }
}

// MARK: - Labels (paint only)

private struct WheelLabelLayer: View {
    let geometry: WheelGeometry
    let look: WheelLook

    var body: some View {
        ZStack {
            Text("MENU")
                .font(.system(size: 11, weight: .semibold))
                .tracking(11 * 0.06)
                .modifier(WheelGlyphBacking(look: look))
                .position(geometry.labelPosition(for: .menu))
            Image(systemName: ImageNames.System.forwardEndAlt)
                .font(.system(size: 14, weight: .semibold))
                .modifier(WheelGlyphBacking(look: look))
                .position(geometry.labelPosition(for: .next))
            Image(systemName: ImageNames.System.playPause)
                .font(.system(size: 14, weight: .semibold))
                .modifier(WheelGlyphBacking(look: look))
                .position(geometry.labelPosition(for: .playPause))
            Image(systemName: ImageNames.System.backwardEndAlt)
                .font(.system(size: 14, weight: .semibold))
                .modifier(WheelGlyphBacking(look: look))
                .position(geometry.labelPosition(for: .previous))
        }
        .foregroundStyle(look.glyph.color)
        .frame(width: geometry.frameSize, height: geometry.frameSize)
        .accessibilityHidden(true)
    }
}

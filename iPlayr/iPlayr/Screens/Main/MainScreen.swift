import SwiftUI
import Observation

@MainActor
@Observable
final class ImmersiveFlowState {
    private var presentation = CoverFlowPresentation()
    var isPresented: Bool { presentation.isPresented }
    var isVisible: Bool { presentation.isVisible }
    @ObservationIgnored private var onDismiss: (() -> Void)?
    @ObservationIgnored private var onPlay: ((String, Int) -> Void)?

    func present(onPlay: @escaping (String, Int) -> Void, onDismiss: @escaping () -> Void) {
        self.onPlay = onPlay
        self.onDismiss = onDismiss
        presentation.present()
    }

    func play(albumID: String, trackIndex: Int) {
        guard let onPlay, presentation.beginPlayback() else { return }
        onPlay(albumID, trackIndex)
    }

    func resume() { presentation.resume() }

    func dismiss() {
        guard isPresented else { return }
        presentation.dismiss()
        let action = onDismiss
        onDismiss = nil
        onPlay = nil
        action?()
    }
}

struct iPlayrView: View {
    @State private var iPlayrController: iPlayrButtonController = .init()
    @State private var immersiveFlow = ImmersiveFlowState()
    @Environment(ThemeManager.self) private var theme
    @Environment(AppleMusicManager.self) private var playerManager

    private var statusBarColorScheme: ColorScheme {
        guard !immersiveFlow.isVisible else { return .dark }
        let top = theme.theme.body.adjustingLightness(by: theme.theme.finish == .matte ? 0.02 : 0.06)
        return top.contrast(with: .black) >= top.contrast(with: .white) ? .light : .dark
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                deviceLayout(size: geometry.size)
                    .opacity(immersiveFlow.isVisible ? 0 : 1)
                    .allowsHitTesting(!immersiveFlow.isVisible)
                    .accessibilityHidden(immersiveFlow.isVisible)

                if immersiveFlow.isPresented {
                    CoverFlowView(
                        onExitImmersive: { immersiveFlow.dismiss() },
                        onPlayImmersive: { albumID, trackIndex in
                            immersiveFlow.play(albumID: albumID, trackIndex: trackIndex)
                        }
                    )
                        .environment(iPlayrController)
                        .environment(theme)
                        .environment(\.colorScheme, .dark)
                        .opacity(immersiveFlow.isVisible ? 1 : 0)
                        .allowsHitTesting(immersiveFlow.isVisible)
                        .accessibilityHidden(!immersiveFlow.isVisible)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ChassisBackgroundView(theme: theme.theme))
        }
        // The system status bar sits on the chassis, outside the simulated screen.
        .preferredColorScheme(statusBarColorScheme)
        .environment(\.colorScheme, theme.mode == .dark ? .dark : .light)
        .environment(\.locale, theme.language.locale)
        .onAppear {
            iPlayrController.setGlobalPlaybackHandler { action in
                Task {
                    switch action {
                    case .playPause: try? await playerManager.togglePlayPause()
                    case .forwardEndAlt: try? await playerManager.skipToNextTrack()
                    case .backwardEndAlt: try? await playerManager.skipToPreviousTrack()
                    default: break
                    }
                }
            }
        }
        .onChange(of: theme.immersiveMode) { _, enabled in
            if !enabled && immersiveFlow.isPresented { immersiveFlow.dismiss() }
        }
    }

    private func deviceLayout(size: CGSize) -> some View {
        let landscape = size.width > size.height
        let screenWidth = landscape ? min(size.height * 1.25, size.width * 0.56) : max(0, size.width - 32)
        let wheelSide = max(60, min(size.height * 0.84, size.width - screenWidth - 56))
        let portraitWheelHeight = max(60, min(size.width, size.height - 324))
        let layout = landscape ? AnyLayout(HStackLayout(spacing: 0)) : AnyLayout(VStackLayout(spacing: 0))

        // AnyLayout preserves the same screen and player instances across rotation.
        return layout {
            Spacer(minLength: 0)
                .frame(width: landscape ? 0 : nil, height: landscape ? 0 : nil)
            iPlayrScreen()
                .environment(iPlayrController)
                .environment(theme)
                .environment(immersiveFlow)
                .frame(width: screenWidth, height: 300)
            Spacer(minLength: landscape ? 16 : 12)
            iPlayrButtons(sizing: landscape ? .fillContainer : .bodyWidth)
                .environment(iPlayrController)
                .environment(theme)
                .frame(width: landscape ? wheelSide : size.width,
                       height: landscape ? wheelSide : portraitWheelHeight)
            Spacer(minLength: 0)
                .frame(width: landscape ? 0 : nil, height: landscape ? 0 : nil)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading, landscape ? 16 : 0)
        .padding(.trailing, landscape ? 20 : 0)
    }
}

/// The simulated hardware body, drawn from the theme only (mode never reaches
/// it): a vertical gradient of body ±6% (±2% matte), a 1px inner edge, and a
/// sharper highlight on gloss. Dark bodies get a white 18% rim instead of the
/// −18% edge, which would clamp to invisible black.
private struct ChassisBackgroundView: View {
    let theme: ThemeSpec

    private var gradientDelta: Double { theme.finish == .matte ? 0.02 : 0.06 }
    private var top: Color { theme.body.adjustingLightness(by: gradientDelta).color }
    private var bottom: Color { theme.body.adjustingLightness(by: -gradientDelta).color }

    private var edge: Color {
        if let override = theme.bodyEdgeOverride { return override.color }
        return theme.body.isLight
            ? theme.body.adjustingLightness(by: -0.18).color
            : Color.white.opacity(0.18)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
            if theme.finish == .gloss {
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.22), location: 0),
                        .init(color: .white.opacity(0.07), location: 0.32),
                        .init(color: .clear, location: 0.5),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .strokeBorder(edge, lineWidth: 1)
        }
        .ignoresSafeArea()
        .background(Color.black.ignoresSafeArea())
    }
}

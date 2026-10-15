import SwiftUI
import Observation

@MainActor
@Observable
final class ImmersiveFlowState {
    var isPresented = false
    @ObservationIgnored private var onDismiss: (() -> Void)?

    func present(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        isPresented = true
    }

    func dismiss() {
        guard isPresented else { return }
        isPresented = false
        let action = onDismiss
        onDismiss = nil
        action?()
    }
}

struct iPlayrView: View {
    @State private var iPlayrController: iPlayrButtonController = .init()
    @State private var immersiveFlow = ImmersiveFlowState()
    @Environment(ThemeManager.self) private var theme
    @Environment(AppleMusicManager.self) private var playerManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                deviceLayout(size: geometry.size)
                    .opacity(immersiveFlow.isPresented ? 0 : 1)
                    .allowsHitTesting(!immersiveFlow.isPresented)

                if immersiveFlow.isPresented {
                    CoverFlowView(onExitImmersive: { immersiveFlow.dismiss() })
                        .environment(iPlayrController)
                        .environment(theme)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ChassisBackgroundView(theme: theme.theme))
        }
        .preferredColorScheme(theme.mode == .dark ? .dark : .light)
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

    @ViewBuilder
    private func deviceLayout(size: CGSize) -> some View {
        if size.width > size.height {
            HStack(spacing: 12) {
                iPlayrScreen()
                    .environment(iPlayrController)
                    .environment(theme)
                    .environment(immersiveFlow)
                    .frame(width: min(size.height * 1.25, size.width * 0.56), height: 300)
                iPlayrButtons()
                    .environment(iPlayrController)
                    .environment(theme)
                    .frame(width: min(size.height * 0.78, size.width * 0.34), height: size.height * 0.78)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
        } else {
            VStack(spacing: 0) {
                Spacer()
                iPlayrScreen()
                    .environment(iPlayrController)
                    .environment(theme)
                    .environment(immersiveFlow)
                    .padding(.horizontal)
                Spacer()
                iPlayrButtons()
                    .environment(iPlayrController)
                    .environment(theme)
                Spacer()
            }
        }
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

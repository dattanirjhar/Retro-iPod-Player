import SwiftUI
import MusicKit

struct PlayerView: View {
    let source: PlaybackSource?
    let trackIndex: Int
    let isFromCoverFlow: Bool
    var initialArtwork: Artwork?
    var onDismissFromCoverFlow: (() -> Void)? = nil
    @State private var activeArtwork: Artwork?
    @Environment(\.navigate) private var navigate
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(ThemeManager.self) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    @State private var scope = FocusScope(id: "player", handledTransportActions: [.playPause, .forwardEndAlt, .backwardEndAlt])
    @State private var currentDegree: Double = 80
    @State private var currentOpacity: Double = 0
    @State private var isScaleAnimation: Bool = true
    @State private var seekTask: Task<Void, Never>?
    @State private var seekStartTime: Date?
    @State private var currentSeekSpeed: Double = 1.0
    @State private var playbackErrorMessage: String?
    @State private var mode: NowPlayingMode = .volume
    @State private var volumeLevel: Float?
    @State private var palette: ArtworkPalette?

    private static let artworkSize: CGFloat = 120

    private let initialRotation: Double = 80
    private let finalRotation: Double = 5
    private let flipDuration: Double = 0.6
    private let fadeDelay: Double = 0.3
    private let fadeDuration: Double = 0.4

    // MARK: - Theme resolution (render time only)

    private var tokens: InterfaceTokens { theme.tokens(increasedContrast: contrast == .increased) }

    /// Atmosphere is Now Playing only, at the theme's level, and off under Increase Contrast.
    private var atmosphereEnabled: Bool {
        theme.theme.atmosphere != .off && contrast != .increased
    }

    private var artworkKey: String? { activeArtwork?.url(width: 64, height: 64)?.absoluteString }

    private var atmosphereSpec: AtmosphereSpec? {
        guard atmosphereEnabled, let palette else { return nil }
        return AtmosphereSpec.make(palette: palette, tokens: tokens, atmosphere: theme.theme.atmosphere)
    }

    private var primaryTextColor: Color { atmosphereSpec?.textColor.color ?? tokens.primaryText.color }
    private var secondaryTextColor: Color { atmosphereSpec.map { $0.textColor.color.opacity(0.78) } ?? tokens.secondaryText.color }
    private var mutedTextColor: Color { atmosphereSpec.map { $0.textColor.color.opacity(0.62) } ?? tokens.mutedText.color }

    private var progressStyle: ProgressBarStyle {
        if let spec = atmosphereSpec {
            return ProgressBarStyle(track: Color.white.opacity(0.24),
                                    fill: spec.progressFill(accent: tokens.accent).color,
                                    text: spec.textColor.color)
        }
        return ProgressBarStyle(tokens: tokens)
    }

    var body: some View {
        ZStack {
            background
            playerContent
            if let playbackErrorMessage {
                errorOverlay(playbackErrorMessage)
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            if let artwork = initialArtwork {
                activeArtwork = artwork
            } else {
                activeArtwork = playerManager.currentTrack?.artwork
            }
            if !isFromCoverFlow {
                currentDegree = finalRotation
                currentOpacity = 1
                isScaleAnimation = false
            }
            setupButtonListener()
        }
        .taskAfterNavigation { await startPlayback() }
        .task(id: volumeLevel) {
            guard volumeLevel != nil else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.18)) { volumeLevel = nil }
        }
        .task(id: "\(artworkKey ?? "")|\(atmosphereEnabled)") { await loadPalette() }
        .onDisappear {
            stopSeeking()
        }
    }

    private func loadPalette() async {
        guard atmosphereEnabled, let artwork = activeArtwork, let key = artworkKey else {
            palette = nil
            return
        }
        let result = await ArtworkPaletteExtractor.shared.palette(for: artwork, key: key)
        guard !Task.isCancelled else { return }
        palette = result
    }

    private func startPlayback() async {
        guard let source else { return }
        do {
            switch source {
            case .album(let id):
                // Reuse the store's (cached) track list so the index matches the row shown.
                guard let tracks = await libraryStore.albumTracks(id: id) else {
                    throw MusicPlayerError.libraryRequestFailed(message: libraryStore.errorMessage)
                }
                try await playerManager.playTracks(tracks, fromIndex: trackIndex)
            case .playlist(let id):
                guard let tracks = await libraryStore.playlistTracks(id: id) else {
                    throw MusicPlayerError.libraryRequestFailed(message: libraryStore.errorMessage)
                }
                try await playerManager.playTracks(tracks, fromIndex: trackIndex)
            case .composer(let name):
                await libraryStore.loadSongsIfNeeded()
                try await playerManager.playSongs(libraryStore.composerSongs(name: name), fromIndex: trackIndex)
            case .allSongs:
                await libraryStore.loadSongsIfNeeded()
                try await playerManager.playSongs(libraryStore.songs ?? [], fromIndex: trackIndex)
            case .shuffleAll:
                await libraryStore.loadSongsIfNeeded()
                try await playerManager.playSongs(libraryStore.songs?.shuffled() ?? [], shuffleMode: .songs)
            case .shuffleAlbums:
                try await playerManager.playSongs(await libraryStore.songsGroupedByShuffledAlbums(), shufflingAlbums: true)
            }
        } catch {
            playbackErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Background

    /// Screen background, plus the artwork atmosphere when enabled. With no
    /// usable artwork the fallback is an 8% accent glow behind the artwork.
    private var background: some View {
        ZStack {
            tokens.screenBackground.color
            if let spec = atmosphereSpec {
                LinearGradient(stops: spec.stops, startPoint: spec.startPoint, endPoint: spec.endPoint)
                spec.screen.color.opacity(spec.overlayOpacity)
            } else if atmosphereEnabled {
                RadialGradient(colors: [tokens.accent.color.opacity(0.08), .clear],
                               center: UnitPoint(x: 0.22, y: 0.32), startRadius: 0, endRadius: 160)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: atmosphereSpec)
        .ignoresSafeArea()
    }

    /// Controls sit on a translucent raised platter when atmosphere is showing.
    @ViewBuilder
    private func platter<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        if atmosphereSpec != nil {
            if reduceTransparency {
                content()
                    .background(tokens.raisedPanel.color.opacity(0.85), in: shape)
            } else {
                content()
                    .background {
                        shape.fill(.ultraThinMaterial)
                            .overlay(shape.fill(tokens.raisedPanel.color.opacity(0.60)))
                    }
            }
        } else {
            content()
        }
    }

    private func errorOverlay(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: ImageNames.System.xCircle)
                .font(.system(size: 40))
                .foregroundColor(.red.opacity(0.6))
            Text(message)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .foregroundColor(tokens.secondaryText.color)
                .minimumScaleFactor(0.4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tokens.screenBackground.color)
    }

    // MARK: - Content

    private var playerContent: some View {
        VStack(spacing: 0) {
            if !isFromCoverFlow {
                StatusBar(title: String(localized: "Now Playing"))
            }
            VStack(spacing: 0) {
                HStack(spacing: 18) {
                    ZStack {
                        if let image = activeArtwork {
                            ArtworkImage(image, width: Self.artworkSize)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Self.artworkSize, height: Self.artworkSize)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
                                .rotation3DEffect(.degrees(currentDegree), axis: (x: 0, y: 1, z: 0))
                                .scaleEffect(isScaleAnimation ? 1.2 : 1)
                                .onAppear {
                                    guard isFromCoverFlow else { return }
                                    isScaleAnimation = true
                                    currentDegree = initialRotation
                                    currentOpacity = 0
                                    DispatchQueue.main.async {
                                        withAnimation(.snappy(duration: flipDuration)) {
                                            isScaleAnimation = false
                                            currentDegree = finalRotation
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
                                        withAnimation(.easeInOut(duration: fadeDuration)) {
                                            currentOpacity = 1
                                        }
                                    }
                                }
                        } else if playerManager.currentTrack == nil {
                            ProgressView()
                                .tint(mutedTextColor)
                        } else {
                            Image(ImageNames.Custom.coverPlaceholder)
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                        }
                    }
                    .frame(width: Self.artworkSize, height: Self.artworkSize)
                    .onChange(of: playerManager.currentTrack) { _, newValue in
                        activeArtwork = newValue?.artwork
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(playerManager.currentTrack?.title ?? "")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(primaryTextColor)
                            .lineLimit(2)
                            .id(playerManager.currentTrack?.title ?? "")
                        Text(playerManager.currentTrack?.artistName ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(1)
                            .id(playerManager.currentTrack?.artistName ?? "")
                        Text(playerManager.currentTrack?.albumTitle ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(1)
                            .id(playerManager.currentTrack?.albumTitle ?? "")
                        if let queuePosition = playerManager.queuePosition {
                            Text(queuePosition)
                                .font(.system(size: 12))
                                .foregroundColor(mutedTextColor)
                                .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(currentOpacity)
                }
                .frame(height: Self.artworkSize)
                Spacer(minLength: 6)
                platter {
                    VStack(spacing: 4) {
                        modeControls
                            .opacity(currentOpacity)
                        wheelModeSelector
                        transportControls
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .overlay(alignment: .topTrailing) {
            playbackModeIcons
                .padding(.horizontal, 8)
                .padding(.top, isFromCoverFlow ? 4 : StatusBar.height + 4)
                .opacity(currentOpacity)
        }
    }

    private var playbackModeIcons: some View {
        HStack(spacing: 6) {
            if playerManager.shuffleMode == .songs || playerManager.isShufflingAlbums {
                Image(systemName: ImageNames.System.shuffle)
            }
            switch playerManager.repeatMode {
            case .all:
                Image(systemName: ImageNames.System.repeatAll)
            case .one:
                Image(systemName: ImageNames.System.repeatOne)
            default:
                EmptyView()
            }
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(secondaryTextColor)
        .frame(height: 16)
    }

    private var modeControls: some View {
        Group {
            if let volumeLevel {
                VolumeBarView(level: volumeLevel, style: progressStyle)
            } else {
                switch mode {
                case .volume:
                    SongProgressView(style: progressStyle)
                case .seek:
                    ScrubberView(style: progressStyle)
                }
            }
        }
        .frame(height: NowPlayingBarMetrics.height)
        .transition(.opacity)
    }

    private var isSeekAvailable: Bool {
        guard let duration = playerManager.currentTrack?.duration else { return false }
        return duration.isFinite && duration > 0
    }

    private var wheelModeSelector: some View {
        HStack(spacing: 8) {
            Text(String(localized: "Wheel"))
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(mutedTextColor)
            modeButton(.volume, title: String(localized: "Volume"), icon: ImageNames.System.speakerHigh)
            modeButton(.seek, title: String(localized: "Seek"), icon: "waveform.path")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var transportControls: some View {
        HStack(spacing: 28) {
            transportButton(ImageNames.System.backwardEndAlt, title: String(localized: "Previous Track")) {
                Task { try? await playerManager.skipToPreviousTrack() }
            }
            transportButton(playerManager.isPlaying ? "pause.fill" : "play.fill",
                            title: playerManager.isPlaying ? String(localized: "Pause") : String(localized: "Play")) {
                Task { try? await playerManager.togglePlayPause() }
            }
            transportButton(ImageNames.System.forwardEndAlt, title: String(localized: "Next Track")) {
                Task { try? await playerManager.skipToNextTrack() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private func transportButton(_ symbol: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(primaryTextColor)
                .frame(width: 34, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    /// The active toggle is the one place the accent appears on this screen
    /// besides progress: selection background with its derived text colour.
    private func modeButton(_ value: NowPlayingMode, title: String, icon: String) -> some View {
        let isActive = mode == value
        return Button { setMode(value) } label: {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .foregroundStyle(isActive ? tokens.selectionText.color : primaryTextColor)
                .background(
                    Capsule().fill(isActive ? tokens.selectionBackground.color : Color.clear)
                )
                .overlay(
                    Capsule().strokeBorder(isActive ? Color.clear : mutedTextColor.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(value == .seek && !isSeekAvailable)
        .opacity(value == .seek && !isSeekAvailable ? 0.45 : 1)
        .accessibilityHint(value == .seek && !isSeekAvailable ? String(localized: "Seeking is unavailable for this track") : "")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func setMode(_ value: NowPlayingMode) {
        guard value != .seek || isSeekAvailable else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            mode = value
            volumeLevel = nil
        }
    }

    private func handleScroll(_ delta: Int) -> Bool {
        switch mode {
        case .volume:
            guard let newLevel = SystemVolume.adjust(by: Float(delta) * 0.0625) else { return false }
            withAnimation(.easeInOut(duration: 0.18)) { volumeLevel = newLevel }
            return true
        case .seek:
            guard let duration = playerManager.currentTrack?.duration, duration.isFinite, duration > 0 else { return false }
            let step = max(1, duration / 60)
            let target = min(max(playerManager.currentPlaybackTime + Double(delta) * step, 0), duration)
            playerManager.seek(to: target)
            return true
        }
    }

    private func setupButtonListener() {
        scope.onScroll = { handleScroll($0) }
        scope.onAction = { action in
            switch action {
            case .menu:
                if isFromCoverFlow {
                    onDismissFromCoverFlow?()
                } else {
                    navigate(.pop)
                }
            case .select:
                setMode(mode.next)
            case .forwardEndAlt:
                Task { try? await playerManager.skipToNextTrack() }
            case .backwardEndAlt:
                Task { try? await playerManager.skipToPreviousTrack() }
            case .playPause:
                Task {
                    try? await playerManager.togglePlayPause()
                }
            case .forwardLongPress:
                startSeeking(forward: true)
            case .forwardLongPressEnd:
                stopSeeking()
            case .backwardLongPress:
                startSeeking(forward: false)
            case .backwardLongPressEnd:
                stopSeeking()
            }
        }
        iPlayrController.activate(scope)
    }

    /// Press-and-hold seeking runs as a main-actor task so every read and
    /// write stays on the main actor; it is cancelled on release.
    private func startSeeking(forward: Bool) {
        guard seekTask == nil else { return }
        seekStartTime = Date()
        currentSeekSpeed = 1.0

        seekTask = Task { @MainActor in
            while !Task.isCancelled {
                updateSeekSpeed()
                if forward {
                    playerManager.seekForward(seconds: currentSeekSpeed)
                } else {
                    playerManager.seekBackward(seconds: currentSeekSpeed)
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func stopSeeking() {
        seekTask?.cancel()
        seekTask = nil
        seekStartTime = nil
        currentSeekSpeed = 1.0
    }

    @MainActor
    private func updateSeekSpeed() {
        guard let startTime = seekStartTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)
        switch elapsedTime {
        case 0..<1:
            currentSeekSpeed = 1.0
        case 1..<3:
            currentSeekSpeed = 2.0
        case 3..<5:
            currentSeekSpeed = 5.0
        case 5..<10:
            currentSeekSpeed = 10.0
        default:
            currentSeekSpeed = 20.0
        }
    }
}

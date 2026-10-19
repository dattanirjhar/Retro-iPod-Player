import SwiftUI
import MusicKit
import Combine

struct RightImageView: View {
    var isActive: Bool = true
    @Environment(MusicAuthorizationManager.self) private var authManager
    @Environment(MusicLibraryStore.self) private var libraryStore
    @State private var artworkAlbums: [Album] = []
    @State private var currentImageIndex = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var panDirection: PanDirection = .right

    private let transitionDuration: Double = 1.5
    private let imageDuration: Double = 6.0
    private let overscan: CGFloat = 1.25
    private let panFraction: CGFloat = 0.08

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black

                if !authManager.isAuthorized {
                    unauthorizedView
                } else if !artworkAlbums.isEmpty {
                    artworkSlideshow(size: proxy.size)
                } else {
                    noMusicView
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .task { await loadAlbumsIfAuthorized() }
        .onChange(of: authManager.isAuthorized) { _, isAuthorized in
            if isAuthorized {
                Task { await loadAlbumsIfAuthorized() }
                startImageCycle()
            } else {
                stopImageCycle()
            }
        }
        .onChange(of: libraryStore.albums, initial: true) { _, albums in
            // Keep a local shuffle so the library's browsing order is unaffected.
            artworkAlbums = (albums ?? []).filter { $0.artwork != nil }.shuffled()
            currentImageIndex = 0
            startImageCycle()
        }
        .onChange(of: isActive) { _, isNowActive in
            if isNowActive {
                startImageCycle()
            } else {
                stopImageCycle()
            }
        }
        .onAppear(perform: startImageCycle)
        .onDisappear(perform: stopImageCycle)
    }

    private func loadAlbumsIfAuthorized() async {
        guard authManager.isAuthorized else { return }
        await libraryStore.loadAlbumsIfNeeded()
    }

    private var unauthorizedView: some View {
        VStack {
            Image(systemName: "applelogo")
                .font(.system(size: 60))
            Spacer().frame(height: 16)
            Text("Please sign in to Apple Music")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
        }
    }

    private func artworkSlideshow(size: CGSize) -> some View {
        let dimension = (max(size.width, size.height) * overscan).rounded()
        return ZStack {
            if artworkAlbums.indices.contains(currentImageIndex),
               let artwork = artworkAlbums[currentImageIndex].artwork {
                ArtworkImage(artwork, width: dimension, height: dimension)
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(overscan)
                    .modifier(PanEffect(
                        duration: imageDuration + transitionDuration,
                        direction: panDirection,
                        maxOffset: size.width * panFraction
                    ))
                    .id(artworkAlbums[currentImageIndex].id)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: transitionDuration), value: currentImageIndex)
            }
        }
        .clipped()
    }

    private var noMusicView: some View {
        VStack {
            Image(systemName: ImageNames.System.musicNote)
                .resizable()
                .frame(width: 50, height: 90)
                .foregroundColor(.white)
            Spacer().frame(height: 16)
            Text("No Music")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
        }
    }

    private func startImageCycle() {
        stopImageCycle()
        guard isActive, authManager.isAuthorized, artworkAlbums.count > 1 else { return }
        timerCancellable = Timer.publish(every: imageDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in transitionToNextImage() }
    }

    private func transitionToNextImage() {
        guard isActive, authManager.isAuthorized, artworkAlbums.count > 1 else { return }

        withAnimation(.easeInOut(duration: transitionDuration)) {
            panDirection = panDirection == .right ? .left : .right
            if currentImageIndex + 1 < artworkAlbums.count {
                currentImageIndex += 1
            } else {
                // Show every available cover once, then reshuffle for the next round.
                let previousID = artworkAlbums[currentImageIndex].id
                artworkAlbums.shuffle()
                if artworkAlbums[0].id == previousID {
                    artworkAlbums.swapAt(0, Int.random(in: 1..<artworkAlbums.count))
                }
                currentImageIndex = 0
            }
        }
    }

    private func stopImageCycle() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

enum PanDirection: String, CaseIterable {
    case left
    case right
}

struct PanEffect: ViewModifier {
    let duration: Double
    let direction: PanDirection
    let maxOffset: CGFloat
    @State private var offset: CGFloat = 0

    private var startOffset: CGFloat {
        direction == .right ? -maxOffset : maxOffset
    }

    private var endOffset: CGFloat {
        direction == .right ? maxOffset : -maxOffset
    }

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                offset = startOffset
                withAnimation(.linear(duration: duration)) {
                    offset = endOffset
                }
            }
            .onChange(of: direction) {
                offset = startOffset
                withAnimation(.linear(duration: duration)) {
                    offset = endOffset
                }
            }
    }
}

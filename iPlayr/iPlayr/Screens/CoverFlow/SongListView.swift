import SwiftUI
import MusicKit

struct SongListView: View {
    let album: Album
    let isSelected: Bool
    @Binding var isSongList: Bool
    var scope: FocusScope
    var onSelectTrack: ((Int) -> Void)? = nil
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(ThemeManager.self) private var theme
    @State private var isLoading = true
    @State private var tracks: [Track] = []
    private var shouldLoad: Bool { isSongList && isSelected }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                albumHeader
                if tracks.isEmpty && !isLoading {
                    StateView(state: .empty(message: String(localized: "No tracks found")))
                } else {
                    tracksList
                }
            }
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                LoadingView()
            }
        }
        .onDisappear(perform: cleanup)
        .task(id: shouldLoad) {
            if shouldLoad { await loadTracks() }
        }
    }

    private var albumHeader: some View {
        VStack(spacing: 0) {
            albumTitle
            artistName
        }
        .background(theme.tokens().raisedPanel.color)
    }

    private var albumTitle: some View {
        Text(album.title)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(theme.tokens().primaryText.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
            .padding(.leading, 8)
            .lineLimit(1)
    }

    private var artistName: some View {
        Text(album.artistName)
            .font(.system(size: 14))
            .foregroundStyle(theme.tokens().secondaryText.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
            .padding(.leading, 8)
            .lineLimit(1)
    }

    private var tracksList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
                        Button {
                            scope.select(index)
                            onSelectTrack?(index)
                        } label: {
                            MenuItemView(
                                menu: Menu(id: index, name: track.title, next: scope.selection == index),
                                isSelected: scope.selection == index
                            )
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(String(localized: "Play this track"))
                        .id(index)
                    }
                }
                .onChange(of: scope.selection) { _, newIndex in
                    proxy.scrollTo(newIndex)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(scope.selection)
                    }
                }
            }
        }
    }

    private func loadTracks() async {
        let loaded = await libraryStore.albumTracks(id: album.id.rawValue) ?? []
        guard !Task.isCancelled else { return }
        tracks = loaded
        scope.configure(itemCount: tracks.count, selection: scope.selection)
        isLoading = false
    }

    private func cleanup() {
        isLoading = true
    }
}


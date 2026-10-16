import SwiftUI

struct SongsView: View {
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(\.navigate) private var navigate

    var body: some View {
        LibraryListView(
            title: String(localized: "Songs"),
            scopeID: "songs",
            emptyMessage: String(localized: "No songs found\nAdd some music to your library"),
            cached: { libraryStore.songs },
            load: {
                await libraryStore.loadSongsIfNeeded()
                return libraryStore.songs
            },
            onSelect: { _, index in
                navigate(.push(.player(source: .allSongs, trackIndex: index)))
            },
            queueCandidate: { song in QueueCandidate(item: .song(song), title: song.title) }
        ) { song, isSelected in
            CollectionMenuItem(model: song.toCollectionMenuModel(), isSelected: isSelected)
        }
    }
}

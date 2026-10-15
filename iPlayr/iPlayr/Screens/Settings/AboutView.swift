import SwiftUI
import UIKit

struct AboutView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "about")
    @State private var page = 0

    private var pages: [[Menu]] {
        [
            [
                Menu(name: String(localized: "Songs"), next: false, value: count(libraryStore.songs?.count)),
                Menu(name: String(localized: "Albums"), next: false, value: count(libraryStore.albums?.count)),
                Menu(name: String(localized: "Artists"), next: false, value: count(libraryStore.artists?.count)),
                Menu(name: String(localized: "Playlists"), next: false, value: count(libraryStore.playlists?.count)),
            ],
            [
                Menu(name: String(localized: "Genres"), next: false, value: count(libraryStore.genres?.count)),
                Menu(name: String(localized: "Composers"), next: false, value: count(libraryStore.composers?.count)),
            ],
            [
                Menu(name: String(localized: "Model"), next: false, value: deviceModel),
                Menu(name: String(localized: "Version"), next: false, value: appVersion),
            ],
        ]
    }

    private func count(_ value: Int?) -> String {
        guard let value else { return "—" }
        return String(value)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var deviceModel: String {
        UIDevice.current.model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "About"))
            let rows = pages[min(page, pages.count - 1)]
            ForEach(rows.indices, id: \.self) { index in
                MenuItemView(menu: rows[index], isSelected: false)
            }
            Spacer()
            pageIndicator
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .taskAfterNavigation { await loadLibraryCounts() }
    }

    /// Songs are loaded first because `loadComposersIfNeeded` derives composers
    /// from the song list; everything else is independent and runs concurrently,
    /// so the counts arrive together instead of one slow round-trip at a time.
    private func loadLibraryCounts() async {
        // Bind the store locally so the `async let` child tasks capture only this
        // Sendable (main-actor) reference and never the non-Sendable view itself.
        let store = libraryStore
        await store.loadSongsIfNeeded()
        async let albums: Void = store.loadAlbumsIfNeeded()
        async let artists: Void = store.loadArtistsIfNeeded()
        async let playlists: Void = store.loadPlaylistsIfNeeded()
        async let genres: Void = store.loadGenresIfNeeded()
        async let composers: Void = store.loadComposersIfNeeded()
        _ = await (albums, artists, playlists, genres, composers)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Circle()
                    // Follows the interface palette so the active dot is visible in
                    // Night mode too (a hard-coded black dot vanished on the dark background).
                    .fill(index == page ? theme.tokens().primaryText.color : Color.gray.opacity(0.35))
                    .frame(width: 5, height: 5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
    }

    private func setup() {
        scope.configure(itemCount: 0)
        scope.onAction = { action in
            switch action {
            case .menu:
                navigate(.pop)
            case .select:
                page = (page + 1) % pages.count
            default:
                break
            }
        }
        iPlayrController.activate(scope)
    }
}

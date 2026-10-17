import SwiftUI
import UIKit

struct AboutView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "about")
    private enum Page: CaseIterable {
        case app, library, collections, device, inspiration
    }

    private var page: Page { Page.allCases[scope.selection] }

    private func count(_ value: Int?) -> String {
        guard let value else { return "—" }
        return String(value)
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "About"))
            pageContent
            Spacer(minLength: 0)
            pageControl
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .taskAfterNavigation { await loadLibraryCounts() }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .app:
            VStack(alignment: .leading, spacing: 5) {
                Text("iPod-Playr")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.tokens().primaryText.color)
                Text("Classic controls. Your Apple Music library.")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.tokens().secondaryText.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            infoRow(String(localized: "Version"), value: appVersion)
            infoRow(String(localized: "Themes"), value: String(ThemeTable.all.count))
        case .library:
            infoRow(String(localized: "Songs"), value: count(libraryStore.songs?.count))
            infoRow(String(localized: "Albums"), value: count(libraryStore.albums?.count))
            infoRow(String(localized: "Artists"), value: count(libraryStore.artists?.count))
            infoRow(String(localized: "Playlists"), value: count(libraryStore.playlists?.count))
        case .collections:
            infoRow(String(localized: "Genres"), value: count(libraryStore.genres?.count))
            infoRow(String(localized: "Composers"), value: count(libraryStore.composers?.count))
        case .device:
            infoRow(String(localized: "Model"), value: UIDevice.current.model)
            infoRow("iOS", value: UIDevice.current.systemVersion)
        case .inspiration:
            VStack(alignment: .leading, spacing: 10) {
                Text("Inspiration")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.tokens().primaryText.color)
                Text("Inspired by iPodPlayer.")
                Text("Extensively reworked with custom themes, refined Cover Flow and expanded playback controls.")
                Text("Built with SwiftUI and MusicKit.")
            }
            .font(.system(size: 13))
            .foregroundStyle(theme.tokens().secondaryText.color)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
        }
    }

    private func infoRow(_ name: String, value: String) -> some View {
        MenuItemView(menu: Menu(name: name, next: false, value: value), isSelected: false)
            .accessibilityElement(children: .combine)
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

    private var pageControl: some View {
        Button(action: nextPage) {
            HStack {
                Text("\(scope.selection + 1) / \(Page.allCases.count)")
                    .monospacedDigit()
                Spacer(minLength: 4)
                Text("Next")
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(theme.tokens().secondaryText.color)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Next About page"))
        .accessibilityValue("\(scope.selection + 1) / \(Page.allCases.count)")
    }

    private func nextPage() {
        scope.select((scope.selection + 1) % Page.allCases.count)
    }

    private func setup() {
        scope.configure(itemCount: Page.allCases.count)
        scope.onAction = { action in
            switch action {
            case .menu:
                navigate(.pop)
            case .select:
                nextPage()
            default:
                break
            }
        }
        iPlayrController.activate(scope)
    }
}

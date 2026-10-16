import Foundation
import SwiftUI

enum NavigationType: Hashable, Sendable {
    case push(Route)
    case pop
    case popToRoot
}

struct NavigateAction: Sendable {
    typealias Action = @MainActor @Sendable (NavigationType) -> Void
    let action: Action

    @MainActor
    func callAsFunction(_ navigationType: NavigationType) {
        action(navigationType)
    }
}

struct NavigationEnvironmentKey: EnvironmentKey {
    static let defaultValue: NavigateAction = NavigateAction(action: { _ in })
}

struct IsNavigatingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var navigate: NavigateAction {
        get { self[NavigationEnvironmentKey.self] }
        set { self[NavigationEnvironmentKey.self] = newValue }
    }

    var isNavigating: Bool {
        get { self[IsNavigatingEnvironmentKey.self] }
        set { self[IsNavigatingEnvironmentKey.self] = newValue }
    }
}

extension View {
    func taskAfterNavigation(_ action: @escaping @MainActor @Sendable () async -> Void) -> some View {
        modifier(TaskAfterNavigation(action: action))
    }
}

private struct TaskAfterNavigation: ViewModifier {
    @Environment(\.isNavigating) private var isNavigating
    @State private var hasRun = false
    let action: @MainActor @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.task(id: isNavigating) {
            guard !isNavigating, !hasRun else { return }
            hasRun = true
            await action()
        }
    }
}

enum PlaybackSource: Hashable, Sendable {
    case album(id: String)
    case playlist(id: String)
    case composer(name: String)
    case allSongs
    case shuffleAll
    case shuffleAlbums
}

enum InfoPage: String, Hashable, Sendable {
    case gestures, tutorial, whatsNew

    var title: String {
        switch self {
        case .gestures: String(localized: "Gestures")
        case .tutorial: String(localized: "Tutorial")
        case .whatsNew: String(localized: "What’s New")
        }
    }

    var message: String {
        switch self {
        case .gestures:
            String(localized: "Rotate the wheel to move through lists. Press the center button to select. Press and hold the center button on a song for Play Now, Play Next and Add to End of Queue, or on Now Playing to see the queue. Press MENU to go back; press and hold MENU to return to the main menu. Press and hold Play/Pause anywhere to open Now Playing. In Now Playing, use the on-screen Wheel control to choose Volume or Seek; seeking takes effect once the wheel settles.")
        case .tutorial:
            String(localized: "Browse your Apple Music library from Music. Open Cover Flow to browse album artwork, then press the center button to view tracks or select a track to play. Settings lets you customize the simulated iPod and clickwheel.")
        case .whatsNew:
            String(localized: "Browse albums, artists, playlists, songs, genres and composers. Customize the iPod body, clickwheel and interface separately. Shuffle songs or albums, and switch the Now Playing wheel between volume and seeking.")
        }
    }
}

enum Route: Hashable, Identifiable, Sendable {
    case music
    case home
    case playlists
    case artists(genre: CollectionInfoModel?)
    case albums
    case songs
    case genres
    case composers
    case artistAlbums(artist: CollectionInfoModel)
    case playlistTracks(playlist: CollectionInfoModel)
    case albumTracks(album: CollectionInfoModel)
    case composerSongs(composer: String)
    case about
    case brightness
    case menuCustomization(isMainMenu: Bool)
    case signIn
    case coverFlow
    case theme
    case player(source: PlaybackSource, trackIndex: Int, isFromCoverFlow: Bool = false)
    case settings
    case nowPlaying
    case immersiveCoverFlowPlayer(albumID: String, trackIndex: Int)
    case queue
    case extras
    case appearanceSetting(AppearanceSetting)
    case info(InfoPage)

    var id: Route { self }
}

extension Route {
    /// Screens that already show the player; the Now Playing shortcut is a no-op on them.
    var isPlayerScreen: Bool {
        switch self {
        case .player, .nowPlaying, .immersiveCoverFlowPlayer: return true
        default: return false
        }
    }

    var isFullScreen: Bool {
        switch self {
        case .home, .music, .settings, .signIn, .theme, .extras,
             .about, .brightness, .menuCustomization, .appearanceSetting(_), .info(_):
            return false
        case .playlists, .artists, .albums, .songs, .genres, .composers,
             .artistAlbums, .playlistTracks, .albumTracks, .composerSongs,
             .coverFlow, .player, .nowPlaying, .immersiveCoverFlowPlayer, .queue:
            return true
        }
    }

    @MainActor @ViewBuilder
    var destination: some View {
        switch self {
        case .music:
            MusicListView()
        case .home:
            HomeListView()
        case .playlists:
            PlaylistsView()
        case .artists(let genre):
            ArtistsView(genre: genre)
        case .albums:
            AlbumsView()
        case .songs:
            SongsView()
        case .genres:
            GenresView()
        case .composers:
            ComposersView()
        case .artistAlbums(let artist):
            ArtistAlbumsView(artist: artist)
        case .playlistTracks(let playlist):
            PlaylistTracksView(playlist: playlist)
        case .albumTracks(let album):
            AlbumTracksView(album: album)
        case .composerSongs(let composer):
            ComposerSongsView(composer: composer)
        case .about:
            AboutView()
        case .brightness:
            BrightnessView()
        case .menuCustomization(let isMainMenu):
            MenuCustomizationView(isMainMenu: isMainMenu)
        case .appearanceSetting(let setting):
            switch setting {
            case .theme: ThemePickerView()
            case .mode: ModePickerView()
            case .language: LanguagePickerView()
            }
        case .info(let page):
            InfoPageView(page: page)
        case .extras:
            ExtrasView()
        case .signIn:
            SignInView()
        case .coverFlow:
            CoverFlowView()
        case .theme:
            ThemeView()
        case .player(let source, let trackIndex, let isFromCoverFlow):
            PlayerView(source: source, trackIndex: trackIndex, isFromCoverFlow: isFromCoverFlow)
        case .nowPlaying:
            PlayerView(source: nil, trackIndex: 0, isFromCoverFlow: false)
        case .immersiveCoverFlowPlayer(let albumID, let trackIndex):
            PlayerView(source: .album(id: albumID), trackIndex: trackIndex, isFromCoverFlow: false)
        case .queue:
            QueueView()
        case .settings:
            SettingsView()
        }
    }
}

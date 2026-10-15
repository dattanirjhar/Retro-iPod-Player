import Foundation
import MusicKit
import Observation

@MainActor
@Observable
final class MusicLibraryStore {
    private(set) var albums: [Album]?
    private(set) var playlists: [Playlist]?
    private(set) var artists: [Artist]?
    private(set) var genres: [Genre]?
    private(set) var songs: [Song]?
    private(set) var composers: [String]?
    var errorMessage: String?
    private(set) var sortOrder: SortOrder

    @ObservationIgnored private let service = MusicLibraryService()
    @ObservationIgnored private let defaults = UserDefaults.standard
    @ObservationIgnored private var albumTracksCache: [String: [Track]] = [:]
    @ObservationIgnored private var playlistTracksCache: [String: [Track]] = [:]
    @ObservationIgnored private var artistAlbumsCache: [String: [Album]] = [:]
    @ObservationIgnored private var genreArtistsCache: [String: [Artist]] = [:]

    init() {
        sortOrder = UserDefaults.standard.string(forKey: UserDefaultsKeys.sortOrder.rawValue)
            .flatMap(SortOrder.init(rawValue:)) ?? .alphabetical
    }

    func setSortOrder(_ order: SortOrder) {
        guard order != sortOrder else { return }
        sortOrder = order
        defaults.set(order.rawValue, forKey: UserDefaultsKeys.sortOrder.rawValue)
        albums = albums.map(sortedAlbums)
        playlists = playlists.map(sortedPlaylists)
        artists = artists.map(sortedArtists)
        songs = songs.map(sortedSongs)
        artistAlbumsCache = artistAlbumsCache.mapValues(sortedAlbums)
        genreArtistsCache = genreArtistsCache.mapValues(sortedArtists)
    }

    func loadAlbumsIfNeeded() async {
        guard albums == nil else { return }
        albums = await fetch { try await service.fetchAlbums(sortOrder: sortOrder) }.map(sortedAlbums)
    }

    func loadPlaylistsIfNeeded() async {
        guard playlists == nil else { return }
        playlists = await fetch { try await service.fetchPlaylists(sortOrder: sortOrder) }.map(sortedPlaylists)
    }

    func loadArtistsIfNeeded() async {
        guard artists == nil else { return }
        artists = await fetch { try await service.fetchArtists(sortOrder: sortOrder) }.map(sortedArtists)
    }

    func loadGenresIfNeeded() async {
        guard genres == nil else { return }
        genres = await fetch { try await service.fetchGenres() }
    }

    func loadSongsIfNeeded() async {
        guard songs == nil else { return }
        songs = await fetch { try await service.fetchSongs(sortOrder: sortOrder) }.map(sortedSongs)
    }

    func loadComposersIfNeeded() async {
        guard composers == nil else { return }
        await loadSongsIfNeeded()
        guard let songs else { return }
        let names = songs.compactMap { $0.composerName?.trimmingCharacters(in: .whitespacesAndNewlines) }
        composers = Set(names.filter { !$0.isEmpty })
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    func composerSongs(name: String) -> [Song] {
        songs?.filter { $0.composerName?.trimmingCharacters(in: .whitespacesAndNewlines) == name } ?? []
    }

    func songsGroupedByShuffledAlbums() async -> [Song] {
        await loadSongsIfNeeded()
        guard let songs, !songs.isEmpty else { return [] }
        let groups = Dictionary(grouping: songs, by: { $0.albumTitle ?? "" })
        return groups.keys.shuffled().flatMap { albumTitle in
            (groups[albumTitle] ?? []).sorted {
                ($0.discNumber ?? 0, $0.trackNumber ?? 0) < ($1.discNumber ?? 0, $1.trackNumber ?? 0)
            }
        }
    }

    func cachedAlbumTracks(id: String) -> [Track]? { albumTracksCache[id] }
    func cachedPlaylistTracks(id: String) -> [Track]? { playlistTracksCache[id] }
    func cachedArtistAlbums(id: String) -> [Album]? { artistAlbumsCache[id] }
    func cachedGenreArtists(id: String) -> [Artist]? { genreArtistsCache[id] }

    func albumTracks(id: String) async -> [Track]? {
        if let cached = albumTracksCache[id] { return cached }
        guard let tracks = await fetch({ try await service.fetchAlbumTracks(id: id) }) else { return nil }
        albumTracksCache[id] = tracks
        return tracks
    }

    func playlistTracks(id: String) async -> [Track]? {
        if let cached = playlistTracksCache[id] { return cached }
        guard let tracks = await fetch({ try await service.fetchPlaylistTracks(id: id) }) else { return nil }
        playlistTracksCache[id] = tracks
        return tracks
    }

    func artistAlbums(id: String) async -> [Album]? {
        if let cached = artistAlbumsCache[id] { return cached }
        guard let fetched = await fetch({ try await service.fetchArtistAlbums(id: id) }) else { return nil }
        let albums = sortedAlbums(fetched)
        artistAlbumsCache[id] = albums
        return albums
    }

    func genreArtists(id: String) async -> [Artist]? {
        if let cached = genreArtistsCache[id] { return cached }
        guard let fetched = await fetch({ try await service.fetchGenreArtists(id: id) }) else { return nil }
        let artists = sortedArtists(fetched)
        genreArtistsCache[id] = artists
        return artists
    }

    private func fetch<T>(_ operation: () async throws -> [T]) async -> [T]? {
        do {
            return try await operation()
        } catch {
            errorMessage = String(localized: "Request failed with error: \(error.localizedDescription)")
            return nil
        }
    }

    private func sortedAlbums(_ items: [Album]) -> [Album] {
        switch sortOrder {
        case .alphabetical: items.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .dateAdded: items.sorted { ($0.libraryAddedDate ?? .distantPast) > ($1.libraryAddedDate ?? .distantPast) }
        }
    }

    private func sortedPlaylists(_ items: [Playlist]) -> [Playlist] {
        switch sortOrder {
        case .alphabetical: items.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .dateAdded: items.sorted { ($0.libraryAddedDate ?? .distantPast) > ($1.libraryAddedDate ?? .distantPast) }
        }
    }

    private func sortedArtists(_ items: [Artist]) -> [Artist] {
        switch sortOrder {
        case .alphabetical: items.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .dateAdded: items.sorted { ($0.libraryAddedDate ?? .distantPast) > ($1.libraryAddedDate ?? .distantPast) }
        }
    }

    private func sortedSongs(_ items: [Song]) -> [Song] {
        switch sortOrder {
        case .alphabetical: items.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .dateAdded: items.sorted { ($0.libraryAddedDate ?? .distantPast) > ($1.libraryAddedDate ?? .distantPast) }
        }
    }
}

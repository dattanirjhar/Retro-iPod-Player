import Foundation
import Combine
import MusicKit
import Observation

@MainActor
@Observable
final class AppleMusicManager {
    private static let queueLimit = 200
    private static let queueLeadIn = 25

    var currentTrack: Song?
    var isPlaying: Bool = false
    private(set) var shuffleMode: MusicPlayer.ShuffleMode = .off
    private(set) var isShufflingAlbums = false
    private(set) var repeatMode: MusicPlayer.RepeatMode = .none
    private(set) var isPaused: Bool = false
    private(set) var isLast: Bool = false
    private(set) var isFirst: Bool = false
    private(set) var queuePosition: String?
    /// Snapshot of the player's queue for the Queue screen.
    private(set) var queueEntries: [QueueEntryInfo] = []

    @ObservationIgnored private nonisolated(unsafe) let musicPlayer = ApplicationMusicPlayer.shared
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var isSkipping = false
    
    init() {
        setupSongObserver()
    }

    /// Plays an album's or playlist's tracks. The caller passes the exact `[Track]`
    /// array it displayed (from `MusicLibraryStore`), so `fromIndex` always refers
    /// to the row the user selected. Previously the player re-fetched tracks with a
    /// different relationship/source than the list, which could shift the index.
    func playTracks(_ tracks: [Track], fromIndex: Int = 0) async throws {
        // Albums and playlists are finite, user-chosen containers: queue them whole
        // so playback runs through the entire collection, as the old
        // `Queue(album:)` / `Queue(playlist:)` forms did.
        try await enqueue(tracks, fromIndex: fromIndex, shuffleMode: .off, shufflingAlbums: false, windowed: false)
    }

    /// Library-wide lists (all songs, shuffle) can be thousands of items, so these
    /// are queued through a bounded window around the selected song.
    func playSongs(
        _ songs: [Song],
        fromIndex: Int = 0,
        shuffleMode: MusicPlayer.ShuffleMode = .off,
        shufflingAlbums: Bool = false
    ) async throws {
        try await enqueue(songs, fromIndex: fromIndex, shuffleMode: shuffleMode, shufflingAlbums: shufflingAlbums, windowed: true)
    }

    private func enqueue<Item: PlayableMusicItem>(
        _ items: [Item],
        fromIndex: Int,
        shuffleMode: MusicPlayer.ShuffleMode,
        shufflingAlbums: Bool,
        windowed: Bool
    ) async throws {
        guard !items.isEmpty else {
            throw MusicPlayerError.trackNotFound
        }
        guard items.indices.contains(fromIndex) else {
            throw MusicPlayerError.invalidTrackIndex(index: fromIndex, totalTracks: items.count)
        }

        let queued: [Item]
        if windowed {
            // A window of `queueLimit` items starting `queueLeadIn` before the
            // selection. The selected item is always inside it because
            // end >= start + queueLimit > fromIndex.
            let start = max(0, fromIndex - Self.queueLeadIn)
            let end = min(items.count, start + Self.queueLimit)
            queued = Array(items[start..<end])
        } else {
            queued = items
        }

        currentTrack = nil
        musicPlayer.queue = ApplicationMusicPlayer.Queue(for: queued, startingAt: items[fromIndex])
        musicPlayer.state.shuffleMode = shuffleMode
        self.shuffleMode = shuffleMode
        isShufflingAlbums = shufflingAlbums
        try await startPlayback()
    }

    /// `prepareToPlay()`/`play()` can intermittently fail right after a queue is
    /// assigned (MPMusicPlayerControllerErrorDomain error 6), seemingly because the
    /// player hasn't caught up with the new queue yet. One short-delayed retry clears
    /// it in practice, so we don't surface a scary error for what's usually a
    /// transient timing hiccup.
    private func startPlayback(retriesRemaining: Int = 1) async throws {
        do {
            try await musicPlayer.prepareToPlay()
            try await musicPlayer.play()
        } catch {
            guard retriesRemaining > 0 else { throw error }
            try? await Task.sleep(for: .milliseconds(300))
            try await startPlayback(retriesRemaining: retriesRemaining - 1)
        }
    }

    func skipToNextTrack() async throws {
        guard !isLast, !isSkipping else { return }
        isSkipping = true
        defer { isSkipping = false }
        try await musicPlayer.skipToNextEntry()
        await updatePlayerState()
    }

    func skipToPreviousTrack() async throws {
        guard !isFirst, !isSkipping else { return }
        isSkipping = true
        defer { isSkipping = false }
        try await musicPlayer.skipToPreviousEntry()
        await updatePlayerState()
    }

    func togglePlayPause() async throws {
        if isPlaying {
            musicPlayer.pause()
        } else {
            try await musicPlayer.play()
        }
    }

    // MARK: Queue

    /// Makes the given queue entry current and plays it.
    func jump(toEntryID id: String) async throws {
        guard let entry = musicPlayer.queue.entries.first(where: { String(describing: $0.id) == id }) else {
            throw MusicPlayerError.trackNotFound
        }
        musicPlayer.queue.currentEntry = entry
        try await musicPlayer.play()
        await updatePlayerState()
    }

    func playNext(_ item: QueueableItem) async throws {
        try await insert(item, position: .afterCurrentEntry)
    }

    func addToQueue(_ item: QueueableItem) async throws {
        try await insert(item, position: .tail)
    }

    /// With nothing queued, both actions simply start playing the item.
    private func insert(_ item: QueueableItem, position: MusicPlayer.Queue.EntryInsertionPosition) async throws {
        if musicPlayer.queue.entries.isEmpty {
            switch item {
            case .song(let song): try await playSongs([song])
            case .track(let track): try await playTracks([track])
            }
            return
        }
        switch item {
        case .song(let song): try await musicPlayer.queue.insert(song, position: position)
        case .track(let track): try await musicPlayer.queue.insert(track, position: position)
        }
        await updatePlayerState()
    }

    private func setupSongObserver() {
        Publishers.Merge(
            musicPlayer.state.objectWillChange,
            musicPlayer.queue.objectWillChange
        )
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.updatePlayerState()
                }
            }
            .store(in: &cancellables)
    }

    func setShuffleMode(_ mode: MusicPlayer.ShuffleMode) {
        musicPlayer.state.shuffleMode = mode
        shuffleMode = mode
        isShufflingAlbums = false
    }

    func setRepeatMode(_ mode: MusicPlayer.RepeatMode) {
        musicPlayer.state.repeatMode = mode
        repeatMode = mode
    }

    func seek(to time: TimeInterval) {
        guard let duration = currentTrack?.duration else { return }
        musicPlayer.playbackTime = min(max(time, 0), duration)
    }

    private func updatePlayerState() async {
        let currentPlayingEntryId = musicPlayer.queue.currentEntry?.id
        let entries = musicPlayer.queue.entries
        isLast = entries.last?.id == currentPlayingEntryId
        isFirst = entries.first?.id == currentPlayingEntryId
        if let index = entries.firstIndex(where: { $0.id == currentPlayingEntryId }) {
            queuePosition = String(localized: "\(index + 1) of \(entries.count)")
        } else {
            queuePosition = nil
        }
        queueEntries = entries.map { entry in
            QueueEntryInfo(id: String(describing: entry.id), title: entry.title,
                           subtitle: entry.subtitle ?? "", artwork: entry.artwork,
                           isCurrent: entry.id == currentPlayingEntryId)
        }
        shuffleMode = musicPlayer.state.shuffleMode ?? .off
        repeatMode = musicPlayer.state.repeatMode ?? MusicPlayer.RepeatMode.none
        await updateCurrentTrack()
        updatePlaybackStatus()
    }

    private func updateCurrentTrack() async {
        if case let .song(song) = musicPlayer.queue.currentEntry?.item {
            currentTrack = song
        }
    }

    private func updatePlaybackStatus() {
        switch musicPlayer.state.playbackStatus {
        case .playing:
            isPlaying = true
            isPaused = false
        case .paused:
            isPlaying = false
            isPaused = true
        case .stopped, .interrupted:
            isPlaying = false
            isPaused = false
        default:
            break
        }
    }

    var currentPlaybackTime: TimeInterval {
        return musicPlayer.playbackTime
    }
}

/// A song or track a list row can offer to the queue.
enum QueueableItem: Sendable {
    case song(Song)
    case track(Track)
}

struct QueueEntryInfo: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let artwork: Artwork?
    let isCurrent: Bool
}

enum MusicPlayerError: LocalizedError, Sendable {
    case trackNotFound
    case invalidTrackIndex(index: Int, totalTracks: Int)
    case libraryRequestFailed(message: String?)

    var errorDescription: String? {
        switch self {
        case .trackNotFound:
            return "The specified track could not be found."
        case .invalidTrackIndex(let index, let totalTracks):
            return "The track index \(index) is out of range. The item contains \(totalTracks) tracks."
        case .libraryRequestFailed(let message):
            return message ?? "The library request failed. Please try again."
        }
    }
}

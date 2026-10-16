import SwiftUI

enum NowPlayingMode: CaseIterable {
    case volume
    case seek

    var next: NowPlayingMode {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}

/// Colours for a progress bar. Now Playing overrides these when artwork
/// atmosphere is showing; every other caller takes the interface tokens.
struct ProgressBarStyle: Hashable {
    let track: Color
    let fill: Color
    let text: Color

    init(tokens: InterfaceTokens) {
        track = tokens.progressTrack.color
        fill = tokens.progressFill.color
        text = tokens.primaryText.color
    }

    init(track: Color, fill: Color, text: Color) {
        self.track = track
        self.fill = fill
        self.text = text
    }
}

/// A restrained modern bar: a 6pt capsule track, an accent-derived fill, and
/// (in Seek mode) a round playhead. No gloss, no reflection.
struct BarTrack: View {
    static let height: CGFloat = 6

    let progress: Double
    var playhead: Double?
    var style: ProgressBarStyle?
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        let style = style ?? ProgressBarStyle(tokens: theme.tokens())
        GeometryReader { geo in
            let clamped = min(max(progress, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(style.track)
                Capsule()
                    .fill(style.fill)
                    .frame(width: max(Self.height, geo.size.width * clamped))
                if let playhead {
                    let p = min(max(playhead, 0), 1)
                    Circle()
                        .fill(style.fill)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.25), radius: 1.5, y: 0.5)
                        .offset(x: geo.size.width * p - 6)
                }
            }
            .frame(height: Self.height)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 14)
    }
}

enum NowPlayingBarMetrics {
    static let height: CGFloat = 30
    static let sideWidth: CGFloat = 48
}

struct NowPlayingBar<Leading: View, Trailing: View>: View {
    let progress: Double
    var playhead: Double?
    var style: ProgressBarStyle?
    let leading: Leading
    let trailing: Trailing

    init(progress: Double, playhead: Double? = nil, style: ProgressBarStyle? = nil,
         @ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.progress = progress
        self.playhead = playhead
        self.style = style
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 0) {
            leading
                .frame(width: NowPlayingBarMetrics.sideWidth, alignment: .leading)
            BarTrack(progress: progress, playhead: playhead, style: style)
                .padding(.horizontal, 6)
            trailing
                .frame(width: NowPlayingBarMetrics.sideWidth, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .frame(height: NowPlayingBarMetrics.height)
    }
}

struct SongProgressView: View {
    var style: ProgressBarStyle?
    @Environment(AppleMusicManager.self) private var playerManager

    private var duration: TimeInterval { playerManager.currentTrack?.duration ?? 0 }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, playerManager.currentPlaybackTime / duration)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: playerManager.isPlaying ? 0.25 : 3600)) { _ in
            NowPlayingBar(progress: progress, style: style) {
                TimeLabel(seconds: Int(progress * duration), color: style?.text)
            } trailing: {
                TimeLabel(seconds: Int(duration - progress * duration), isRemaining: true, color: style?.text)
            }
        }
    }
}

struct ScrubberView: View {
    var style: ProgressBarStyle?
    /// Set while the wheel is scrubbing; the playhead follows it instead of playback.
    var pendingPosition: TimeInterval? = nil
    @Environment(AppleMusicManager.self) private var playerManager

    private var duration: TimeInterval { playerManager.currentTrack?.duration ?? 0 }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        let position = pendingPosition ?? playerManager.currentPlaybackTime
        return min(1, max(0, position / duration))
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: playerManager.isPlaying ? 0.1 : 3600)) { _ in
            NowPlayingBar(progress: progress, playhead: progress, style: style) {
                TimeLabel(seconds: Int(progress * duration), color: style?.text)
            } trailing: {
                TimeLabel(seconds: Int(duration - progress * duration), isRemaining: true, color: style?.text)
            }
        }
    }
}

struct VolumeBarView: View {
    let level: Float
    var style: ProgressBarStyle?
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        let text = style?.text ?? theme.tokens().primaryText.color
        NowPlayingBar(progress: Double(level), style: style) {
            Image(systemName: ImageNames.System.speakerLow)
                .font(.system(size: 12))
                .foregroundColor(text)
        } trailing: {
            Image(systemName: ImageNames.System.speakerHigh)
                .font(.system(size: 12))
                .foregroundColor(text)
        }
    }
}

struct TimeLabel: View {
    let seconds: Int
    var isRemaining: Bool = false
    var color: Color? = nil
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        Text(isRemaining ? "-\(formatted)" : formatted)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color ?? theme.tokens().secondaryText.color)
            .monospacedDigit()
            .lineLimit(1)
    }

    /// `mm:ss` under an hour, `h:mm:ss` beyond it.
    private var formatted: String {
        let total = max(0, seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%02d:%02d", minutes, secs)
    }
}

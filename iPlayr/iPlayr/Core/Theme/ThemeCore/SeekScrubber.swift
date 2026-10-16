import Foundation

/// Wheel scrubbing model for Now Playing. Lives in the Foundation-only core so
/// it is unit-tested on Linux alongside the theme logic.
///
/// Audio keeps playing while the user turns the wheel: each click moves a
/// *pending* position by one sixtieth of the track, the scrubber draws the
/// playhead there, and the view commits a single seek once the wheel has been
/// still for `settleDelay`. One seek per gesture is what keeps playback smooth.
struct SeekScrubber: Hashable, Sendable {
    let duration: TimeInterval
    private(set) var pending: TimeInterval?

    static let settleDelay: Duration = .milliseconds(400)
    static let stepsPerTrack: Double = 60

    init(duration: TimeInterval, pending: TimeInterval? = nil) {
        self.duration = duration
        self.pending = pending
    }

    /// One wheel click moves 1/60 of the track, never less than one second.
    var stepSize: TimeInterval { max(1, duration / Self.stepsPerTrack) }

    var isScrubbing: Bool { pending != nil }

    /// Moves the pending position by `clicks` steps. The first click of a
    /// gesture starts from the live playback position.
    mutating func move(by clicks: Int, from livePosition: TimeInterval) {
        let base = pending ?? livePosition
        pending = Self.clamp(base + Double(clicks) * stepSize, to: duration)
    }

    /// Hands back the position to seek to and ends the gesture.
    mutating func commit() -> TimeInterval? {
        defer { pending = nil }
        return pending
    }

    mutating func cancel() {
        pending = nil
    }

    /// What the playhead shows: the pending position while scrubbing, else live.
    func displayedPosition(live: TimeInterval) -> TimeInterval {
        Self.clamp(pending ?? live, to: duration)
    }

    private static func clamp(_ value: TimeInterval, to duration: TimeInterval) -> TimeInterval {
        min(max(value, 0), max(0, duration))
    }
}

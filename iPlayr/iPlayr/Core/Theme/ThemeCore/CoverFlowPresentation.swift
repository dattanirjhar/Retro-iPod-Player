import Foundation

/// Keeps immersive browsing mounted while playback uses the normal iPod screen.
struct CoverFlowPresentation: Hashable, Sendable {
    enum Phase: Hashable, Sendable {
        case inactive, browsing, playback
    }

    private(set) var phase: Phase = .inactive
    var isPresented: Bool { phase != .inactive }
    var isVisible: Bool { phase == .browsing }

    mutating func present() { phase = .browsing }

    @discardableResult
    mutating func beginPlayback() -> Bool {
        guard phase == .browsing else { return false }
        phase = .playback
        return true
    }

    mutating func resume() {
        guard phase == .playback else { return }
        phase = .browsing
    }

    mutating func dismiss() { phase = .inactive }
}

/// A close first neighbour, then a tightly overlapping fan of farther albums.
enum CoverFlowLayout {
    static let neighbourDistance = 0.70
    static let stackStep = 0.36

    static func horizontalOffset(position: Double, coverSize: Double) -> Double {
        let distance = abs(position)
        let magnitude = distance <= 1
            ? distance * neighbourDistance
            : neighbourDistance + (distance - 1) * stackStep
        return (position < 0 ? -magnitude : magnitude) * coverSize
    }
}

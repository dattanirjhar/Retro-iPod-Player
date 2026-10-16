import CoreGraphics

/// Layout constants shared by CoverFlowView and AlbumCover. Track lists use
/// the available content area instead of an independently sized flip card.
enum CoverFlowMetrics {
    /// Width/height of a cover in its face-down (album art) state.
    static let coverSize: CGFloat = 160
    /// Horizontal distance, in points, the carousel scrolls per index step.
    static let itemStep: CGFloat = 180
    /// Strength of the 3D rotation applied to off-center covers (0...1).
    static let tilt: CGFloat = 0.7
    // Horizontal placement comes from the Foundation-only CoverFlowLayout model.
    /// Number of covers rendered on each side of the selected index.
    static let windowRadius = 5
}

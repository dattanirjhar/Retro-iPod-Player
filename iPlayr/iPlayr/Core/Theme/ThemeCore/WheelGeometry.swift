import Foundation

enum WheelRegion: Hashable, Sendable {
    case center, menu, next, playPause, previous, none
}

/// Pure click-wheel geometry. It has no notion of style, so the hit map is
/// identical for Classic and Minimal + Icons by construction.
struct WheelGeometry: Hashable, Sendable {
    /// Size of the hit disc's own frame: the wheel plus slop on every side.
    let frameSize: CGFloat
    let diameter: CGFloat
    static let slop: CGFloat = 8

    init(diameter: CGFloat) {
        self.diameter = diameter
        frameSize = diameter + Self.slop * 2
    }

    var center: CGPoint { CGPoint(x: frameSize / 2, y: frameSize / 2) }
    var outerRadius: CGFloat { diameter / 2 }
    /// Centre button: 36% of the wheel diameter.
    var centerDiameter: CGFloat { diameter * 0.36 }
    var centerRadius: CGFloat { centerDiameter / 2 }
    /// Labels sit at the ring's mid-radius (68% of the outer radius).
    var labelRadius: CGFloat { outerRadius * 0.68 }

    /// Angle in degrees from the top, clockwise.
    func angle(at point: CGPoint) -> CGFloat {
        var deg = atan2(point.x - center.x, center.y - point.y) * 180 / .pi
        if deg < 0 { deg += 360 }
        return deg
    }

    func radius(at point: CGPoint) -> CGFloat {
        hypot(point.x - center.x, point.y - center.y)
    }

    /// Centre circle, then four 90° sectors of the annulus centred on top,
    /// right, bottom and left, extended 8pt past the outer edge.
    func region(at point: CGPoint) -> WheelRegion {
        let r = radius(at: point)
        if r <= centerRadius { return .center }
        guard r <= outerRadius + Self.slop else { return .none }
        switch angle(at: point) {
        case 315..<360, 0..<45: return .menu
        case 45..<135: return .next
        case 135..<225: return .playPause
        default: return .previous
        }
    }

    func labelPosition(for region: WheelRegion) -> CGPoint {
        switch region {
        case .menu: return CGPoint(x: center.x, y: center.y - labelRadius)
        case .next: return CGPoint(x: center.x + labelRadius, y: center.y)
        case .playPause: return CGPoint(x: center.x, y: center.y + labelRadius)
        case .previous: return CGPoint(x: center.x - labelRadius, y: center.y)
        case .center, .none: return center
        }
    }

    /// Polygon outline of a region's 90° annular sector (outer arc then inner arc back).
    func sectorOutline(for region: WheelRegion, steps: Int = 24) -> [CGPoint] {
        let centerAngle: CGFloat
        switch region {
        case .menu: centerAngle = 0
        case .next: centerAngle = 90
        case .playPause: centerAngle = 180
        case .previous: centerAngle = 270
        case .center, .none: return []
        }
        let start = centerAngle - 45, end = centerAngle + 45
        func point(_ deg: CGFloat, _ radius: CGFloat) -> CGPoint {
            let rad = deg * .pi / 180
            return CGPoint(x: center.x + radius * sin(rad), y: center.y - radius * cos(rad))
        }
        var points: [CGPoint] = []
        for i in 0...steps { points.append(point(start + (end - start) * CGFloat(i) / CGFloat(steps), outerRadius)) }
        for i in stride(from: steps, through: 0, by: -1) { points.append(point(start + (end - start) * CGFloat(i) / CGFloat(steps), centerRadius)) }
        return points
    }
}

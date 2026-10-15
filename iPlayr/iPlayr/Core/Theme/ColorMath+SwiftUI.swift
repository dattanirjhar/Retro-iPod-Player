import SwiftUI

extension RGB {
    var color: Color { Color(red: r, green: g, blue: b) }
}

extension Color {
    static func hex(_ value: String) -> Color { RGB.hex(value).color }
}

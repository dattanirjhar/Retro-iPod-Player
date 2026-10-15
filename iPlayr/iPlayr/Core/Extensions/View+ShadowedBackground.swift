import SwiftUI

struct ShadowedBackground: ViewModifier {
    @Environment(ThemeManager.self) private var theme
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(theme.tokens().screenBackground.color)
                    .shadow(color: .black.opacity(0.7), radius: 8, x: 4, y: 0)
            )
    }
}

extension View {
    func shadowedBackground() -> some View {
        modifier(ShadowedBackground())
    }
}

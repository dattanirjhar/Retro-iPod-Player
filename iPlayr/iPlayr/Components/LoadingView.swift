import SwiftUI

struct LoadingView: View {
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        ProgressView()
            .tint(theme.tokens().mutedText.color)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

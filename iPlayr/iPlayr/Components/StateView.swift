import SwiftUI

enum ViewState: Equatable {
    case loading
    case content
    case empty(message: String)
    case error(message: String)
}

struct StateView: View {
    let state: ViewState
    @Environment(ThemeManager.self) private var theme
    
    var body: some View {
        switch state {
        case .loading:
            LoadingView()
        case .empty(let message):
            VStack(spacing: 16) {
                Image(systemName: ImageNames.System.musicNoteList)
                    .font(.system(size: 40))
                    .foregroundColor(theme.tokens().secondaryText.color)
                Text(message)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.tokens().secondaryText.color)
                    .minimumScaleFactor(0.4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: ImageNames.System.xCircle)
                    .font(.system(size: 40))
                    .foregroundColor(.red.opacity(0.6))
                Text(message)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.tokens().secondaryText.color)
                    .minimumScaleFactor(0.4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .content:
            EmptyView()
        }
    }
}

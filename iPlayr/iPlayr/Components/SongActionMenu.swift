import SwiftUI

enum SongAction: CaseIterable {
    case playNow, playNext, addToQueue

    var title: String {
        switch self {
        case .playNow: String(localized: "Play Now")
        case .playNext: String(localized: "Play Next")
        case .addToQueue: String(localized: "Add to End of Queue")
        }
    }
}

/// What a row offers when the user holds SELECT on it.
struct QueueCandidate {
    let item: QueueableItem
    let title: String
}

/// The panel that slides in over a list when SELECT is held on a song. It owns
/// the wheel while visible: SELECT picks the highlighted action, MENU dismisses.
struct SongActionMenu: View {
    let title: String
    let onPick: (SongAction) -> Void
    let onDismiss: () -> Void

    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(ThemeManager.self) private var theme
    @State private var scope = FocusScope(id: "songActions")

    var body: some View {
        let tokens = theme.tokens()
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .foregroundStyle(tokens.primaryText.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(tokens.panelBackground.color)
            Rectangle()
                .fill(tokens.divider.color)
                .frame(height: 1)
            ForEach(Array(SongAction.allCases.enumerated()), id: \.offset) { index, action in
                MenuItemView(menu: Menu(name: action.title, next: false), isSelected: scope.selection == index)
            }
            Spacer(minLength: 0)
        }
        .background(tokens.screenBackground.color)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(tokens.divider.color)
                .frame(width: 1)
        }
        .shadow(color: .black.opacity(0.5), radius: 10, x: -4, y: 0)
        .onAppear {
            scope.configure(itemCount: SongAction.allCases.count)
            scope.onAction = { action in
                switch action {
                case .menu: onDismiss()
                case .select:
                    let actions = SongAction.allCases
                    guard actions.indices.contains(scope.selection) else { return }
                    onPick(actions[scope.selection])
                default: break
                }
            }
            iPlayrController.activate(scope)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "Song actions for \(title)"))
    }
}

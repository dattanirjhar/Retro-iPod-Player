import SwiftUI

struct Menu: Identifiable, Equatable {
    var id: Int = 0
    let name: String
    let next: Bool
    var value: String? = nil
}

struct MenuItemView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(\.colorSchemeContrast) private var contrast
    var menu: Menu
    var isSelected: Bool

    private var tokens: InterfaceTokens { theme.tokens(increasedContrast: contrast == .increased) }

    var body: some View {
        let tokens = tokens
        HStack(spacing: 8) {
            Text(menu.name)
                .font(.system(size: 17, weight: .regular))
                .lineLimit(1)
            Spacer(minLength: 0)
            if let value = menu.value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? tokens.selectionText.color.opacity(0.85) : tokens.mutedText.color)
            } else if menu.next && isSelected {
                Image(systemName: ImageNames.System.chevronRight)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(isSelected ? tokens.selectionText.color : tokens.primaryText.color)
        .background(SelectedRowBackground(tokens: tokens, isSelected: isSelected))
    }
}

/// Selected rows use the derived selection colour; unselected rows sit on the
/// screen surface so menus read as one stable panel.
struct SelectedRowBackground: View {
    let tokens: InterfaceTokens
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Rectangle().fill(tokens.selectionBackground.color)
        } else {
            Rectangle().fill(tokens.screenBackground.color)
        }
    }
}

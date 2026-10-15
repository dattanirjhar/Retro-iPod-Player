import SwiftUI
import MusicKit

struct CollectionMenuModel: Equatable {
    let artwork: Artwork?
    let name: String
    let description: String
}

struct CollectionMenuItem: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(\.colorSchemeContrast) private var contrast
    var model: CollectionMenuModel
    var isSelected: Bool

    var body: some View {
        let tokens = theme.tokens(increasedContrast: contrast == .increased)
        HStack(spacing: 10) {
            artworkView
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(model.name)
                    .font(.system(size: 17, weight: .regular))
                    .lineLimit(1)
                if !model.description.isEmpty {
                    Text(model.description)
                        .font(.system(size: 14))
                        .foregroundStyle(isSelected ? tokens.selectionText.color.opacity(0.8) : tokens.secondaryText.color)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            if isSelected {
                Image(systemName: ImageNames.System.chevronRight)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .foregroundColor(isSelected ? tokens.selectionText.color : tokens.primaryText.color)
        .background(SelectedRowBackground(tokens: tokens, isSelected: isSelected))
    }

    @ViewBuilder
    private var artworkView: some View {
        if let artwork = model.artwork {
            ArtworkImage(artwork, width: 44, height: 44)
        } else {
            Image(ImageNames.Custom.coverPlaceholder)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
    }
}

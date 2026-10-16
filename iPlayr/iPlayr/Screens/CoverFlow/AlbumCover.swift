import SwiftUI
import MusicKit

struct AlbumCover: View {
    let album: Album
    var coverSize: CGFloat = CoverFlowMetrics.coverSize

    var body: some View {
        albumArtwork
            .frame(width: coverSize, height: coverSize)
            .reflection()
    }

    @ViewBuilder
    private var albumArtwork: some View {
        Group {
            if let artwork = album.artwork {
                ArtworkImage(artwork, width: coverSize, height: coverSize)
            } else {
                Image(ImageNames.Custom.coverPlaceholder)
                    .resizable()
                    .frame(width: coverSize, height: coverSize)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}

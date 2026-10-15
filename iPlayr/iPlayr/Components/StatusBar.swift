import SwiftUI

struct StatusBar: View {
    static let height: CGFloat = 26

    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(ThemeManager.self) private var theme
    @Environment(\.colorSchemeContrast) private var contrast
    var title: String
    @State private var batteryLevel = UIDevice.current.batteryLevel

    var body: some View {
        let tokens = theme.tokens(increasedContrast: contrast == .increased)
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Text(title)
                    .foregroundColor(tokens.primaryText.color)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if playerManager.isPlaying || playerManager.isPaused {
                    Image(systemName: playerManager.isPlaying ? "play.fill" : "pause.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tokens.secondaryText.color)
                }
                if playerManager.shuffleMode == .songs || playerManager.isShufflingAlbums {
                    Image(systemName: ImageNames.System.shuffle)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tokens.secondaryText.color)
                }
                switch playerManager.repeatMode {
                case .all:
                    Image(systemName: ImageNames.System.repeatAll)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tokens.secondaryText.color)
                case .one:
                    Image(systemName: ImageNames.System.repeatOne)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tokens.secondaryText.color)
                default: EmptyView()
                }
                BatteryIconView(level: CGFloat(batteryLevel), ink: tokens.primaryText.color)
                    .frame(width: 28, height: 14)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height - 1)
            .background(tokens.panelBackground.color)
            Rectangle()
                .fill(tokens.divider.color)
                .frame(maxWidth: .infinity, maxHeight: 1)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            batteryLevel = UIDevice.current.batteryLevel
        }
    }
}

/// A flat battery glyph: primaryText fill, #E5484D below 20%.
struct BatteryIconView: View {
    var level: CGFloat
    var ink: Color

    private static let lowChargeThreshold: CGFloat = 0.2
    private static let lowColor = Color.hex("E5484D")

    private var fill: Color { level < Self.lowChargeThreshold ? Self.lowColor : ink }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(ink.opacity(0.7), lineWidth: 1)
                .frame(width: 24, height: 12)
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(fill)
                .frame(width: max(0, 20 * min(max(level, 0), 1)), height: 8)
                .offset(x: 2)
            RoundedRectangle(cornerRadius: 0.5)
                .fill(ink.opacity(0.7))
                .frame(width: 2, height: 5)
                .offset(x: 25)
        }
        .padding(1)
        .frame(width: 28, height: 14)
        .accessibilityLabel("Battery \(Int(max(0, min(1, level)) * 100)) percent")
    }
}

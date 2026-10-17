import SwiftUI
import MusicKit

struct SettingsView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(\.navigate) private var navigate
    @AppStorage(UserDefaultsKeys.hapticsEnabled.rawValue) private var hapticsEnabled: Bool = true
    @AppStorage(UserDefaultsKeys.soundsEnabled.rawValue) private var soundsEnabled: Bool = true
    @State private var scope = FocusScope(id: "settings")

    private enum Row: CaseIterable {
        case appSettings, about
        case shuffle, repeatMode, sortOrder, mainMenu, musicMenu, brightness, haptics, sounds
    }

    private func menu(for row: Row) -> Menu {
        switch row {
        case .appSettings:
            return Menu(name: String(localized: "App Settings"), next: true)
        case .about:
            return Menu(name: String(localized: "About"), next: true)
        case .shuffle:
            return Menu(name: String(localized: "Shuffle"), next: false, value: shuffleValue)
        case .repeatMode:
            return Menu(name: String(localized: "Repeat"), next: false, value: repeatValue)
        case .sortOrder:
            return Menu(name: String(localized: "Sort Order"), next: false, value: libraryStore.sortOrder.rawValue)
        case .mainMenu:
            return Menu(name: String(localized: "Main Menu"), next: true)
        case .musicMenu:
            return Menu(name: String(localized: "Music Menu"), next: true)
        case .brightness:
            return Menu(name: String(localized: "Brightness"), next: true)
        case .haptics:
            return Menu(name: String(localized: "Haptics"), next: false, value: onOff(hapticsEnabled))
        case .sounds:
            return Menu(name: String(localized: "Clicker"), next: false, value: onOff(soundsEnabled))
        }
    }

    private var shuffleValue: String {
        if playerManager.isShufflingAlbums { return String(localized: "Albums") }
        return playerManager.shuffleMode == .songs ? String(localized: "Songs") : String(localized: "Off")
    }

    private var repeatValue: String {
        switch playerManager.repeatMode {
        case .one: return String(localized: "One")
        case .all: return String(localized: "All")
        default: return String(localized: "Off")
        }
    }

    private func onOff(_ isOn: Bool) -> String {
        isOn ? String(localized: "On") : String(localized: "Off")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Settings"))
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(Row.allCases.enumerated()), id: \.offset) { index, row in
                            MenuItemView(menu: menu(for: row), isSelected: scope.selection == index)
                                .id(index)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: scope.selection) { _, newIndex in
                    proxy.scrollTo(newIndex)
                }
            }
        }
        .shadowedBackground()
        .onAppear(perform: setup)
    }

    private func setup() {
        scope.configure(itemCount: Row.allCases.count)
        scope.onAction = { handleButtonAction($0) }
        iPlayrController.activate(scope)
    }

    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .menu:
            navigate(.pop)
        case .select:
            handleSelect()
        default:
            break
        }
    }

    private func handleSelect() {
        guard Row.allCases.indices.contains(scope.selection) else { return }
        switch Row.allCases[scope.selection] {
        case .appSettings:
            navigate(.push(.theme))
        case .about:
            navigate(.push(.about))
        case .shuffle:
            playerManager.setShuffleMode(playerManager.shuffleMode == .songs ? .off : .songs)
        case .repeatMode:
            playerManager.setRepeatMode(nextRepeatMode)
        case .sortOrder:
            libraryStore.setSortOrder(libraryStore.sortOrder.next)
        case .mainMenu:
            navigate(.push(.menuCustomization(isMainMenu: true)))
        case .musicMenu:
            navigate(.push(.menuCustomization(isMainMenu: false)))
        case .brightness:
            navigate(.push(.brightness))
        case .haptics:
            hapticsEnabled.toggle()
        case .sounds:
            soundsEnabled.toggle()
        }
    }

    private var nextRepeatMode: MusicPlayer.RepeatMode {
        switch playerManager.repeatMode {
        case .none: return .all
        case .all: return .one
        default: return MusicPlayer.RepeatMode.none
        }
    }
}

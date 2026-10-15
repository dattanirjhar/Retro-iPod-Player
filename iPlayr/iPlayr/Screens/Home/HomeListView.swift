import SwiftUI
import MusicKit

struct HomeListView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(MusicAuthorizationManager.self) private var authManager
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(MenuPreferences.self) private var menuPreferences
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "home")

    private var entries: [(menu: Menu, route: Route)] {
        var entries: [(menu: Menu, route: Route)] = [
            (.init(name: String(localized: "Music"), next: true), .music),
        ]
        entries += menuPreferences.mainMenuShortcuts.map {
            (Menu(name: $0.title, next: true), $0.route)
        }
        if authManager.isAuthorized {
            entries += [
                (.init(name: String(localized: "Shuffle Songs"), next: false), .player(source: .shuffleAll, trackIndex: 0)),
                (.init(name: String(localized: "Shuffle Albums"), next: false), .player(source: .shuffleAlbums, trackIndex: 0)),
            ]
        }
        entries += [
            (.init(name: String(localized: "Extras"), next: true), .extras),
            (.init(name: String(localized: "Settings"), next: true), .settings),
        ]
        if !authManager.isAuthorized {
            entries.append((.init(name: String(localized: "Sign In"), next: true), .signIn))
        }
        if playerManager.currentTrack != nil {
            entries.append((.init(name: String(localized: "Now Playing"), next: true), .nowPlaying))
        }
        return entries
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "iPlayr"))
            // Scrollable like every other menu: with several main-menu shortcuts
            // enabled plus the shuffle, Sign In and Now Playing rows, a plain
            // VStack overflowed the 300pt screen and hid the bottom entries.
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(entries.indices, id: \.self) { index in
                            MenuItemView(menu: entries[index].menu, isSelected: scope.selection == index)
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
        .onChange(of: entries.count) { _, count in
            scope.itemCount = count
        }
    }

    private func setup() {
        scope.configure(itemCount: entries.count)
        scope.onAction = { handleButtonAction($0) }
        iPlayrController.activate(scope)
    }

    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .select:
            guard entries.indices.contains(scope.selection) else { return }
            navigate(.push(entries[scope.selection].route))
        default: break
        }
    }
}

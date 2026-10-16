import SwiftUI

/// The player's queue, opened by holding SELECT on Now Playing. SELECT jumps
/// to an entry; MENU returns to Now Playing.
struct QueueView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "queue")

    private var entries: [QueueEntryInfo] { playerManager.queueEntries }

    private var title: String {
        if let position = playerManager.queuePosition {
            return String(localized: "Queue") + " · " + position
        }
        return String(localized: "Queue")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: title)
            if entries.isEmpty {
                StateView(state: .empty(message: String(localized: "Nothing queued\nPlay something, then come back")))
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(entries.indices, id: \.self) { index in
                                let entry = entries[index]
                                CollectionMenuItem(
                                    model: CollectionMenuModel(artwork: entry.artwork, name: entry.title, description: entry.subtitle),
                                    isSelected: scope.selection == index,
                                    trailingSymbol: entry.isCurrent ? "speaker.wave.2.fill" : nil
                                )
                                .id(index)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: scope.selection) { _, index in proxy.scrollTo(index) }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(scope.selection)
                        }
                    }
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
        let current = entries.firstIndex { $0.isCurrent } ?? 0
        scope.configure(itemCount: entries.count, selection: current)
        scope.onAction = { action in
            switch action {
            case .menu:
                navigate(.pop)
            case .select:
                guard entries.indices.contains(scope.selection) else { return }
                let id = entries[scope.selection].id
                Task { try? await playerManager.jump(toEntryID: id) }
            default:
                break
            }
        }
        iPlayrController.activate(scope)
    }
}

import SwiftUI

struct LibraryListView<Item, Row: View>: View {
    let title: String
    let emptyMessage: String
    let cached: () -> [Item]?
    let load: () async -> [Item]?
    let onSelect: (Item, Int) -> Void
    /// Rows that return a candidate get the hold-SELECT song menu
    /// (Play Now / Play Next / Add to End of Queue). Nil for non-song lists.
    let queueCandidate: ((Item) -> QueueCandidate?)?
    let row: (Item, Bool) -> Row

    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(MusicLibraryStore.self) private var libraryStore
    @Environment(AppleMusicManager.self) private var playerManager
    @Environment(\.navigate) private var navigate
    @State private var scope: FocusScope
    @State private var viewState: ViewState = .loading
    @State private var items: [Item] = []
    @State private var actionIndex: Int?

    init(
        title: String,
        scopeID: String,
        emptyMessage: String,
        cached: @escaping () -> [Item]? = { nil },
        load: @escaping () async -> [Item]?,
        onSelect: @escaping (Item, Int) -> Void,
        queueCandidate: ((Item) -> QueueCandidate?)? = nil,
        @ViewBuilder row: @escaping (Item, Bool) -> Row
    ) {
        self.title = title
        self.emptyMessage = emptyMessage
        self.cached = cached
        self.load = load
        self.onSelect = onSelect
        self.queueCandidate = queueCandidate
        self.row = row
        _scope = State(initialValue: FocusScope(id: scopeID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: title)
            ZStack {
                if viewState == .content {
                    itemList
                }
                StateView(state: viewState)
            }
        }
        .overlay(alignment: .trailing) { songActionOverlay }
        .shadowedBackground()
        .onAppear(perform: setup)
        .taskAfterNavigation { await loadItems() }
    }

    private var itemList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        row(items[index], index == scope.selection)
                            .id(index)
                    }
                }
            }
            .onChange(of: scope.selection) { _, newIndex in
                proxy.scrollTo(newIndex)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(scope.selection)
                }
            }
        }
    }

    /// Slides in over the list when SELECT is held on a queueable row.
    @ViewBuilder
    private var songActionOverlay: some View {
        if let index = actionIndex, items.indices.contains(index), let candidate = queueCandidate?(items[index]) {
            SongActionMenu(title: candidate.title,
                           onPick: { action in perform(action, candidate: candidate, index: index) },
                           onDismiss: dismissActions)
                .frame(width: 236)
                .frame(maxHeight: .infinity)
                .padding(.top, StatusBar.height)
                .transition(.move(edge: .trailing))
        }
    }

    private func setup() {
        scope.onAction = { handleButtonAction($0) }
        iPlayrController.activate(scope)
        applyCachedItems()
    }

    private func applyCachedItems() {
        guard let cachedItems = cached(), !cachedItems.isEmpty else { return }
        items = cachedItems
        scope.configure(itemCount: cachedItems.count)
        viewState = .content
    }

    private func loadItems() async {
        guard viewState != .content else { return }
        viewState = .loading

        guard let loadedItems = await load() else {
            viewState = .error(message: libraryStore.errorMessage ?? String(localized: "An error occurred\nPlease try again later"))
            return
        }

        items = loadedItems
        guard !loadedItems.isEmpty else {
            viewState = .empty(message: emptyMessage)
            return
        }
        scope.configure(itemCount: loadedItems.count)
        viewState = .content
    }

    private func handleButtonAction(_ action: ButtonAction) {
        switch action {
        case .menu:
            navigate(.pop)
        case .select:
            guard items.indices.contains(scope.selection) else { return }
            onSelect(items[scope.selection], scope.selection)
        case .selectLongPress:
            guard let queueCandidate, items.indices.contains(scope.selection),
                  queueCandidate(items[scope.selection]) != nil else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                actionIndex = scope.selection
            }
        default:
            break
        }
    }

    private func perform(_ action: SongAction, candidate: QueueCandidate, index: Int) {
        dismissActions()
        switch action {
        case .playNow:
            onSelect(items[index], index)
        case .playNext:
            Task { try? await playerManager.playNext(candidate.item) }
        case .addToQueue:
            Task { try? await playerManager.addToQueue(candidate.item) }
        }
    }

    private func dismissActions() {
        withAnimation(.easeIn(duration: 0.18)) {
            actionIndex = nil
        }
        iPlayrController.activate(scope)
    }
}

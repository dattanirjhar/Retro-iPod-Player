import SwiftUI

// MARK: - Appearance hub: exactly two visual rows, plus Language and Immersive Mode

struct ThemeView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "appearance")

    private enum Row: CaseIterable { case theme, mode, language, immersive }

    private func menu(for row: Row) -> Menu {
        switch row {
        case .theme: Menu(name: AppearanceSetting.theme.title, next: true, value: theme.savedTheme.name)
        case .mode: Menu(name: AppearanceSetting.mode.title, next: true, value: theme.savedMode.title)
        case .language: Menu(name: AppearanceSetting.language.title, next: true, value: theme.language.title)
        case .immersive: Menu(name: String(localized: "Immersive Mode"), next: false,
                              value: theme.immersiveMode ? String(localized: "On") : String(localized: "Off"))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Appearance"))
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
                .onChange(of: scope.selection) { _, index in proxy.scrollTo(index) }
            }
        }
        .shadowedBackground()
        .onAppear {
            scope.configure(itemCount: Row.allCases.count)
            scope.onAction = handleAction
            iPlayrController.activate(scope)
        }
    }

    private func handleAction(_ action: ButtonAction) {
        switch action {
        case .menu: navigate(.pop)
        case .select:
            guard Row.allCases.indices.contains(scope.selection) else { return }
            switch Row.allCases[scope.selection] {
            case .theme: navigate(.push(.appearanceSetting(.theme)))
            case .mode: navigate(.push(.appearanceSetting(.mode)))
            case .language: navigate(.push(.appearanceSetting(.language)))
            case .immersive: theme.setImmersiveMode(!theme.immersiveMode)
            }
        default: break
        }
    }
}

// MARK: - Theme picker: grouped, live preview, confirm with centre, cancel with MENU

struct ThemePickerView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "themePicker")

    private let themes = ThemeTable.all

    private enum Row: Identifiable {
        case header(ThemeGroup)
        case theme(ThemeSpec, index: Int)
        var id: String {
            switch self {
            case .header(let group): "header-\(group.rawValue)"
            case .theme(let spec, _): spec.id
            }
        }
    }

    private var rows: [Row] {
        var result: [Row] = []
        var index = 0
        for group in ThemeGroup.allCases {
            result.append(.header(group))
            for spec in themes where spec.group == group {
                result.append(.theme(spec, index: index))
                index += 1
            }
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Theme"))
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(rows) { row in
                            switch row {
                            case .header(let group):
                                SectionHeaderRow(title: group.rawValue)
                                    .id(row.id)
                            case .theme(let spec, let index):
                                ChoiceRow(
                                    title: spec.name,
                                    swatch: AnyView(ThemeSwatch(theme: spec)),
                                    isCurrent: theme.savedTheme.id == spec.id,
                                    isSelected: scope.selection == index
                                )
                                .id(row.id)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: scope.selection) { _, index in
                    guard themes.indices.contains(index) else { return }
                    theme.preview(theme: themes[index].id)
                    proxy.scrollTo(themes[index].id)
                }
            }
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .onDisappear { theme.cancelPreview() }
    }

    private func setup() {
        let current = themes.firstIndex { $0.id == theme.savedTheme.id } ?? 0
        scope.configure(itemCount: themes.count, selection: current)
        scope.onAction = { action in
            switch action {
            case .menu:
                theme.cancelPreview()
                navigate(.pop)
            case .select:
                guard themes.indices.contains(scope.selection) else { return }
                theme.preview(theme: themes[scope.selection].id)
                theme.commitPreview()
            default: break
            }
        }
        iPlayrController.activate(scope)
    }
}

// MARK: - Mode picker: Dark / Light with the same preview, confirm, cancel

struct ModePickerView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "modePicker")

    private let modes = ScreenMode.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Mode"))
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(modes.indices, id: \.self) { index in
                        let mode = modes[index]
                        ChoiceRow(
                            title: mode.title,
                            swatch: AnyView(ModeSwatch(mode: mode, theme: theme.theme)),
                            isCurrent: theme.savedMode == mode,
                            isSelected: scope.selection == index
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: scope.selection) { _, index in
                guard modes.indices.contains(index) else { return }
                theme.preview(mode: modes[index])
            }
        }
        .shadowedBackground()
        .onAppear(perform: setup)
        .onDisappear { theme.cancelPreview() }
    }

    private func setup() {
        let current = modes.firstIndex(of: theme.savedMode) ?? 0
        scope.configure(itemCount: modes.count, selection: current)
        scope.onAction = { action in
            switch action {
            case .menu:
                theme.cancelPreview()
                navigate(.pop)
            case .select:
                guard modes.indices.contains(scope.selection) else { return }
                theme.preview(mode: modes[scope.selection])
                theme.commitPreview()
            default: break
            }
        }
        iPlayrController.activate(scope)
    }
}

// MARK: - Language picker (unchanged behaviour: applies on select)

struct LanguagePickerView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(ThemeManager.self) private var theme
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "languagePicker")

    private let languages = AppLanguage.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Language"))
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(languages.indices, id: \.self) { index in
                        ChoiceRow(title: languages[index].title, swatch: nil,
                                  isCurrent: theme.language == languages[index],
                                  isSelected: scope.selection == index)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .shadowedBackground()
        .onAppear {
            scope.configure(itemCount: languages.count, selection: languages.firstIndex(of: theme.language) ?? 0)
            scope.onAction = { action in
                switch action {
                case .menu: navigate(.pop)
                case .select where languages.indices.contains(scope.selection): theme.set(languages[scope.selection])
                default: break
                }
            }
            iPlayrController.activate(scope)
        }
    }
}

// MARK: - Rows and swatches

/// A non-focusable group header in the theme list.
struct SectionHeaderRow: View {
    let title: String
    @Environment(ThemeManager.self) private var theme

    var body: some View {
        let tokens = theme.tokens()
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.6)
            .foregroundStyle(tokens.mutedText.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 3)
            .background(tokens.screenBackground.color)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A row with an optional swatch, a title, and a tick when it is the saved value.
struct ChoiceRow: View {
    let title: String
    var swatch: AnyView? = nil
    let isCurrent: Bool
    let isSelected: Bool
    @Environment(ThemeManager.self) private var theme
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let tokens = theme.tokens(increasedContrast: contrast == .increased)
        HStack(spacing: 10) {
            if let swatch { swatch }
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .lineLimit(1)
            Spacer(minLength: 0)
            if isCurrent {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(isSelected ? tokens.selectionText.color : tokens.primaryText.color)
        .background(SelectedRowBackground(tokens: tokens, isSelected: isSelected))
    }
}

/// Body disc, wheel ring, accent dot.
struct ThemeSwatch: View {
    let theme: ThemeSpec

    var body: some View {
        ZStack {
            Circle().fill(theme.body.color)
            Circle()
                .strokeBorder(theme.wheel.color, lineWidth: theme.wheelStyle == .classic ? 5 : 2)
                .padding(3)
            Circle()
                .fill(theme.accent.color)
                .frame(width: 6, height: 6)
        }
        .frame(width: 24, height: 24)
        .overlay(Circle().strokeBorder(Color.black.opacity(0.25), lineWidth: 0.5))
    }
}

/// That mode's screen background with a line of its primary text.
struct ModeSwatch: View {
    let mode: ScreenMode
    let theme: ThemeSpec

    var body: some View {
        let tokens = InterfaceTokens.resolve(theme: theme, mode: mode)
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(tokens.screenBackground.color)
            Text("Aa")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tokens.primaryText.color)
        }
        .frame(width: 28, height: 22)
        .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).strokeBorder(Color.black.opacity(0.25), lineWidth: 0.5))
    }
}

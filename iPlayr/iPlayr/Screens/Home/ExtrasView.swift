import SwiftUI

struct ExtrasView: View {
    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "extras")

    private var rows: [(Menu, Route)] {
        [
            (Menu(name: String(localized: "About"), next: true), .about),
            (Menu(name: String(localized: "Brightness"), next: true), .brightness),
            (Menu(name: String(localized: "Tutorial"), next: true), .info(.tutorial)),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: String(localized: "Extras"))
            ForEach(rows.indices, id: \.self) { index in
                MenuItemView(menu: rows[index].0, isSelected: scope.selection == index)
            }
            Spacer()
        }
        .shadowedBackground()
        .onAppear {
            scope.configure(itemCount: rows.count)
            scope.onAction = { action in
                switch action {
                case .menu: navigate(.pop)
                case .select where rows.indices.contains(scope.selection): navigate(.push(rows[scope.selection].1))
                default: break
                }
            }
            iPlayrController.activate(scope)
        }
    }
}

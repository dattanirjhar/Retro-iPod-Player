import SwiftUI

struct InfoPageView: View {
    let page: InfoPage

    @Environment(iPlayrButtonController.self) private var iPlayrController
    @Environment(\.navigate) private var navigate
    @State private var scope = FocusScope(id: "infoPage")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBar(title: page.title)
            ScrollView {
                Text(page.message)
                    .font(.system(size: 15, weight: .medium))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            Spacer(minLength: 0)
        }
        .shadowedBackground()
        .onAppear {
            scope.configure(itemCount: 0)
            scope.onAction = { if $0 == .menu { navigate(.pop) } }
            iPlayrController.activate(scope)
        }
    }
}

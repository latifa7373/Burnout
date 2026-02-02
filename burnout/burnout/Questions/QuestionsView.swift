import SwiftUI

struct QuestionsView: View {
    @StateObject private var viewModel = QuestionsViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            Text("Questions Page 1")
                .tag(0)
            Text("Questions Page 2")
                .tag(1)
            Text("Questions Page 3")
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    QuestionsView()
}



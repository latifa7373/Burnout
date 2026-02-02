import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            Text("Welcome Page 1")
                .tag(0)
            Text("Welcome Page 2")
                .tag(1)
            Text("Welcome Page 3")
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    WelcomeView()
}




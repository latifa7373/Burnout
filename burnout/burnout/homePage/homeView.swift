import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        Text("Main Screen")
            .font(.title)
    }
}

#Preview {
    MainView()
}



import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Text("Splash Screen")
                .font(.largeTitle)
        }
    }
}

#Preview {
    SplashView()
}



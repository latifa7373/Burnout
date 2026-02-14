import SwiftUI
import SwiftData

@main
struct burnoutApp: App {
    @StateObject private var splashViewModel = SplashViewModel()

    init() {
        UIView.appearance().semanticContentAttribute = .unspecified
    }

    var body: some Scene {
        WindowGroup {
            SplashView(viewModel: splashViewModel)
        }
        .modelContainer(for: [QuestionResponse.self, DailyRiskScore.self])    }
}

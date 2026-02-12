import SwiftUI
import SwiftData

@main
struct burnoutApp: App {

    init() {
        UIView.appearance().semanticContentAttribute = .unspecified
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [QuestionResponse.self])
    }
}

import SwiftUI
import Combine

class WelcomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var currentPage: Int = 1
    @Published var selectedDays: Set<String> = []
    @Published var workEndTime = Date()
}

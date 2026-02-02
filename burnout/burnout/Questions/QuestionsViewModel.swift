import Foundation
import Combine

final class QuestionsViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var model = QuestionsModel()
}



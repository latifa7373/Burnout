import Foundation
import Combine

final class WelcomeViewModel: ObservableObject {
    // هنا تقدر تضيف منطق الـ onboarding (التنقل بين الصفحات الثلاث مثلاً)
    @Published var currentPage: Int = 0
}



import Foundation
import Combine

final class SplashViewModel: ObservableObject {
    // هنا تقدر تحط منطق الانتقال من شاشة الـ Splash إلى الشاشات الأخرى
    @Published var isFinished: Bool = false
}



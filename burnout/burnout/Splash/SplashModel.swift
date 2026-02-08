import Foundation

struct SplashModel {
    // بيانات الفيديو
    let videoName: String = "bbb"
    let videoRate: Float = 0.9
    
    // بيانات الصورة
    let imageName: String = "logo"
    let imageWidth: CGFloat = 150
    let imageHeight: CGFloat = 150
    
    // بيانات النصوص
    let titleText: String = "Burn-Out"
    let titleFontSize: CGFloat = 32
    let subtitleText: String = "Out the burnout"
    let subtitleFontSize: CGFloat = 18
    
    // إعدادات الموضع والحجم
    let videoScale: CGFloat = 1.0
    let videoOffsetX: CGFloat = 0
    let videoOffsetY: CGFloat = 0
    let contentOffsetX: CGFloat = 0
    let contentOffsetY: CGFloat = -80  // رفع اللوقو والنص قليلاً (قيمة سالبة = فوق)
    let subtitleOffsetY: CGFloat = 150
}



import Foundation

// MARK: - User Model
struct WelcomeUser {
    var name: String
    var workDays: Set<String>
    var workEndTime: Date
    
    init(name: String = "", workDays: Set<String> = [], workEndTime: Date = Date()) {
        self.name = name
        self.workDays = workDays
        self.workEndTime = workEndTime
    }
}

// MARK: - Days Model
struct WorkDay {
    static let allDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Get localized day name dynamically based on device language
    static func localizedName(for day: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // ← يأخذ لغة الجهاز تلقائياً
        
        // نحول الاختصار لرقم اليوم في الأسبوع
        let dayIndex: Int
        switch day {
        case "Sun": dayIndex = 1
        case "Mon": dayIndex = 2
        case "Tue": dayIndex = 3
        case "Wed": dayIndex = 4
        case "Thu": dayIndex = 5
        case "Fri": dayIndex = 6
        case "Sat": dayIndex = 7
        default: return day
        }
        
        // نجيب اسم اليوم المختصر من الـ DateFormatter
        return formatter.shortWeekdaySymbols[dayIndex - 1]
    }
}

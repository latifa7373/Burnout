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
}

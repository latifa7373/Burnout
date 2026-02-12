import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var model = ProfileModel()
    @Published var isEditing: Bool = false
    @Published var tempUserName: String = ""
    @Published var workEndTime: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 17
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }()
    @Published var tempWorkEndTime: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 17
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }()
    
    @Published var tempSelectedWorkDays: Set<Weekday> = []
    
    // استخدام UserDefaults بدلاً من @AppStorage
    private let userDefaults = UserDefaults.standard
    private let userNameKey = "userName"
    private let workEndTimeKey = "workEndTime"
    private let workDaysKey = "workDays"
    
    private var userName: String {
        get {
            userDefaults.string(forKey: userNameKey) ?? "NouraH"
        }
        set {
            userDefaults.set(newValue, forKey: userNameKey)
        }
    }
    
    private var workEndTimeString: String {
        get {
            if let value = userDefaults.string(forKey: workEndTimeKey), !value.isEmpty {
                return value
            }
            // Backward compatibility: older onboarding stored Date مباشرة.
            if let savedDate = userDefaults.object(forKey: workEndTimeKey) as? Date {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: savedDate)
            }
            return "17:00"
        }
        set {
            userDefaults.set(newValue, forKey: workEndTimeKey)
        }
    }
    
    private var selectedWorkDays: Set<Weekday> {
        get {
            let defaultDays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday]
            if let data = userDefaults.data(forKey: workDaysKey),
               let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) {
                return decoded
            }
            // Backward compatibility: older onboarding stored [String] like ["Sun","Mon"].
            if let stringDays = userDefaults.array(forKey: workDaysKey) as? [String] {
                let mapped = Set(stringDays.compactMap(mapStringDayToWeekday))
                if !mapped.isEmpty { return mapped }
            }
            return defaultDays
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: workDaysKey)
            }
        }
    }

    private func mapStringDayToWeekday(_ day: String) -> Weekday? {
        switch day.lowercased() {
        case "sun", "sunday": return .sunday
        case "mon", "monday": return .monday
        case "tue", "tues", "tuesday": return .tuesday
        case "wed", "wednesday": return .wednesday
        case "thu", "thur", "thurs", "thursday": return .thursday
        case "fri", "friday": return .friday
        case "sat", "saturday": return .saturday
        default: return nil
        }
    }
    
    init() {
        loadUserData()
    }
    
    /// يحمّل البيانات المحفوظة
    func loadUserData() {
        model.userName = userName
        model.workEndTimeString = workEndTimeString
        model.selectedWorkDays = selectedWorkDays
        tempUserName = userName
        tempSelectedWorkDays = selectedWorkDays
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let savedTime = formatter.date(from: workEndTimeString) {
            workEndTime = savedTime
            tempWorkEndTime = savedTime
        }
    }
    
    /// يحفظ البيانات بعد التعديل
    func saveChanges() {
        userName = tempUserName.isEmpty ? userName : tempUserName
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        workEndTimeString = formatter.string(from: tempWorkEndTime)
        workEndTime = tempWorkEndTime
        selectedWorkDays = tempSelectedWorkDays
        
        model.userName = userName
        model.workEndTimeString = workEndTimeString
        model.selectedWorkDays = tempSelectedWorkDays
    }
    
    /// يبدأ/ينهي وضع التعديل (بدون withAnimation - سيتم في View)
    func toggleEditing() {
        if isEditing {
            saveChanges()
        } else {
            tempUserName = userName
            tempWorkEndTime = workEndTime
            tempSelectedWorkDays = selectedWorkDays
        }
        isEditing.toggle()
    }
    
    /// يبدّل حالة يوم معيّن (يضيفه أو يشيله)
    func toggleWorkDay(_ day: Weekday) {
        if tempSelectedWorkDays.contains(day) {
            tempSelectedWorkDays.remove(day)
        } else {
            tempSelectedWorkDays.insert(day)
        }
    }
    
    /// يرجع الوقت المنسق للعرض
    func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}




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
    
    // استخدام UserDefaults بدلاً من @AppStorage
    private let userDefaults = UserDefaults.standard
    private let userNameKey = "userName"
    private let workEndTimeKey = "workEndTime"
    
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
            userDefaults.string(forKey: workEndTimeKey) ?? "17:00"
        }
        set {
            userDefaults.set(newValue, forKey: workEndTimeKey)
        }
    }
    
    init() {
        loadUserData()
    }
    
    /// يحمّل البيانات المحفوظة
    func loadUserData() {
        model.userName = userName
        model.workEndTimeString = workEndTimeString
        tempUserName = userName
        
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
        
        model.userName = userName
        model.workEndTimeString = workEndTimeString
    }
    
    /// يبدأ/ينهي وضع التعديل (بدون withAnimation - سيتم في View)
    func toggleEditing() {
        if isEditing {
            saveChanges()
        } else {
            tempUserName = userName
            tempWorkEndTime = workEndTime
        }
        isEditing.toggle()
    }
    
    /// يرجع الوقت المنسق للعرض
    func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}




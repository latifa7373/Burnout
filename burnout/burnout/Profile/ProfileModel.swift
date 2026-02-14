import Foundation

enum Weekday: String, CaseIterable, Codable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

struct ProfileModel {
    // بيانات المستخدم
    var userName: String = "NouraH"
    var workEndTimeString: String = "17:00"
    var selectedWorkDays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday]
    
    // إعدادات الواجهة
    let backgroundColorHex: String = "2C1E2F"
    let profileImageSize: CGFloat = 110
    let profileRingSize: CGFloat = 120
    let profileIconSize: CGFloat = 50
    let titleFontSize: CGFloat = 26
    let headerFontSize: CGFloat = 22
    let cardIconSize: CGFloat = 50
    let cardCornerRadius: CGFloat = 20
}

extension Weekday {
    var calendarValue: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }

    var localizedName: String {
        switch self {
        case .sunday:
            return String(localized: "Sunday")
        case .monday:
            return String(localized: "Monday")
        case .tuesday:
            return String(localized: "Tuesday")
        case .wednesday:
            return String(localized: "Wednesday")
        case .thursday:
            return String(localized: "Thursday")
        case .friday:
            return String(localized: "Friday")
        case .saturday:
            return String(localized: "Saturday")
        }
    }
}



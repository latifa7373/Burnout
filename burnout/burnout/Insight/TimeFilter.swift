import Foundation

enum TimeFilter: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

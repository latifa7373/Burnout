import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let riskScore: Double  // Daily risk score (1...5)
    let date: Date
    let isWorkDay: Bool
    let hasResponse: Bool
}

enum TimeFilter: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .week:
            return String(localized: "Week")
        case .month:
            return String(localized: "Month")
        }
    }
}

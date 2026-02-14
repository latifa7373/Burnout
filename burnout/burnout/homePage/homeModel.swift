import Foundation
import SwiftUI
import Combine

// MARK: - Model

struct BurnoutDashboardModel: Equatable {
    var userName: String

    // Final risk score used by gauge/status (average of last 3 daily averages)
    // Expected range: 1...5 when enough data exists
    var riskIndex: Double
    var riskLabel: String
    var riskSubtitle: String

    var statusCard: InfoCardModel
    var todayCard: InfoCardModel
    var insights: InsightsModel
}

struct InfoCardModel: Equatable, Identifiable {
    let id = UUID()
    var title: String
    var actionText: String
    var badgeTitle: String
    var bodyText: String
}

struct InsightsModel: Equatable {
    var averageLabel: String
    var averagePercent: Int
    var bars: [BarModel]
}

struct BarModel: Equatable, Identifiable {
    let id = UUID()
    var height: CGFloat
    var color: Color
}

import Foundation
import SwiftUI
import Combine

// MARK: - Model

struct BurnoutDashboardModel: Equatable {
    var userName: String
    var riskIndex: Double // Raw average risk score based on the latest 3 days
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


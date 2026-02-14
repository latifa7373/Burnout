import Foundation
import SwiftUI
import Combine
import SwiftData

final class HomeViewModel: ObservableObject {
    @Published var hasCompletedCheckIn: Bool = true
    @Published var isFirstTimeUser: Bool = true
    @Published var hasMinimumData: Bool = false // true only when we have 3 days
    @Published var model: BurnoutDashboardModel = BurnoutDashboardModel(
        userName: "Nourah",
        riskIndex: 0.0,
        riskLabel: "Pending",
        riskSubtitle: String(localized: "Complete 3 daily check-ins to see your burnout status."),
        statusCard: InfoCardModel(
            title: String(localized: "Status"),
            actionText: String(localized: "learn more"),
            badgeTitle: String(localized: "Pending"),
            bodyText: String(localized: "Your status will appear after 3 check-ins.")
        ),
        todayCard: InfoCardModel(
            title: String(localized: "Today's\nCheck"),
            actionText: String(localized: "View more"),
            badgeTitle: String(localized: "All Done"),
            bodyText: String(localized: "Keep checking in daily for more accurate insights")
        ),
        insights: InsightsModel(
            averageLabel: String(localized: "Insights"),
            averagePercent: 0,
            bars: [
                BarModel(height: 0, color: Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)),
                BarModel(height: 0, color: Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)),
                BarModel(height: 0, color: Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0))
            ]
        )
    )

    private let defaults = UserDefaults.standard

    // IMPORTANT:
    // Each DailyRiskScore.riskScore should be the daily average (sum of answers / 3).
    // Final dashboard risk = average of last 3 daily averages.
    func calculateRiskFromLastWeek(dailyRiskScores: [DailyRiskScore]) {
        if dailyRiskScores.isEmpty {
            applyFirstTimeState()
            return
        }

        isFirstTimeUser = false

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        hasCompletedCheckIn = dailyRiskScores.contains { calendar.startOfDay(for: $0.date) == today }
        updateTodayCard()

        let sorted = dailyRiskScores.sorted { $0.date > $1.date }

        // Always show bars for available data, but do not show final status/average before 3 days.
        if sorted.count < 3 {
            applyInsufficientDataState(riskScores: sorted)
            return
        }

        hasMinimumData = true
        let last3Days = Array(sorted.prefix(3))

        // average of 3 daily averages
        let avgRiskScore = last3Days.reduce(0.0) { $0 + $1.riskScore } / 3.0
        model.riskIndex = avgRiskScore

        let roundedAverage = (avgRiskScore * 10).rounded() / 10
        if roundedAverage <= 2.0 {
            model.riskLabel = String(localized: "Low")
            model.riskSubtitle = String(localized: "Your average over the past 3 days is in the low range.")
        } else if roundedAverage <= 3.4 {
            model.riskLabel = String(localized: "Medium")
            model.riskSubtitle = String(localized: "Your average over the past 3 days is in the medium range.")
        } else {
            model.riskLabel = String(localized: "High")
            model.riskSubtitle = String(localized: "Your average over the past 3 days is in the high range.")
        }

        updateStatusCard(riskLabel: model.riskLabel, riskSubtitle: model.riskSubtitle)
        updateInsights(riskScores: last3Days)
    }

    private func applyInsufficientDataState(riskScores: [DailyRiskScore]) {
        hasMinimumData = false

        model.riskIndex = 0.0
        model.riskLabel = String(localized: "Pending")
        model.riskSubtitle = String(localized: "Complete 3 daily check-ins to see your burnout status.")

        model.statusCard.badgeTitle = String(localized: "Pending")
        model.statusCard.bodyText = String(localized: "Your status will appear after 3 check-ins.")

        model.insights.averageLabel = String(localized: "Insights")
        model.insights.averagePercent = 0

        updateBarsOnly(riskScores: riskScores)
    }

    private func updateStatusCard(riskLabel: String, riskSubtitle: String) {
        switch riskLabel {
        case String(localized: "High"):
            model.statusCard.badgeTitle = String(localized: "High Risk")
            model.statusCard.bodyText = riskSubtitle
        case String(localized: "Medium"):
            model.statusCard.badgeTitle = String(localized: "Medium Risk")
            model.statusCard.bodyText = riskSubtitle
        default:
            model.statusCard.badgeTitle = String(localized: "Low Risk")
            model.statusCard.bodyText = riskSubtitle
        }
    }

    private func updateInsights(riskScores: [DailyRiskScore]) {
        let avgScore = riskScores.reduce(0.0) { $0 + $1.riskScore } / Double(max(riskScores.count, 1))
        let rawPercent = Int(((avgScore - 1.0) / 4.0) * 100)
        let percent = min(max(rawPercent, 0), 100)

        model.insights.averageLabel = String(localized: "Insights")
        model.insights.averagePercent = percent

        updateBarsOnly(riskScores: riskScores)
    }

    private func updateBarsOnly(riskScores: [DailyRiskScore]) {
        let sortedScores = riskScores.sorted { $0.date > $1.date }
        let last3Days = Array(sortedScores.prefix(3))

        var heights = last3Days.map { score in
            CGFloat(min(max(((score.riskScore - 1.0) / 4.0) * 100, 0), 100))
        }

        while heights.count < 3 {
            heights.append(0)
        }

        model.insights.bars = [
            BarModel(height: heights[0], color: Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)),
            BarModel(height: heights[1], color: Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)),
            BarModel(height: heights[2], color: Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0))
        ]
    }

    func updateTodayCard() {
        if hasCompletedCheckIn {
            model.todayCard.badgeTitle = String(localized: "All Done")
            model.todayCard.bodyText = String(localized: "Keep checking in daily for more accurate insights")
        } else {
            model.todayCard.badgeTitle = String(localized: "Check-In Pending")
            model.todayCard.bodyText = String(localized: "Take a minute to complete it when you're ready.")
        }
    }

    func loadUserName() {
        if let name = defaults.string(forKey: "userName"), !name.isEmpty {
            model.userName = name
        }
    }

    private func applyFirstTimeState() {
        isFirstTimeUser = true
        hasMinimumData = false
        hasCompletedCheckIn = false

        model.riskIndex = 0.0
        model.riskLabel = String(localized: "No Status")
        model.riskSubtitle = String(localized: "Answer today's questions to see your burnout status.")

        model.statusCard.badgeTitle = String(localized: "No Status Yet")
        model.statusCard.bodyText = String(localized: "Complete your first check-in to unlock your personalized status.")

        model.todayCard.badgeTitle = String(localized: "Start Now")
        model.todayCard.bodyText = String(localized: "Answer today's questions to generate your first insights.")

        model.insights.averageLabel = String(localized: "Insights")
        model.insights.averagePercent = 0
        model.insights.bars = [
            BarModel(height: 0, color: Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)),
            BarModel(height: 0, color: Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)),
            BarModel(height: 0, color: Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0))
        ]
    }
}


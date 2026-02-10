import Foundation
import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published var hasCompletedCheckIn: Bool = true
    @Published var model: BurnoutDashboardModel = BurnoutDashboardModel(
        userName: "Nourah",
        riskIndex: 0.0,
        riskLabel: "Low",
        riskSubtitle: "Some signs are starting to slightly increase",
        statusCard: InfoCardModel(
            title: "Status",
            actionText: "learn more",
            badgeTitle: "Low Risk",
            bodyText: "Your responses indicate that your productivity level is currently normal"
        ),
        todayCard: InfoCardModel(
            title: "Today’s\nCheck",
            actionText: "View more",
            badgeTitle: "All Done",
            bodyText: "Keep checking in daily for more accurate insights"
        ),
        insights: InsightsModel(
            averageLabel: "Average",
            averagePercent: 30,
            bars: [
                BarModel(height: 28, color: Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)),
                BarModel(height: 42, color: Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)),
                BarModel(height: 56, color: Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0))
            ]
        )
    )

    private let defaults = UserDefaults.standard
    private let keyPrefix = "burnout_"

    // حساب متوسط آخر 3 أيام (0..5)
    func calculateAverageLast3Days() {
        let dates = lastNDates(3)
        let values = dates.compactMap { defaults.object(forKey: keyPrefix + dateKey($0)) as? Double }
        let avg = values.isEmpty ? 0.0 : values.reduce(0, +) / Double(values.count)
        let clamped = min(max(avg, 0), 5)

        model.riskIndex = clamped / 5.0
        model.riskLabel = clamped < 3 ? "Low" : "High"
        model.insights.averagePercent = Int((clamped / 5.0) * 100)
        updateTodayCard()
    }
    
    func updateTodayCard() {
        if hasCompletedCheckIn {
            model.todayCard.badgeTitle = "All Done"
            model.todayCard.bodyText = "Keep checking in daily for more accurate insights"
        } else {
            model.todayCard.badgeTitle = "Check-In Pending"
            model.todayCard.bodyText = "Take a minute to complete it when you’re ready."
        }
    }

    // تخزين قيمة اليوم (0..5)
    func saveToday(value: Double) {
        let clamped = min(max(value, 0), 5)
        let key = keyPrefix + dateKey(Date())
        defaults.set(clamped, forKey: key)
    }

    private func lastNDates(_ n: Int) -> [Date] {
        (0..<n).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}


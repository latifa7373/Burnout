import Foundation
import SwiftUI
import Combine
import SwiftData

final class HomeViewModel: ObservableObject {
    @Published var hasCompletedCheckIn: Bool = true
    @Published var isFirstTimeUser: Bool = true
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
            title: "Today's\nCheck",
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

    // الحساب يعتمد فقط على متوسط آخر 3 أيام (نافذة متحركة)
    func calculateRiskFromLastWeek(dailyRiskScores: [DailyRiskScore]) {
        // أول دخول بدون أي إجابات محفوظة: اعرض حالة ترحيبية بدل النتائج.
        if dailyRiskScores.isEmpty {
            applyFirstTimeState()
            return
        }

        isFirstTimeUser = false

        // التحقق من حالة اليوم
        let today = Calendar.current.startOfDay(for: Date())
        hasCompletedCheckIn = dailyRiskScores.contains { Calendar.current.startOfDay(for: $0.date) == today }
        updateTodayCard()

        // آخر 3 أيام فقط (rolling window)
        let last3Days = Array(dailyRiskScores.sorted { $0.date > $1.date }.prefix(3))
        let avgRiskScore = last3Days.reduce(0.0) { $0 + $1.riskScore } / Double(last3Days.count)
        let clampedAverage = min(max(avgRiskScore, 1.0), 5.0)

        // تحويل من نطاق 1-5 إلى 0-1 للـ gauge
        model.riskIndex = (clampedAverage - 1.0) / 4.0

        // التصنيف حسب المتوسط (بدقة منزلة عشرية واحدة):
        // Low: ...2.0, Medium: 2.1...3.4, High: 3.5...
        let roundedAverage = (clampedAverage * 10).rounded() / 10
        if roundedAverage <= 2.0 {
            model.riskLabel = "Low"
            model.riskSubtitle = "Your average over the past 3 days is in the low range."
        } else if roundedAverage <= 3.4 {
            model.riskLabel = "Medium"
            model.riskSubtitle = "Your average over the past 3 days is in the medium range."
        } else {
            model.riskLabel = "High"
            model.riskSubtitle = "Your average over the past 3 days is in the high range."
        }

        // تحديث Status Card
        updateStatusCard(riskLabel: model.riskLabel, riskSubtitle: model.riskSubtitle)

        // تحديث Insights
        updateInsights(riskScores: last3Days)
    }
    
    private func updateStatusCard(riskLabel: String, riskSubtitle: String) {
        // ✅ اجعل كارد Status يعكس نفس حالة الـ gauge تمامًا
        switch riskLabel {
        case "High":
            model.statusCard.badgeTitle = "High Risk"
            model.statusCard.bodyText = riskSubtitle
        case "Medium":
            model.statusCard.badgeTitle = "Medium Risk"
            model.statusCard.bodyText = riskSubtitle.isEmpty ? "Some early signs are showing. Try recovery habits." : riskSubtitle
        default:
            model.statusCard.badgeTitle = "Low Risk"
            model.statusCard.bodyText = riskSubtitle
        }
    }
    
    private func updateInsights(riskScores: [DailyRiskScore]) {
        // حساب متوسط آخر 3 أيام
        let avgScore = riskScores.isEmpty ? 0.0 :
            riskScores.reduce(0.0) { $0 + $1.riskScore } / Double(riskScores.count)

        // تحويل Risk Score (1-5) إلى نسبة مئوية (0-100)
        let rawPercent = Int(((avgScore - 1.0) / 4.0) * 100)
        let percent = min(max(rawPercent, 0), 100)
        model.insights.averagePercent = percent

        // تحديث الأعمدة بناءً على آخر 3 أيام
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
            model.todayCard.badgeTitle = "All Done"
            model.todayCard.bodyText = "Keep checking in daily for more accurate insights"
        } else {
            model.todayCard.badgeTitle = "Check-In Pending"
            model.todayCard.bodyText = "Take a minute to complete it when you're ready."
        }
    }
    
    // تحميل اسم المستخدم
    func loadUserName() {
        if let name = defaults.string(forKey: "userName"), !name.isEmpty {
            model.userName = name
        }
    }

    private func applyFirstTimeState() {
        isFirstTimeUser = true
        hasCompletedCheckIn = false

        model.riskIndex = 0.0
        model.riskLabel = "No Status"
        model.riskSubtitle = "Answer today's questions to see your burnout status."

        model.statusCard.badgeTitle = "No Status Yet"
        model.statusCard.bodyText = "Complete your first check-in to unlock your personalized status."

        model.todayCard.badgeTitle = "Start Now"
        model.todayCard.bodyText = "Answer today's questions to generate your first insights."

        model.insights.averageLabel = "Insights"
        model.insights.averagePercent = 0
    }
}


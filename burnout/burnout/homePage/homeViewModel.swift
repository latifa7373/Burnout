import Foundation
import SwiftUI
import Combine
import SwiftData

final class HomeViewModel: ObservableObject {
    @Published var hasCompletedCheckIn: Bool = true
    @Published var isFirstTimeUser: Bool = true
    private let inactivityThresholdDays = 3
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

    // تطبيق النمط: "3 أيام خطر خلال أسبوع"
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
        
        // الحصول على آخر أسبوع (7 أيام)
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekStart = calendar.startOfDay(for: weekAgo)
        
        // فلترة Risk Scores للأسبوع الماضي
        let weekRiskScores = dailyRiskScores.filter { $0.date >= weekStart }

        if shouldShowPendingStatus(from: dailyRiskScores) {
            applyInactiveState()
            updateInsights(riskScores: weekRiskScores)
            return
        }
        
        // حساب عدد أيام الخطر خلال الأسبوع (isRiskDay == true)
        let riskDaysCount = weekRiskScores.filter { $0.isRiskDay }.count
        
        // تطبيق النمط: إذا كان هناك 3 أيام أو أكثر خطر خلال الأسبوع → High Risk
        let isHighRisk = riskDaysCount >= 3
        
        // حساب متوسط Risk Score للأسبوع
        let avgRiskScore = weekRiskScores.isEmpty ? 0.0 :
            weekRiskScores.reduce(0.0) { $0 + $1.riskScore } / Double(weekRiskScores.count)
        
        // تحويل من نطاق 1-6 إلى 0-1 للـ gauge
        let normalizedRisk = (avgRiskScore - 1.0) / 5.0
        let clamped = min(max(normalizedRisk, 0.0), 1.0)
        
        model.riskIndex = clamped
        
        // تحديد التصنيف بناءً على النمط (هذا هو مصدر الحقيقة للـ gauge + status card)
        if isHighRisk {
            model.riskLabel = "High"
            model.riskSubtitle = "3 or more risk days detected in the past week"
        } else {
            model.riskLabel = "Low"
            model.riskSubtitle = "Your risk level is within normal range"
        }
        
        // تحديث Status Card
        updateStatusCard(riskLabel: model.riskLabel, riskSubtitle: model.riskSubtitle)
        
        // تحديث Insights
        updateInsights(riskScores: weekRiskScores)
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
        // حساب متوسط Risk Score للأسبوع
        let avgScore = riskScores.isEmpty ? 0.0 :
            riskScores.reduce(0.0) { $0 + $1.riskScore } / Double(riskScores.count)
        
        // تحويل Risk Score (1-6) إلى نسبة مئوية (0-100)
        let rawPercent = Int(((avgScore - 1.0) / 5.0) * 100)
        let percent = min(max(rawPercent, 0), 100)
        model.insights.averagePercent = percent
        
        // تحديث الأعمدة بناءً على آخر 3 أيام من الأسبوع
        let sortedScores = riskScores.sorted { $0.date > $1.date }
        let last3Days = Array(sortedScores.prefix(3))
        
        if last3Days.count >= 3 {
            let heights = last3Days.map { score in
                // تحويل Risk Score (1-6) إلى height (0-100)
                CGFloat(((score.riskScore - 1.0) / 5.0) * 100)
            }
            model.insights.bars = [
                BarModel(height: heights[0], color: Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)),
                BarModel(height: heights[1], color: Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)),
                BarModel(height: heights[2], color: Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0))
            ]
        }
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

    private func shouldShowPendingStatus(from dailyRiskScores: [DailyRiskScore]) -> Bool {
        guard let lastCheckInDate = dailyRiskScores.map(\.date).max() else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastCheckInDate)
        let daysSinceLastCheckIn = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
        return daysSinceLastCheckIn >= inactivityThresholdDays
    }

    private func applyInactiveState() {
        model.riskIndex = 0.0
        model.riskLabel = "Status Pending"
        model.riskSubtitle = "No recent check-ins. Complete today's questions to refresh your status."

        model.statusCard.badgeTitle = "Status Pending"
        model.statusCard.bodyText = "You've been away for a while. Complete today's check-in to update your status."

        model.todayCard.badgeTitle = "Check-In Pending"
        model.todayCard.bodyText = "Take a minute to complete it when you're ready."
    }
}


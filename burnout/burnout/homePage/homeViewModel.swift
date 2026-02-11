import Foundation
import SwiftUI
import Combine
import SwiftData

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
        
        // تحديد التصنيف بناءً على النمط
        if isHighRisk {
            model.riskLabel = "High"
            model.riskSubtitle = "3 or more risk days detected in the past week"
        } else {
            model.riskLabel = "Low"
            model.riskSubtitle = "Your risk level is within normal range"
        }
        
        // تحديث Status Card
        updateStatusCard(isHighRisk: isHighRisk, riskScore: avgRiskScore)
        
        // تحديث Insights
        updateInsights(riskScores: weekRiskScores)
    }
    
    private func updateStatusCard(isHighRisk: Bool, riskScore: Double) {
        if isHighRisk {
            model.statusCard.badgeTitle = "High Risk"
            model.statusCard.bodyText = "3 or more risk days detected in the past week. Please take care of yourself."
        } else {
            model.statusCard.badgeTitle = "Low Risk"
            model.statusCard.bodyText = "Your responses indicate that your productivity level is currently normal"
        }
    }
    
    private func updateInsights(riskScores: [DailyRiskScore]) {
        // حساب متوسط Risk Score للأسبوع
        let avgScore = riskScores.isEmpty ? 0.0 : 
            riskScores.reduce(0.0) { $0 + $1.riskScore } / Double(riskScores.count)
        
        // تحويل Risk Score (1-6) إلى نسبة مئوية (0-100)
        let percent = Int(((avgScore - 1.0) / 5.0) * 100)
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
}


import Foundation
import Combine
import SwiftData

final class BurnoutViewModel: ObservableObject {

    @Published var selectedFilter: TimeFilter = .day
    @Published var data: [ChartDataPoint] = []

    // ✅ الشهر الحالي المختار (للـ Month فقط)
    @Published var selectedMonth: Date = Date()
    
    // ✅ البيانات من SwiftData
    var dailyRiskScores: [DailyRiskScore] = []

    init() {
        loadData()
    }
    
    func updateData(_ riskScores: [DailyRiskScore]) {
        dailyRiskScores = riskScores
        loadData()
    }

    func setFilter(_ filter: TimeFilter) {
        selectedFilter = filter
        loadData()
    }

    // ✅ تنقل بين الشهور (زي التقويم)
    func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        loadData()
    }

    func prevMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
        loadData()
    }

    // ✅ اسم الشهر للعرض (Aug 2026 مثل Apple)
    var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "MMM yyyy"
        return f.string(from: selectedMonth)
    }

    // ✅ تحويل Risk Score من 1-6 إلى 0-100
    func convertToPercentage(_ riskScore: Double) -> Double {
        // Risk Score من 1 إلى 6 → تحويل إلى 0-100
        let percentage = ((riskScore - 1.0) / 5.0) * 100.0
        return min(max(percentage, 0), 100)
    }

    private func loadData() {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .day:
            // Day = اليوم الحالي فقط (نقطة واحدة)
            let today = calendar.startOfDay(for: now)
            let dayScore = dailyRiskScores.first { 
                calendar.isDate($0.date, inSameDayAs: today)
            }
            
            if let score = dayScore {
                // إذا كانت هناك بيانات لليوم، نعرضها كنقطة واحدة
                data = [ChartDataPoint(
                    label: "Today",
                    riskScore: score.riskScore,
                    date: score.date
                )]
            } else {
                // إذا لم توجد بيانات، نعرض نقطة فارغة
                data = [ChartDataPoint(
                    label: "Today",
                    riskScore: 0,
                    date: today
                )]
            }

        case .week:
            // Week = آخر 7 أيام
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let weekStart = calendar.startOfDay(for: weekAgo)
            
            let weekScores = dailyRiskScores.filter { $0.date >= weekStart }
                .sorted { $0.date < $1.date }
            
            // إنشاء نقاط للأيام السبعة
            let days = ["Sat","Sun","Mon","Tue","Wed","Thu","Fri"]
            data = (0..<7).map { dayOffset in
                let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
                let dayStart = calendar.startOfDay(for: targetDate)
                
                // البحث عن Risk Score لهذا اليوم
                if let score = weekScores.first(where: { 
                    calendar.isDate($0.date, inSameDayAs: dayStart)
                }) {
                    return ChartDataPoint(
                        label: days[dayOffset % 7],
                        riskScore: score.riskScore,
                        date: score.date
                    )
                } else {
                    return ChartDataPoint(
                        label: days[dayOffset % 7],
                        riskScore: 0,
                        date: dayStart
                    )
                }
            }

        case .month:
            // Month = أيام الشهر المختار
            let range = calendar.range(of: .day, in: .month, for: selectedMonth) ?? (1..<31)
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth
            
            let monthScores = dailyRiskScores.filter {
                calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
            }.sorted { $0.date < $1.date }
            
            data = range.map { day in
                let targetDate = calendar.date(bySetting: .day, value: day, of: monthStart) ?? monthStart
                let dayStart = calendar.startOfDay(for: targetDate)
                
                if let score = monthScores.first(where: {
                    calendar.isDate($0.date, inSameDayAs: dayStart)
                }) {
                    return ChartDataPoint(
                        label: "\(day)",
                        riskScore: score.riskScore,
                        date: score.date
                    )
                } else {
                    return ChartDataPoint(
                        label: "\(day)",
                        riskScore: 0,
                        date: dayStart
                    )
                }
            }
        }
    }

    private func hourLabel(_ h: Int) -> String {
        switch h {
        case 0: return "12 AM"
        case 6: return "6"
        case 12: return "12 PM"
        case 18: return "6"
        default: return "\(h)"
        }
    }
}

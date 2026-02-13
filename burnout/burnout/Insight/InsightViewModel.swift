import Foundation
import Combine
import SwiftData

final class InsightViewModel: ObservableObject {

    @Published var selectedFilter: TimeFilter = .week
    @Published var data: [ChartDataPoint] = []

    // ✅ الشهر الحالي المختار (للـ Month فقط)
    @Published var selectedMonth: Date = Date()
    
    // ✅ البيانات من SwiftData
    var dailyRiskScores: [DailyRiskScore] = []
    
    // ✅ أيام العمل من UserDefaults
    private var selectedWorkDays: Set<Weekday> {
        let userDefaults = UserDefaults.standard
        let defaultDays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday]

        if let data = userDefaults.data(forKey: "workDays"),
           let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) {
            return decoded.isEmpty ? defaultDays : decoded
        }

        // Backward compatibility: older onboarding stored [String] like ["Sun","Mon"].
        if let stringDays = userDefaults.array(forKey: "workDays") as? [String] {
            let mapped = Set(stringDays.compactMap(mapStringDayToWeekday))
            if !mapped.isEmpty { return mapped }
        }

        return defaultDays
    }
    
    // ✅ تحويل Weekday إلى Calendar weekday number (1 = Sunday, 2 = Monday, etc.)
    private func weekdayToCalendarNumber(_ weekday: Weekday) -> Int {
        switch weekday {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    // ✅ التحقق إذا كان اليوم من أيام العمل
    private func isWorkDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        return selectedWorkDays.contains { weekdayToCalendarNumber($0) == weekdayNumber }
    }

    private func mapStringDayToWeekday(_ day: String) -> Weekday? {
        switch day.lowercased() {
        case "sun", "sunday": return .sunday
        case "mon", "monday": return .monday
        case "tue", "tues", "tuesday": return .tuesday
        case "wed", "wednesday": return .wednesday
        case "thu", "thur", "thurs", "thursday": return .thursday
        case "fri", "friday": return .friday
        case "sat", "saturday": return .saturday
        default: return nil
        }
    }

    // Keep one score per day (latest saved value) so each day is represented once.
    private func latestRiskPerDay(from scores: [DailyRiskScore]) -> [DailyRiskScore] {
        let calendar = Calendar.current
        var byDay: [Date: DailyRiskScore] = [:]

        for score in scores {
            let day = calendar.startOfDay(for: score.date)
            if let existing = byDay[day] {
                if score.date > existing.date {
                    byDay[day] = score
                }
            } else {
                byDay[day] = score
            }
        }

        return byDay.values.sorted { $0.date < $1.date }
    }

    init() {
        loadData()
    }
    
    func updateData(_ riskScores: [DailyRiskScore]) {
        dailyRiskScores = latestRiskPerDay(from: riskScores)
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
        case .week:
            // Week = الأسبوع التقويمي الحالي (Sun...Sat)
            // نعرض أيام الدوام (حتى لو ما جاوب) + أي يوم جاوب فيه داخل الأسبوع.
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start
                ?? calendar.startOfDay(for: now)
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            
            // فلترة بيانات نفس الأسبوع
            let weekScores = dailyRiskScores.filter { score in
                let scoreDate = calendar.startOfDay(for: score.date)
                return scoreDate >= weekStart && scoreDate <= weekEnd
            }.sorted { $0.date < $1.date }
            
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en")
            dayFormatter.dateFormat = "E"
            
            var weekData: [ChartDataPoint] = []
            
            for dayOffset in 0..<7 {
                let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
                let dayStart = calendar.startOfDay(for: targetDate)
                
                let workday = isWorkDay(dayStart)
                let dayLabel = dayFormatter.string(from: dayStart)
                
                if let score = weekScores.first(where: { score in
                    let scoreDate = calendar.startOfDay(for: score.date)
                    return scoreDate == dayStart
                }) {
                    // عنده إجابة -> ينعرض
                    weekData.append(ChartDataPoint(
                        label: dayLabel,
                        riskScore: score.riskScore,
                        date: score.date,
                        isWorkDay: workday,
                        hasResponse: true
                    ))
                } else if workday {
                    // يوم دوام بدون إجابة -> ينعرض بدون عمود
                    weekData.append(ChartDataPoint(
                        label: dayLabel,
                        riskScore: 0,
                        date: dayStart,
                        isWorkDay: true,
                        hasResponse: false
                    ))
                }
            }
            
            data = weekData

        case .month:
            // Month = كل أيام الشهر المختار (28/29/30/31)
            // نعرض الأعمدة فقط للأيام اللي جاوب فيها اليوزر، ونبقي باقي الأيام كفراغ.
            let range = calendar.range(of: .day, in: .month, for: selectedMonth) ?? (1..<31)
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth
            
            let monthScores = dailyRiskScores.filter { score in
                calendar.isDate(score.date, equalTo: selectedMonth, toGranularity: .month)
            }.sorted { $0.date < $1.date }
            
            var monthData: [ChartDataPoint] = []
            for day in range {
                let targetDate = calendar.date(bySetting: .day, value: day, of: monthStart) ?? monthStart
                let dayStart = calendar.startOfDay(for: targetDate)
                let workday = isWorkDay(dayStart)
                
                if let score = monthScores.first(where: { score in
                    let scoreDate = calendar.startOfDay(for: score.date)
                    return scoreDate == dayStart
                }) {
                    monthData.append(ChartDataPoint(
                        label: "\(day)",
                        riskScore: score.riskScore,
                        date: score.date,
                        isWorkDay: workday,
                        hasResponse: true
                    ))
                } else {
                    monthData.append(ChartDataPoint(
                        label: "\(day)",
                        riskScore: 0,
                        date: dayStart,
                        isWorkDay: workday,
                        hasResponse: false
                    ))
                }
            }
            
            data = monthData
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

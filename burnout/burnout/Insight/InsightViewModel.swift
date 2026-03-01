// =========================
//  InsightViewModel.swift (FIXED - Month accuracy)
// =========================
import Foundation
import Combine
import SwiftData

final class InsightViewModel: ObservableObject {
    @Published var selectedFilter: TimeFilter = .week
    @Published var data: [ChartDataPoint] = []
    @Published var selectedMonth: Date = Date()

    var dailyRiskScores: [DailyRiskScore] = []

    private var selectedWorkDays: Set<Weekday> {
        let userDefaults = UserDefaults.standard
        let defaultDays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday]

        if let data = userDefaults.data(forKey: "workDays"),
           let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) {
            return decoded.isEmpty ? defaultDays : decoded
        }

        if let stringDays = userDefaults.array(forKey: "workDays") as? [String] {
            let mapped = Set(stringDays.compactMap(mapStringDayToWeekday))
            if !mapped.isEmpty { return mapped }
        }

        return defaultDays
    }

    private func weekdayToCalendarNumber(_ weekday: Weekday) -> Int {
        switch weekday {
        case .sunday:    return 1
        case .monday:    return 2
        case .tuesday:   return 3
        case .wednesday: return 4
        case .thursday:  return 5
        case .friday:    return 6
        case .saturday:  return 7
        }
    }

    private func isWorkDay(_ date: Date) -> Bool {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return selectedWorkDays.contains { weekdayToCalendarNumber($0) == weekdayNumber }
    }

    private func mapStringDayToWeekday(_ day: String) -> Weekday? {
        switch day.lowercased() {
        case "sun", "sunday":                          return .sunday
        case "mon", "monday":                          return .monday
        case "tue", "tues", "tuesday":                 return .tuesday
        case "wed", "wednesday":                       return .wednesday
        case "thu", "thur", "thurs", "thursday":       return .thursday
        case "fri", "friday":                          return .friday
        case "sat", "saturday":                        return .saturday
        default:                                       return nil
        }
    }

    private func latestRiskPerDay(from scores: [DailyRiskScore]) -> [DailyRiskScore] {
        let calendar = Calendar.current
        var byDay: [Date: DailyRiskScore] = [:]

        for score in scores {
            let day = calendar.startOfDay(for: score.date)
            if let existing = byDay[day] {
                if score.date > existing.date { byDay[day] = score }
            } else {
                byDay[day] = score
            }
        }

        return byDay.values.sorted { $0.date < $1.date }
    }

    init() { }

    func updateData(_ riskScores: [DailyRiskScore]) {
        dailyRiskScores = latestRiskPerDay(from: riskScores)
        loadData()
    }

    func setFilter(_ filter: TimeFilter) {
        selectedFilter = filter
    }

    func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }

    func prevMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }

    var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "MMM yyyy"
        return f.string(from: selectedMonth)
    }

    // ✅ بناء التاريخ الصحيح باستخدام DateComponents بدل date(bySetting:)
    private func buildDayDate(year: Int, month: Int, day: Int) -> Date? {
        var comps = DateComponents()
        comps.year  = year
        comps.month = month
        comps.day   = day
        comps.hour  = 0
        comps.minute = 0
        comps.second = 0
        return Calendar.current.date(from: comps)
    }

    private func loadData() {
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {

        case .week:
            var weekCalendar = Calendar.current
            weekCalendar.firstWeekday = 1

            let weekStart = weekCalendar.dateInterval(of: .weekOfYear, for: now)?.start
                ?? weekCalendar.startOfDay(for: now)

            let weekScores = dailyRiskScores.filter {
                weekCalendar.isDate($0.date, equalTo: weekStart, toGranularity: .weekOfYear)
            }

            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en")
            dayFormatter.dateFormat = "E"

            var weekData: [ChartDataPoint] = []

            for dayOffset in 0..<7 {
                let targetDate = weekCalendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
                let dayStart   = weekCalendar.startOfDay(for: targetDate)
                let workday    = isWorkDay(dayStart)
                let dayLabel   = dayFormatter.string(from: dayStart)

                if let score = weekScores.first(where: {
                    weekCalendar.startOfDay(for: $0.date) == dayStart
                }) {
                    weekData.append(ChartDataPoint(label: dayLabel, riskScore: score.riskScore,
                                                   date: dayStart, isWorkDay: workday, hasResponse: true))
                } else {
                    weekData.append(ChartDataPoint(label: dayLabel, riskScore: 0,
                                                   date: dayStart, isWorkDay: workday, hasResponse: false))
                }
            }

            data = weekData

        case .month:
            // ✅ استخراج السنة والشهر من selectedMonth
            let year  = calendar.component(.year,  from: selectedMonth)
            let month = calendar.component(.month, from: selectedMonth)

            // ✅ عدد أيام الشهر الفعلي
            let compsForRange = DateComponents(year: year, month: month)
            let firstOfMonth  = calendar.date(from: compsForRange) ?? selectedMonth
            let daysInMonth   = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

            // ✅ فلترة السكورات المتعلقة بهذا الشهر/السنة بالضبط
            let monthScores = dailyRiskScores.filter {
                let y = calendar.component(.year,  from: $0.date)
                let m = calendar.component(.month, from: $0.date)
                return y == year && m == month
            }

            var monthData: [ChartDataPoint] = []

            for day in 1...daysInMonth {
                // ✅ بناء التاريخ بدقة باستخدام DateComponents
                guard let dayStart = buildDayDate(year: year, month: month, day: day) else { continue }

                let workday = isWorkDay(dayStart)

                if let score = monthScores.first(where: {
                    calendar.startOfDay(for: $0.date) == dayStart
                }) {
                    monthData.append(ChartDataPoint(label: "\(day)", riskScore: score.riskScore,
                                                    date: dayStart, isWorkDay: workday, hasResponse: true))
                } else {
                    monthData.append(ChartDataPoint(label: "\(day)", riskScore: 0,
                                                    date: dayStart, isWorkDay: workday, hasResponse: false))
                }
            }

            data = monthData
        }
    }
}


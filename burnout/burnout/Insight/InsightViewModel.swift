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
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }

    private func isWorkDay(_ date: Date) -> Bool {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
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

    func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        loadData()
    }

    func prevMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
        loadData()
    }

    var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "MMM yyyy"
        return f.string(from: selectedMonth)
    }

    private func loadData() {
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start
                ?? calendar.startOfDay(for: now)

            let weekScores = dailyRiskScores.filter { score in
                calendar.isDate(score.date, equalTo: weekStart, toGranularity: .weekOfYear)
            }

            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en")
            dayFormatter.dateFormat = "E"

            var weekData: [ChartDataPoint] = []

            for dayOffset in 0..<7 {
                let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
                let dayStart = calendar.startOfDay(for: targetDate)
                let workday = isWorkDay(dayStart)
                let dayLabel = dayFormatter.string(from: dayStart)

                if let score = weekScores.first(where: { calendar.startOfDay(for: $0.date) == dayStart }) {
                    weekData.append(ChartDataPoint(
                        label: dayLabel,
                        riskScore: score.riskScore,
                        date: dayStart,
                        isWorkDay: workday,
                        hasResponse: true
                    ))
                } else {
                    weekData.append(ChartDataPoint(
                        label: dayLabel,
                        riskScore: 0,
                        date: dayStart,
                        isWorkDay: workday,
                        hasResponse: false
                    ))
                }
            }

            data = weekData

        case .month:
            let range = calendar.range(of: .day, in: .month, for: selectedMonth) ?? (1..<31)
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth

            let monthScores = dailyRiskScores.filter {
                calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
            }

            var monthData: [ChartDataPoint] = []

            for day in range {
                let targetDate = calendar.date(bySetting: .day, value: day, of: monthStart) ?? monthStart
                let dayStart = calendar.startOfDay(for: targetDate)
                let workday = isWorkDay(dayStart)

                if let score = monthScores.first(where: { calendar.startOfDay(for: $0.date) == dayStart }) {
                    monthData.append(ChartDataPoint(
                        label: "\(day)",
                        riskScore: score.riskScore,
                        date: dayStart,
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
}


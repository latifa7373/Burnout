import Foundation
import Combine

final class BurnoutViewModel: ObservableObject {

    @Published var selectedFilter: TimeFilter = .day
    @Published var data: [ChartDataPoint] = []

    // ✅ الشهر الحالي المختار (للـ Month فقط)
    @Published var selectedMonth: Date = Date()

    init() {
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

    // ✅ cap
    func cap(_ value: Double) -> Double {
        min(max(value, 0), 100)
    }

    private func loadData() {
        switch selectedFilter {

        case .day:
            // Day = 24 Hours
            data = (0..<24).map { h in
                ChartDataPoint(
                    label: hourLabel(h),
                    value1: Double.random(in: 10...95),
                    value2: Double.random(in: 10...95),
                    value3: Double.random(in: 10...95)
                )
            }

        case .week:
            let days = ["Sat","Sun","Mon","Tue","Wed","Thu","Fri"]
            data = days.map { d in
                ChartDataPoint(
                    label: d,
                    value1: Double.random(in: 10...95),
                    value2: Double.random(in: 10...95),
                    value3: Double.random(in: 10...95)
                )
            }

        case .month:
            // ✅ Month = أيام الشهر المختار فعليًا
            let range = Calendar.current.range(of: .day, in: .month, for: selectedMonth) ?? (1..<31)
            data = range.map { day in
                ChartDataPoint(
                    label: "\(day)",
                    value1: Double.random(in: 10...95),
                    value2: Double.random(in: 10...95),
                    value3: Double.random(in: 10...95)
                )
            }
        }
    }

    private func hourLabel(_ h: Int) -> String {
        return "\(h)"
    }
}

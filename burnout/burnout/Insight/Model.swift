import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let riskScore: Double  // Risk Score من DailyRiskScore (1-6)
    let date: Date  // التاريخ للترتيب
    let isWorkDay: Bool
    let hasResponse: Bool  // true فقط إذا فيه DailyRiskScore محفوظ لليوم
}

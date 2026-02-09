import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value1: Double
    let value2: Double
    let value3: Double
}

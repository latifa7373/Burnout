import SwiftUI
import Charts

struct BurnoutChartScreen: View {

    @StateObject private var vm = BurnoutViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            topBar
            filterMenu
            chartCard
            aboutSection

            Spacer()
        }
        .padding()
        .background(appBackground)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Small Views
private extension BurnoutChartScreen {

    // ✅ نخلي الـ Day أنحف
    var chartItemWidth: CGFloat {
        switch vm.selectedFilter {
        case .day:   return 18
        case .week:  return 44
        case .month: return 28
        }
    }

    var fixedYAxisWidth: CGFloat { 42 }
    var xAxisBottomSpace: CGFloat { 26 }
    var plotHeight: CGFloat { 240 - xAxisBottomSpace }

    var chartWidth: CGFloat {
        max(CGFloat(vm.data.count) * chartItemWidth,
            UIScreen.main.bounds.width - 80)
    }

    // MARK: - Glass Theme
    var glassFill: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.62, green: 0.58, blue: 0.70).opacity(0.32),
                Color(red: 0.40, green: 0.34, blue: 0.52).opacity(0.28)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var glassStroke: Color { .white.opacity(0.10) }
    var glassShadow: Color { .black.opacity(0.18) }

    func glassButton<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(glassFill)
            .overlay(shape.stroke(glassStroke, lineWidth: 1))
            .shadow(color: glassShadow, radius: 10, x: 0, y: 8)
    }

    func glassCard<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(glassFill)
            .overlay(shape.stroke(glassStroke, lineWidth: 1))
            .shadow(color: glassShadow, radius: 18, x: 0, y: 10)
    }

    // MARK: - Top Bar
    var topBar: some View {
        ZStack {
            Text("Burnout Insights")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 36, height: 36)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 12)))

                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Filter Menu
    var filterMenu: some View {
        Menu {
            ForEach(TimeFilter.allCases, id: \.self) { filter in
                Button(filter.rawValue) { vm.setFilter(filter) }
            }
        } label: {
            HStack(spacing: 8) {
                Text(vm.selectedFilter.rawValue)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white.opacity(0.95))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(glassButton(RoundedRectangle(cornerRadius: 14)))
        }
    }

    // ✅ Controls تظهر فقط في Month (يمين زي التقويم)
    var monthControls: some View {
        HStack {
            Spacer()

            Text(vm.monthTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))

            HStack(spacing: 8) {
                Button { vm.prevMonth() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))

                Button { vm.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: - Chart Card
    var chartCard: some View {
        VStack(spacing: 10) {

            // ✅ يطلع فقط وقت Month
            if vm.selectedFilter == .month {
                monthControls
            }

            HStack(alignment: .top, spacing: 8) {

                ScrollView(.horizontal, showsIndicators: false) {
                    chartCore
                        .frame(width: chartWidth, height: 240)
                }

                fixedYAxis
                    .frame(width: fixedYAxisWidth, height: 240)
            }
        }
        .padding(14)
        .background(glassCard(RoundedRectangle(cornerRadius: 22)))
    }

    // ✅ عمود واحد = متوسط (value1,value2,value3) + أخضر
    var chartCore: some View {
        Chart {
            ForEach(Array(vm.data.enumerated()), id: \.element.id) { index, item in
                let avg = (item.value1 + item.value2 + item.value3) / 3

                BarMark(
                    x: .value("Index", index),
                    y: .value("Avg", vm.cap(avg))
                )
                .foregroundStyle(Color(red: 0.30, green: 0.60, blue: 0.60))
                .cornerRadius(6)
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0,25,50,75,100]) { _ in
                AxisGridLine().foregroundStyle(.white.opacity(0.12))
                AxisValueLabel().foregroundStyle(.clear)
            }
        }
        .chartXAxis {
            switch vm.selectedFilter {
            case .day:
                AxisMarks(values: [0, 6, 12, 18]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.white.opacity(0.12))
                    AxisValueLabel {
                        Text(dayAxisLabel(for: value.as(Int.self) ?? 0))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 11))
                    .offset(y: 8)
                }

            case .week:
                AxisMarks(values: .automatic) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.white.opacity(0.12))
                    AxisValueLabel {
                        let i = value.as(Int.self) ?? 0
                        Text(xLabel(for: i))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 11))
                    .offset(y: 8)
                }

            case .month:
                // ✅ Month = أرقام أيام الشهر لكن متباعدة (بدون زحمة)
                AxisMarks(values: monthAxisTicks()) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.white.opacity(0.12))
                    AxisValueLabel {
                        let i = value.as(Int.self) ?? 0
                        Text("\(i + 1)")
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 11))
                    .offset(y: 8)
                }
            }
        }
        .chartPlotStyle {
            $0.background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 8)
    }

    // ✅ ticks للـ Month عشان الأرقام ما تتلاصق
    func monthAxisTicks() -> [Int] {
        let count = vm.data.count
        guard count > 0 else { return [] }

        let step: Int
        if count >= 28 { step = 5 }
        else if count >= 20 { step = 4 }
        else { step = 3 }

        var ticks = Array(stride(from: 0, through: count - 1, by: step))

        if ticks.first != 0 { ticks.insert(0, at: 0) }
        if ticks.last != count - 1 { ticks.append(count - 1) }

        return ticks
    }

    func dayAxisLabel(for hourIndex: Int) -> String {
        switch hourIndex {
        case 0:  return "12 AM"
        case 6:  return "6"
        case 12: return "12 PM"
        case 18: return "6"
        default: return ""
        }
    }

    func xLabel(for index: Int) -> String {
        guard vm.data.indices.contains(index) else { return "" }
        return vm.data[index].label
    }

    var fixedYAxis: some View {
        VStack(spacing: 0) {
            ForEach([100,75,50,25,0], id: \.self) { v in
                Text("\(v)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(height: plotHeight / 5)
            }
            Spacer(minLength: xAxisBottomSpace)
        }
        .allowsHitTesting(false)
    }

    // MARK: - About Section (زي ما هو)
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("About Burnout")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))

            VStack(alignment: .leading, spacing: 14) {
                Text("""
Burnout is an occupational phenomenon — not a medical condition.
It results from chronic workplace stress that has not been successfully managed.

According to ICD-11, burnout is characterized by:
• Feelings of energy depletion or exhaustion
• Increased mental distance or cynicism toward work
• Reduced professional efficacy
""")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.88))
                .lineSpacing(4)

                Link(
                    "Learn more — World Health Organization (ICD-11)",
                    destination: URL(string: "https://www.who.int/standards/classifications/frequently-asked-questions/burn-out-an-occupational-phenomenon")!
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
            }
            .padding(18)
            .background(glassCard(RoundedRectangle(cornerRadius: 22)))
        }
        .padding(.top, 4)
    }

    // ✅ خلفية HEX: #2C1E2F
    var appBackground: some View {
        Color(red: 44/255, green: 30/255, blue: 47/255)
            .ignoresSafeArea()
    }
}

#Preview {
    BurnoutChartScreen()
}

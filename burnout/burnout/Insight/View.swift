import SwiftUI
import Charts

struct BurnoutChartScreen: View {

    @StateObject private var vm = BurnoutViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

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
                AxisMarks(values: Array(vm.data.indices)) { value in
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
                AxisMarks(values: Array(vm.data.indices)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4,4]))
                        .foregroundStyle(.white.opacity(0.12))

                    AxisValueLabel {
                        let i = value.as(Int.self) ?? 0
                        Text("\(i + 1)")   // كل أيام الشهر
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

    // MARK: - ✅ About Section (بنفس ستايل الكروت + Read more)
    var aboutSection: some View {
        ExpandableInfoCard(
            title: "About Burnout",
            actionCollapsed: "Read more",
            actionExpanded: "Show less",
            bodyText: """
Burnout is an occupational phenomenon — not a medical condition.
It results from chronic workplace stress that has not been successfully managed.

According to ICD-11, burnout is characterized by:
• Feelings of energy depletion or exhaustion
• Increased mental distance or cynicism toward work
• Reduced professional efficacy
""",
            linkTitle: "Learn more — World Health Organization (ICD-11)",
            linkURL: URL(string: "https://www.who.int/standards/classifications/frequently-asked-questions/burn-out-an-occupational-phenomenon")!,
            openURL: { url in openURL(url) }
        )
        .padding(.top, 6)
    }

    // ✅ خلفية HEX: #2C1E2F
    var appBackground: some View {
        Color(red: 44/255, green: 30/255, blue: 47/255)
            .ignoresSafeArea()
    }
}

// MARK: - Expandable Card Component (✅ يصغر مع النص ثم ينسدل)
private struct ExpandableInfoCard: View {
    let title: String
    let actionCollapsed: String
    let actionExpanded: String
    let bodyText: String
    let linkTitle: String
    let linkURL: URL
    let openURL: (URL) -> Void

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        expanded.toggle()
                    }
                } label: {
                    Text(expanded ? actionExpanded : actionCollapsed)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }
                .buttonStyle(.plain)
            }

            // ✅ النص موجود دائمًا، ويحدد حجم الكارد
            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(3)
                .lineLimit(expanded ? nil : 3) // ← هنا يصغر ثم يكبر
                .fixedSize(horizontal: false, vertical: true)

            // الرابط يطلع بعد التوسيع فقط (ويبقى أزرق)
            if expanded {
                Button {
                    openURL(linkURL)
                } label: {
                    Text(linkTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardGradient)
        )
    }

    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                Color.white.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    BurnoutChartScreen()
}
